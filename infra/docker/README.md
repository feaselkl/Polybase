# Demo stack — SQL Server 2025 + PostgreSQL + remote SQL Server + MinIO

A four-service Docker Compose stack (plus a one-shot init sidecar) that
brings up everything the Data Virtualization demo needs:

- **`sqlserver`** (port 1433) — the SQL Server 2025 instance you can use
  to run demos. This instance includes PolyBase, a `Scratch` database with
  a master key, database-scoped credentials for Cosmos DB, Azure Blob
  Storage, ADLS Gen2, the local Postgres, the remote SQL Server, and the
  local MinIO. 
- **`sqlserver-remote`** (port 31433) — a second SQL Server 2025
  instance that holds the eruption fact table for the federated-read
  demo.
- **`postgres`** (port 5432) — Postgres 16 seeded with the
  `volcano_type` reference table. Speaks ODBC to PolyBase via the
  generic ODBC connector on Linux.
- **`s3`** (port 9000 HTTPS S3 API, 9001 HTTPS console) — MinIO
  (`quay.io/minio/minio`) configured with the self-signed TLS cert in
  `infra/docker/s3/`. PolyBase requires HTTPS for the S3 connector on
  Linux. MinIO loads the cert from `/root/.minio/certs/`. This service
  hosts the median-household-income Parquet for the NC Population demo
  and is what we write to during the cold storage demo.
- **`s3-init`** (one-shot) — uses `minio/mc` to wait for MinIO,
  create the `ncpop` bucket, and upload the HHI Parquet on first boot.

All credentials come from `.env`.

## Prerequisites

- Docker Engine 24+ with the `compose` plugin
- ~3 GB free disk for images and the SQL Server data volumes

## First-time setup: secrets

Cosmos / Blob / ADLS credentials are pulled from a `.env` file that is
gitignored. Copy the example and fill it in:

```bash
cd infra/docker
cp .env.example .env
$EDITOR .env
```

The values land in the running SQL Server containers as environment
variables, are substituted into `*.sql.tmpl` files at first boot via
`envsubst`, and become `CREATE DATABASE SCOPED CREDENTIAL` and
`CREATE LOGIN` statements. They never end up in image layers and are
not persisted on disk after init runs (the rendered SQL files live in
a `mktemp -d` directory that is cleaned up when the entrypoint exits).

You can leave any cloud secret blank if you don't have one. The
corresponding credential is still created (with an empty `SECRET`),
and external sources using it will fail until you supply a real value.
To apply new secrets, run `docker compose down -v` and bring the stack
back up; the init flag is in the SQL Server data volumes, so wiping
the volumes is what re-triggers the bootstrap.

For Azure SAS rotation and CETAS-export cleanup before a talk, see
`infra/preflight.sh`.

## Bring it up

```bash
docker compose up -d --build
```

Watch progress with `docker compose logs -f`. The first start takes
about a minute per SQL Server instance. PolyBase is enabled (primary
only), `Scratch` (primary) and `ExternalExample` (remote) are created,
the credentials and remote login are established, and on the remote
the eruption CSV is `BULK INSERT`-ed from the bind-mounted `data/`.
Subsequent starts skip the bootstrap and come up in seconds.

When `docker compose ps` shows the four long-running services healthy
(`s3-init` will exit successfully after seeding the bucket), you can
connect.

## Connect

| Service           | Host        | Port  | User              | Password (default)  | Database / Bucket |
| ----------------- | ----------- | ----- | ----------------- | ------------------- | ----------------- |
| SQL Server        | `localhost` | 1433  | `sa`              | `Polybase!Demo2025` | `Scratch`         |
| SQL Server remote | `localhost` | 31433 | `sa`              | `Polybase!Demo2025` | `ExternalExample` |
| PostgreSQL        | `localhost` | 5432  | `polybase`        | `pgtestpwd`         | `volcanodemo`     |
| MinIO (S3 API)    | `localhost` | 9000  | `polybases3key`   | `polybases3secret`  | `ncpop` (bucket)  |
| MinIO console     | `localhost` | 9001  | `polybases3key`   | `polybases3secret`  | (web UI)          |

From inside the docker-compose network the hostnames are `sqlserver`,
`sqlserver-remote`, `postgres`, and `s3` (internal ports
`1433` / `1433` / `5432` / `9000`). The PolyBase external data sources
use those internal names — see `src/01 - External Objects/`. From the
host, the MinIO endpoint at `https://localhost:9000` uses the same
self-signed cert.

## Credentials created at init

All inside the primary's `Scratch` database:

| Credential                  | Used by                                | Identity source        | Secret source              |
| --------------------------- | -------------------------------------- | ---------------------- | -------------------------- |
| `CosmosCredential`          | Cosmos DB MongoDB API source           | `${COSMOS_USER}`       | `${COSMOS_KEY}`            |
| `AzureStorageCredential`    | Azure Blob Storage source              | `SHARED ACCESS SIGNATURE` | `${AZURE_BLOB_SAS}`     |
| `DataLakeCredential`        | Azure Data Lake Storage Gen2 source    | `SHARED ACCESS SIGNATURE` | `${AZURE_ADLS_SAS}`     |
| `PostgresVolcanoCredential` | Local Postgres ODBC source             | `${POSTGRES_USER}`     | `${POSTGRES_PASSWORD}`     |
| `RemoteSqlCredential`       | Remote SQL Server `sqlserver://` source | `${REMOTE_SQL_USER}`   | `${REMOTE_SQL_PASSWORD}`   |
| `S3Credential`              | Local S3-compatible (`s3://`) source   | `'S3 Access Key'`      | `${S3_ACCESS_KEY}:${S3_SECRET_KEY}` |

The remote SQL Server's init creates a matching login (`polybase_reader`
by default) granted `SELECT` on `ExternalExample.dbo.Eruption`.

## Master key

The demo scripts under `src/` open the master key with the literal
`OPEN MASTER KEY DECRYPTION BY PASSWORD = '<<SomeSecureKey>>'`. The
default `MASTER_KEY_PASSWORD` in `.env.example` is set to that same
value so the scripts run as-is on the container stack. If you change
`MASTER_KEY_PASSWORD` in your `.env`, update the literal in
the demo scripts to match.

## MinIO TLS cert

`infra/docker/s3/public.crt` and `private.key` are a self-signed cert
pair for hostname `s3` (SAN: `s3`, `localhost`, `127.0.0.1`), valid 10
years. MinIO loads them from `/root/.minio/certs/` for HTTPS, and the
SQL Server containers mount `public.crt` at
`/var/opt/mssql/security/ca-certificates/s3-mock.crt`.
If you need to rotate the certificate, regenerate and then run
`docker compose down && up -d`.

Trace flag 13702 in `mssql.conf` is required for the PolyBase S3 cert
chain to validate against this runtime trust path; it's already set.

This cert has no real security implications — it's a dev-only artifact
for a local mock. Rotate or replace before reusing this stack outside
the demo. Reference openssl command:

```bash
openssl req -x509 -nodes -days 3650 -newkey rsa:2048 \
    -keyout infra/docker/s3/private.key -out infra/docker/s3/public.crt \
    -subj "/CN=s3" \
    -addext "subjectAltName=DNS:s3,DNS:localhost,IP:127.0.0.1"
```

## What the SQL Server image contains

- `mcr.microsoft.com/mssql/server:2025-latest` as the base (Ubuntu 24.04)
- `mssql-server-polybase` for the SQL Server, Cosmos DB, Postgres, and
  generic ODBC connectors
- `mssql-tools18` for `sqlcmd`
- `unixodbc` and `odbc-postgresql` so PolyBase can speak ODBC to
  Postgres on Linux (a SQL Server 2025 feature)
- `dotnet-runtime-8.0` because PolyBase's External Execution Service
  (EES) is a .NET 8 application; without this, ODBC queries fail with
  a gRPC "failed to pick subchannel" error
- `gettext-base` for `envsubst`
- A first-boot entrypoint that enables PolyBase (primary), renders
  init templates with `.env` values, runs the rendered SQL via
  `sqlcmd`, restarts SQL Server so PolyBase activates, then launches
  the EES so ODBC connectors can load their drivers

The Postgres image is unmodified `postgres:16`, seeded with the
`volcano_type` reference table from `postgres/init/01-volcano-types.sql`.

## ODBC connectors and the External Execution Service

ODBC connectors (Postgres, generic) follow a different path than
the file-based engine and the SQL/Cosmos connectors. Three things have
to be lined up correctly inside the SQL Server container:

1. **External Execution Service (EES)** — a separate .NET 8 process at
   `/opt/mssql/bin/ExternalExecutionService` that loads ODBC drivers
   into an isolated host. The engine talks to it over gRPC on
   `127.0.0.1:25100`. Normally `systemd` starts the
   `mssql-ees.service` unit; the container has no systemd, so the
   entrypoint does it manually. The 2025 image splits the wrapper
   binary from its `.dll` (bin vs lib), and ships the dll without the
   `+x` bit set, so the entrypoint also symlinks the `.dll` /
   `.deps.json` / `.runtimeconfig.json` / `.dll.config` into bin and
   `chmod +x`s the wrapper. See `start_ees()` in
   `sqlserver/entrypoint.sh`.
2. **ODBC driver registration** — `odbc-postgresql` adds an entry to
   `/etc/odbcinst.ini` for the driver name (`PostgreSQL Unicode`).
3. **DSN registration** — PolyBase's generic ODBC connector on Linux
   looks up DSNs in `/etc/odbc.ini` even when the external data
   source's `CONNECTION_OPTIONS` specifies `Driver={...}` inline.
   `sqlserver/odbc.ini` defines `[PostgresVolcano]` with the driver,
   server, port, and database; the SQL Server EDS references the DSN
   by name (`CONNECTION_OPTIONS = 'DSN=PostgresVolcano;'`).

### LOCATION syntax for the PolyBase ODBC connector

External tables over ODBC require **three parts** in the `LOCATION`
string: `database.schema.table`. PolyBase splits on `.`, pushes the
first segment into `database=...` in the ODBC connection string, and
uses the rest as the table identifier.

For PostgreSQL the schema is `public`, which is a reserved word in
PolyBase's identifier parser — wrap it in brackets:

```sql
LOCATION = 'volcanodemo.[public].volcano_type'
```

Common error codes for this:

| Error    | Meaning                                          |
| -------- | ------------------------------------------------ |
| `105076` | Could not be parsed (often: reserved word in identifier — try brackets) |
| `105121` | Two-part identifier found, expected three        |
| `105082` | ODBC connect failed — usually `database=<your_table_name>` because LOCATION was 1-part |

## Tear down

```bash
docker compose down          # stop containers, keep volumes (fast restart)
docker compose down -v       # stop and delete data volumes (fresh start)
```

Use `down -v` to force the bootstrap to re-run on next start. This is useful
when you change a secret in `.env` or rotate SAS tokens with the
preflight script.

## Pre-talk / post-talk scripts

Two helper scripts live alongside this folder in `infra/`. These are for
when I deliver a talk and should not be necessary for your own testing.

- **`preflight.sh`** — run before a talk. Requires an active
  `az login`. Generates fresh week-long SAS tokens (read / write /
  list / create) for the Blob and ADLS Gen2 accounts, writes them
  into `.env`, and clears any prior CETAS export blobs. After it
  finishes, `docker compose down -v && docker compose up -d` to
  re-bake the credentials with the new SAS values.
- **`posttalk.sh`** — run after a talk. Deletes the CETAS export
  blobs left behind by the Volcano demo so the next preflight run
  isn't tripped by a non-empty destination. Uses `az login` auth —
  no SAS generation, no `.env` writes.

Both scripts honor `BLOB_ACCOUNT`, `LAKE_ACCOUNT`, `CONTAINER`,
`CETAS_PREFIX`, and `EXPIRY_DAYS` overrides that you can set in `.env`.

## Troubleshooting

- **A service stays unhealthy.** Watch `docker compose logs <service>`.
  Common causes: SA password doesn't meet policy (8+ chars, three of
  upper/lower/digit/symbol); a `CREATE DATABASE SCOPED CREDENTIAL`
  failed because a secret contains an unescaped single quote.
- **Federated read returns zero rows.** The remote `dbo.Eruption` is
  loaded by `BULK INSERT` with `ROWTERMINATOR = '0x0a'` — if
  `data/VolcanoEruptions.csv` was checked out with CRLF, every row
  past the first rejects silently. The repo's `.gitattributes` keeps
  the file LF; if you re-saved it from a Windows editor, normalize
  back to LF.
- **First boot is slow.** The PolyBase package adds hundreds of MB
  to the image; the first `docker compose up --build` pulls and
  installs it. After the build, container starts are fast.
- **`docker compose down` did not pick up new secrets in `.env`.** The
  init flag lives in the `sqlserver-data`, `sqlserver-remote-data`, and
  `s3-init-flag` volumes. Use `docker compose down -v`, then
  `docker compose up -d`.
- **PolyBase fails to connect to MinIO.** The cert is bind-mounted at
  runtime to `/var/opt/mssql/security/ca-certificates/s3-mock.crt`, so
  rebuilding isn't needed, but the SQL Server container has to be
  *restarted* for the certificate scan to pick it up.
  `docker compose restart sqlserver sqlserver-remote` is enough.
  Also confirm trace flag 13702 is enabled
  (`SELECT * FROM sys.dm_server_registry WHERE registry_key LIKE '%TraceFlag%'`
  or check `mssql.conf`).
- **MinIO won't accept the cert.** `public.crt` and `private.key` need
  exact filenames at `/root/.minio/certs/`. Confirm via
  `docker exec s3 ls /root/.minio/certs/`.
- **ODBC external table fails with gRPC "failed to pick subchannel".**
  The PolyBase External Execution Service (EES) isn't running. Verify:
  `docker exec sqlserver ss -tln | grep 25100` should show a listener.
  If empty, check `docker exec sqlserver tail -40 /var/opt/mssql/log/polybase-ees-log/ees.out`
  for the actual reason. Common causes on a fresh install: missing
  `dotnet-runtime-8.0` (rebuild the image), or the EES wrapper at
  `/opt/mssql/bin/ExternalExecutionService` can't find its `.dll` /
  `.deps.json` siblings (the entrypoint symlinks them — confirm with
  `docker exec sqlserver ls -la /opt/mssql/bin/External*`).
- **ODBC error: "could not be parsed" or `database=<table_name>` in
  the connection string.** LOCATION on an ODBC external table needs
  three parts (`database.schema.table`); reserved words like `public`
  must be bracketed (`'volcanodemo.[public].volcano_type'`). See the
  ODBC connectors section above.
- **`docker stop` returns "permission denied" on Ubuntu 24.04.**
  Stale AppArmor profiles for the running container are blocking the
  signal. Run `sudo aa-remove-unknown` to clear orphaned profiles,
  then retry the stop / `down`.
