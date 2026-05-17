# Convert the bundled Raleigh Fire Incidents Parquet file to CSV at image
# build time. BULK INSERT can't read Parquet, and OPENROWSET(BULK ...,
# FORMAT='PARQUET') on on-prem SQL Server requires an external data source
# backed by Azure Storage or S3, so it can't use local file paths.
FROM python:3.12-slim AS parquet-to-csv
RUN pip install --no-cache-dir duckdb
COPY --from=data RaleighFireIncidents.parquet /work/in.parquet
# TRY_STRPTIME converts the source 'yyyy/MM/dd HH:mm:ss+00' strings to
# TIMESTAMP and yields NULL on the empty values in the file (1,456 rows
# have an empty dispatch_date_time). DuckDB writes TIMESTAMP as ISO
# 'YYYY-MM-DD HH:MM:SS' and NULL as an unquoted empty field, both of
# which BULK INSERT parses directly into DATETIME2(0).
RUN python <<'PY'
import duckdb
duckdb.sql("""
COPY (
    SELECT
        incident_number,
        incident_type,
        incident_type_description,
        TRY_STRPTIME(arrive_date_time,   '%Y/%m/%d %H:%M:%S+00') AS arrive_date_time,
        TRY_STRPTIME(cleared_date_time,  '%Y/%m/%d %H:%M:%S+00') AS cleared_date_time,
        TRY_STRPTIME(dispatch_date_time, '%Y/%m/%d %H:%M:%S+00') AS dispatch_date_time,
        exposure,
        platoon,
        station,
        address,
        address2,
        apt_room
    FROM read_parquet('/work/in.parquet')
) TO '/work/RaleighFireIncidents.csv' (HEADER, FORMAT 'csv')
""")
PY

FROM mcr.microsoft.com/mssql/server:2025-latest

USER root

# Add the Microsoft package repos for the base OS this image was built on.
# gettext-base supplies envsubst, used to render ${VAR} placeholders in init templates.
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        curl ca-certificates gnupg lsb-release gettext-base && \
    rm -rf /var/lib/apt/lists/*

# Place the dearmored Microsoft signing key at the path the upstream
# .list files reference (signed-by=/usr/share/keyrings/microsoft-prod.gpg).
# That value is baked into both list files for Ubuntu 24.04+, so no sed
# rewrite is needed and trying to prepend another signed-by block
# produces two [...] options on the deb line, which apt rejects.
RUN install -d -m 0755 /usr/share/keyrings && \
    curl -fsSL https://packages.microsoft.com/keys/microsoft.asc \
        | gpg --batch --yes --no-tty --dearmor -o /usr/share/keyrings/microsoft-prod.gpg && \
    UBUNTU_REL="$(lsb_release -rs)" && \
    curl -fsSL "https://packages.microsoft.com/config/ubuntu/${UBUNTU_REL}/mssql-server-2025.list" \
        > /etc/apt/sources.list.d/mssql-server-2025.list && \
    curl -fsSL "https://packages.microsoft.com/config/ubuntu/${UBUNTU_REL}/prod.list" \
        > /etc/apt/sources.list.d/microsoft-prod.list

# PolyBase service (needed for Cosmos/Postgres/SQL connectors), sqlcmd, and Postgres ODBC driver.
# odbc-postgresql + unixodbc give us SQL Server 2025's ODBC-on-Linux PolyBase capability.
# dotnet-runtime-8.0 is required by the PolyBase External Execution Service (EES),
# which is the dotnet process that loads ODBC drivers for connectors like Postgres.
# Without it, the EES wrapper at /opt/mssql/bin/ExternalExecutionService fails with
# "You must install .NET to run this application" and ODBC queries return a gRPC
# "failed to pick subchannel" error. The mssql-server-polybase package doesn't pull
# it in transitively under --no-install-recommends, so we add it explicitly.
RUN apt-get update && \
    ACCEPT_EULA=Y apt-get install -y --no-install-recommends \
        mssql-server-polybase \
        mssql-tools18 \
        unixodbc \
        odbc-postgresql \
        dotnet-runtime-8.0 && \
    rm -rf /var/lib/apt/lists/*

ENV PATH="/opt/mssql-tools18/bin:${PATH}"

COPY mssql.conf /var/opt/mssql/mssql.conf
COPY odbc.ini /etc/odbc.ini
COPY entrypoint.sh /usr/local/bin/entrypoint.sh
COPY init/ /docker-entrypoint-initdb.d/

# CSV derived from the Raleigh Fire Incidents parquet file by the
# parquet-to-csv builder stage. Loaded into Scratch.dbo.RaleighFireIncidents
# by 04-load-fireincidents.sql on first boot.
COPY --from=parquet-to-csv /work/RaleighFireIncidents.csv /var/opt/mssql/data-shared/RaleighFireIncidents.csv

RUN chmod +x /usr/local/bin/entrypoint.sh && \
    chown -R mssql:root /var/opt/mssql /docker-entrypoint-initdb.d && \
    chmod -R a+r /docker-entrypoint-initdb.d

EXPOSE 1433

# Run the entrypoint as root so it can launch the PolyBase External
# Execution Service as user mssql_ees and sqlservr as user mssql.
# The entrypoint uses runuser to drop privileges for both processes.
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
