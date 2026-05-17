# Data Virtualization in SQL Server

This is the repository for my talk entitled [Data Virtualization in SQL Server](https://csmore.info/on/polybase).

The demo flow joins a SQL Server query against a variety of data sources, including Cosmos DB (using the MongoDB connector), Azure Blob Storage, Azure Data Lake Storage Gen2, PostgreSQL, another second SQL Server instance, and S3-compatible storage.

## Setting Up

The demos run on a Docker Compose stack (SQL Server 2025 + a second SQL Server 2025 + Postgres 16 + an S3-compatible object store) that bootstraps PolyBase, the `Scratch` and `ExternalExample` databases, all required credentials, and the local S3 bucket on first boot.

### Build and Run

From the repository root:

```bash
cp infra/docker/.env.example infra/docker/.env
$EDITOR infra/docker/.env       # fill in Cosmos / Blob / ADLS secrets

docker compose -f infra/docker/docker-compose.yml up -d --build
```

Watch progress with `docker compose -f infra/docker/docker-compose.yml logs -f`. First boot installs PolyBase and seeds the databases (~1-2 minutes). Subsequent starts come up in seconds.

### Connection Details

| Service           | Host        | Port  | User             | Password (default)  | Database / Bucket |
| ----------------- | ----------- | ----- | ---------------- | ------------------- | ----------------- |
| SQL Server        | `localhost` | 1433  | `sa`             | `Polybase!Demo2025` | `Scratch`         |
| SQL Server remote | `localhost` | 31433 | `sa`             | `Polybase!Demo2025` | `ExternalExample` |
| PostgreSQL        | `localhost` | 5432  | `polybase`       | `pgtestpwd`         | `volcanodemo`     |
| MinIO (S3 API)    | `localhost` | 9000  | `polybases3key`  | `polybases3secret`  | `ncpop` (bucket)  |
| MinIO console     | `localhost` | 9001  | `polybases3key`  | `polybases3secret`  | (web UI)          |

The SQL Server defaults work directly with the VS Code mssql extension or any other SQL client. The MinIO endpoint is HTTPS with a self-signed cert (committed under `infra/docker/s3/`) — connect with `--insecure` (`mc`) or `--no-verify-ssl` (`aws`) from the host, or trust `infra/docker/s3/public.crt` in your client.

### Pre-flight (Azure dependencies)

Some demos read from Cosmos DB and Azure Blob / ADLS Gen2. To rotate SAS tokens and clear prior CETAS exports before a talk:

```bash
az login
infra/preflight.sh
docker compose -f infra/docker/docker-compose.yml down -v
docker compose -f infra/docker/docker-compose.yml up -d
```

The `down -v` is needed because credentials are baked into the SQL Server volume on first boot.

### Stopping and Removing the Stack

```bash
docker compose -f infra/docker/docker-compose.yml down       # stop, keep volumes
docker compose -f infra/docker/docker-compose.yml down -v    # stop and wipe (fresh bootstrap on next up)
```

### Without Docker

If you prefer to install SQL Server 2025 directly, the setup scripts in `src/00 - Setup and Teardown/` create the `Scratch` database, master key, and credentials manually. You will also need a reachable Postgres instance, a second SQL Server instance for the federated-read demo, and SAS tokens for the Azure storage accounts.

## Running the Code

All scripts are in the `src/` folder, organized by demo phase:

| Folder                                  | What it covers |
| --------------------------------------- | -------------- |
| `src/00 - Setup and Teardown/`          | Manual database setup + credential creation (non-container) and a teardown script |
| `src/01 - External Objects/`            | External data sources and file formats |
| `src/02 - North Carolina Population/`   | External tables across Azure Blob (CSV), local SQL lookups, S3-compatible store (Parquet), and ADLS Gen2 (Parquet) |
| `src/03 - Volcano Data/`                | Cosmos volcanoes, Blob country statistics, Postgres type lookup, remote SQL eruption history, CETAS export to Blob |
| `src/04 - Cold Storage/'                | Migrating data from SQL Server into S3-compatible store (Parquet) |

Run them in folder order from SQL Server Management Studio, VS Code with the mssql extension, or whatever your SQL Server query runner of choice.

For deeper Docker stack details (image contents, troubleshooting, master-key handling, full credential table), see [infra/docker/README.md](infra/docker/README.md).
