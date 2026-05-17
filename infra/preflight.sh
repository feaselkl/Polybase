#!/usr/bin/env bash
# Pre-flight for the Data Virtualization demo.
#
#   1. Verifies you're logged into Azure with `az`.
#   2. Generates fresh container-level SAS tokens (read+write+list+create,
#      one-week expiry) for the Blob and ADLS Gen2 demo accounts.
#   3. Writes them into infra/docker/.env.
#   4. Deletes prior CETAS export blobs under exports/volcanoes/ so the
#      Volcano CETAS demo can re-run cleanly.
#
# Run from anywhere — paths resolve relative to the script. NOT invoked
# by docker compose; run it manually before the talk.
#
# Requires: az CLI 2.40+, awk, date.
# Permissions: Owner / Contributor / Storage Account Key Operator on both
#              storage accounts (so `az` can fetch account keys for SAS).

set -euo pipefail

# Paths --------------------------------------------------------------
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ENV_FILE="${ENV_FILE:-${SCRIPT_DIR}/docker/.env}"

# Pull preflight-specific overrides from .env if they're set there and
# not already present in the calling environment. Only the keys this
# script understands — secrets like AZURE_BLOB_SAS are left alone. The
# `|| true` guards against `set -e` exiting silently when grep finds no
# match (those keys are commented out in .env.example by default).
if [ -f "$ENV_FILE" ]; then
    for _k in SUBSCRIPTION BLOB_ACCOUNT LAKE_ACCOUNT CONTAINER CETAS_PREFIX EXPIRY_DAYS; do
        if [ -z "${!_k:-}" ]; then
            _v=$(grep -E "^${_k}=" "$ENV_FILE" 2>/dev/null | head -1 | cut -d= -f2- || true)
            [ -n "$_v" ] && export "${_k}=${_v}"
        fi
    done
    unset _k _v || true
fi

# Config (defaults applied if neither environment nor .env supplied a value).
BLOB_ACCOUNT="${BLOB_ACCOUNT:-cspolybaseblob}"
LAKE_ACCOUNT="${LAKE_ACCOUNT:-cspolybaselake}"
CONTAINER="${CONTAINER:-ncpop}"
CETAS_PREFIX="${CETAS_PREFIX:-exports/volcanoes/}"
EXPIRY_DAYS="${EXPIRY_DAYS:-7}"

# Sanity checks ------------------------------------------------------
command -v az >/dev/null || { echo "az CLI not found. Install from https://aka.ms/installazurecli" >&2; exit 1; }
[ -f "$ENV_FILE" ]       || { echo ".env not found at $ENV_FILE — copy .env.example first" >&2; exit 1; }
az account show -o none 2>/dev/null || { echo "Not signed in. Run: az login" >&2; exit 1; }

# If SUBSCRIPTION is set, target every az call at it explicitly. Avoids
# the "wrong default subscription" footgun without flipping the user's
# global default via `az account set`.
SUB_ARGS=()
if [ -n "${SUBSCRIPTION:-}" ]; then
    SUB_ARGS=(--subscription "$SUBSCRIPTION")
fi

EXPIRY=$(date -u -d "+${EXPIRY_DAYS} days" '+%Y-%m-%dT%H:%MZ')

echo "[preflight] Subscription: $(az account show "${SUB_ARGS[@]}" --query name -o tsv)"
echo "[preflight] SAS expiry:   $EXPIRY"

# SAS generation -----------------------------------------------------
# Account-level SAS over blob service, all resource types, rwlc.
# Works for both Blob (REST) and ADLS Gen2 (DFS) endpoints since
# ADLS Gen2 storage accounts honour the same SAS.
gen_sas () {
    local account="$1"
    az storage account generate-sas \
        "${SUB_ARGS[@]}" \
        --account-name "$account" \
        --services    b \
        --resource-types sco \
        --permissions rwlc \
        --expiry      "$EXPIRY" \
        --https-only \
        --output      tsv \
        | tr -d '\r\n'
}

echo "[preflight] Generating SAS for $BLOB_ACCOUNT..."
BLOB_SAS=$(gen_sas "$BLOB_ACCOUNT")
echo "[preflight] Generating SAS for $LAKE_ACCOUNT..."
LAKE_SAS=$(gen_sas "$LAKE_ACCOUNT")

# Update .env in place. awk-based so SAS tokens with & = + / are
# never interpreted as substitution metacharacters.
update_env () {
    local key="$1" value="$2" file="$3"
    local tmp="${file}.tmp"
    KEY="$key" VALUE="$value" awk '
        BEGIN { key = ENVIRON["KEY"]; value = ENVIRON["VALUE"]; found = 0 }
        $0 ~ "^"key"=" { print key"="value; found = 1; next }
        { print }
        END { if (!found) print key"="value }
    ' "$file" > "$tmp"
    mv "$tmp" "$file"
}

update_env "AZURE_BLOB_SAS" "$BLOB_SAS" "$ENV_FILE"
update_env "AZURE_ADLS_SAS" "$LAKE_SAS" "$ENV_FILE"
echo "[preflight] SAS tokens written to $ENV_FILE."

# CETAS cleanup ------------------------------------------------------
echo "[preflight] Cleaning prior CETAS exports at ${BLOB_ACCOUNT}/${CONTAINER}/${CETAS_PREFIX}..."
if ! DELETE_OUTPUT=$(az storage blob delete-batch \
        "${SUB_ARGS[@]}" \
        --source       "$CONTAINER" \
        --account-name "$BLOB_ACCOUNT" \
        --pattern      "${CETAS_PREFIX}*" \
        --sas-token    "$BLOB_SAS" \
        --output       tsv 2>&1); then
    echo "[preflight] az storage blob delete-batch failed:" >&2
    printf '%s\n' "$DELETE_OUTPUT" >&2
    exit 1
fi
DELETED=$(printf '%s\n' "$DELETE_OUTPUT" | grep -c . || true)
echo "[preflight] CETAS cleanup complete (objects removed: ${DELETED})."

# Done ---------------------------------------------------------------
cat <<EOF

Ready. To pick up the new SAS in the running container:

    docker compose -f ${SCRIPT_DIR}/docker/docker-compose.yml down -v
    docker compose -f ${SCRIPT_DIR}/docker/docker-compose.yml up -d

(\`down -v\` is required: credentials are baked at first boot and held
in the sqlserver-data volume. Wiping the volume re-triggers the bootstrap
with the refreshed SAS tokens from .env.)
EOF
