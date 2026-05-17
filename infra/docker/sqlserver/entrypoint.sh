#!/bin/bash
set -e

INIT_FLAG=/var/opt/mssql/.polybase-initialized

# Names of the env vars whose values we substitute into *.sql.tmpl files.
# Listed explicitly so envsubst leaves any other ${...} (e.g. T-SQL string
# fragments) alone.
TEMPLATE_VARS='${MASTER_KEY_PASSWORD} ${COSMOS_USER} ${COSMOS_KEY} ${AZURE_BLOB_SAS} ${AZURE_ADLS_SAS} ${AZURE_SQL_USER} ${AZURE_SQL_PASSWORD} ${POSTGRES_USER} ${POSTGRES_PASSWORD} ${REMOTE_SQL_USER} ${REMOTE_SQL_PASSWORD} ${S3_ACCESS_KEY} ${S3_SECRET_KEY}'

# Launch the PolyBase External Execution Service (EES). This loads ODBC drivers
# (Postgres etc.) into a separate process the engine talks to via gRPC on
# port 25100. Normally started by systemd; in a container we launch it
# directly. SQL Server 2025's image ships a wrapper binary at
# /opt/mssql/bin/ExternalExecutionService that handles dotnet runtime
# resolution itself, so we don't need to wire DOTNET_ROOT or TMPDIR. The
# image doesn't create a separate mssql_ees account either, so we just
# run as mssql.
start_ees() {
    local ees=/opt/mssql/bin/ExternalExecutionService
    if [ ! -f "$ees" ]; then
        echo "[init] EES binary not found at $ees; ODBC connectors will fail." >&2
        return
    fi
    # The 2025 image splits the dotnet apphost wrapper from its
    # supporting files: the wrapper is in /opt/mssql/bin/ but the .dll +
    # sidecars are in /opt/mssql/lib/. The wrapper expects the dll as a
    # sibling, so symlink the four files into bin/ where it looks.
    for f in ExternalExecutionService.dll \
             ExternalExecutionService.deps.json \
             ExternalExecutionService.runtimeconfig.json \
             ExternalExecutionService.dll.config; do
        if [ ! -e "/opt/mssql/bin/$f" ] && [ -f "/opt/mssql/lib/$f" ]; then
            ln -sf "/opt/mssql/lib/$f" "/opt/mssql/bin/$f"
        fi
    done
    # Some 2025 image builds ship the binary mode 644. Make it executable
    # for mssql before runuser tries to launch it.
    chmod +x "$ees" 2>/dev/null || true
    mkdir -p /var/opt/mssql/log/polybase-ees-log
    chown -R mssql:root /var/opt/mssql/log/polybase-ees-log 2>/dev/null || true
    echo "[init] Starting PolyBase External Execution Service (EES)..."
    runuser -u mssql -- "$ees" \
        > /var/opt/mssql/log/polybase-ees-log/ees.out 2>&1 &
    EES_PID=$!
    # Brief readiness check: if EES dies within 2s, log the tail so the
    # cause is visible in `docker logs`.
    sleep 2
    if ! kill -0 "$EES_PID" 2>/dev/null; then
        echo "[init] EES exited immediately; ees.out tail:" >&2
        tail -30 /var/opt/mssql/log/polybase-ees-log/ees.out >&2 || true
    fi
}

# sqlservr always runs as the mssql user (uid 10001).
run_sqlservr_bg() {
    runuser -u mssql -- /opt/mssql/bin/sqlservr &
    SQL_PID=$!
}

if [ ! -f "$INIT_FLAG" ] && [ -d /docker-entrypoint-initdb.d ]; then
    echo "[init] First boot — bootstrapping PolyBase and credentials..."

    run_sqlservr_bg

    # Bare 'SELECT 1' can succeed once and then start failing as SQL Server
    # cycles in and out of script upgrade mode while bringing system
    # databases (model_msdb, msdb, DWDiagnostics from the PolyBase package)
    # to the current schema. Require N consecutive 1s-spaced successes
    # before we consider the engine stably ready for init.
    CONSECUTIVE_OK=0
    REQUIRED_OK=5
    for i in $(seq 1 240); do
        if /opt/mssql-tools18/bin/sqlcmd -S localhost -U sa -P "$MSSQL_SA_PASSWORD" -C -l 2 -Q "SELECT 1" >/dev/null 2>&1; then
            CONSECUTIVE_OK=$((CONSECUTIVE_OK + 1))
            if [ "$CONSECUTIVE_OK" -ge "$REQUIRED_OK" ]; then
                echo "[init] SQL Server is stably accepting connections."
                break
            fi
        else
            CONSECUTIVE_OK=0
        fi
        if ! kill -0 "$SQL_PID" 2>/dev/null; then
            echo "[init] sqlservr exited before becoming ready. Aborting." >&2
            exit 1
        fi
        sleep 1
    done

    # Render any *.sql.tmpl files into a private temp dir, then run all
    # rendered + plain *.sql files in a single sorted order. Keeping the
    # rendered output off-disk-after-use means secrets don't linger in the
    # image and only appear in the running process while sqlcmd executes them.
    RENDER_DIR=$(mktemp -d)
    trap 'rm -rf "$RENDER_DIR"' EXIT

    for f in /docker-entrypoint-initdb.d/*; do
        [ -e "$f" ] || continue
        base=$(basename "$f")
        case "$base" in
            *.sql.tmpl)
                out="$RENDER_DIR/${base%.tmpl}"
                envsubst "$TEMPLATE_VARS" < "$f" > "$out"
                chmod 600 "$out"
                ;;
            *.sql)
                cp "$f" "$RENDER_DIR/$base"
                ;;
        esac
    done

    # Per-script retry: a late-arriving system-DB upgrade can put the engine
    # back into script upgrade mode for a few seconds. Retry sqlcmd a small
    # number of times before giving up so that race doesn't fail init.
    for sql in $(find "$RENDER_DIR" -maxdepth 1 -name '*.sql' | sort); do
        echo "[init] Applying $(basename "$sql")"
        for retry in 1 2 3 4 5; do
            if /opt/mssql-tools18/bin/sqlcmd -S localhost -U sa -P "$MSSQL_SA_PASSWORD" -C -b -i "$sql"; then
                break
            fi
            if [ "$retry" -eq 5 ]; then
                echo "[init] $(basename "$sql") failed after 5 attempts. Aborting." >&2
                exit 1
            fi
            echo "[init] $(basename "$sql") failed (attempt $retry/5); waiting 5s before retry..."
            sleep 5
        done
    done

    touch "$INIT_FLAG"

    echo "[init] Stopping SQL Server so PolyBase changes take effect..."
    kill -SIGTERM "$SQL_PID"
    wait "$SQL_PID" 2>/dev/null || true
    echo "[init] Restarting with PolyBase enabled."
fi

# Background the EES so the ODBC connectors have a worker to talk to,
# then foreground sqlservr as PID 1's main child.
start_ees
exec runuser -u mssql -- /opt/mssql/bin/sqlservr
