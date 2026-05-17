#!/usr/bin/env bash
# Post-talk cleanup. Deletes the CETAS export blobs left behind by the
# Volcano demo so the next pre-talk run doesn't trip over a non-empty
# destination path.
#
# Does NOT rotate SAS tokens or touch .env. For both, see infra/preflight.sh.
#
# Run from anywhere — paths resolve relative to the script.
# Requires: az CLI 2.40+, an active `az login`, and Storage Blob Data
# Contributor (or higher) on the Blob account.

set -euo pipefail

# Paths --------------------------------------------------------------
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ENV_FILE="${ENV_FILE:-${SCRIPT_DIR}/docker/.env}"

# Pull any preflight-style overrides from .env if they're set there and
# not already in the calling environment. The `|| true` guards against
# `set -e` exiting silently when grep finds no match (those keys are
# commented out in .env.example by default).
if [ -f "$ENV_FILE" ]; then
    for _k in SUBSCRIPTION BLOB_ACCOUNT CONTAINER CETAS_PREFIX; do
        if [ -z "${!_k:-}" ]; then
            _v=$(grep -E "^${_k}=" "$ENV_FILE" 2>/dev/null | head -1 | cut -d= -f2- || true)
            [ -n "$_v" ] && export "${_k}=${_v}"
        fi
    done
    unset _k _v || true
fi

# Config (defaults if neither environment nor .env supplied a value).
BLOB_ACCOUNT="${BLOB_ACCOUNT:-cspolybaseblob}"
CONTAINER="${CONTAINER:-ncpop}"
CETAS_PREFIX="${CETAS_PREFIX:-exports/volcanoes/}"

# Sanity checks ------------------------------------------------------
command -v az >/dev/null || { echo "az CLI not found. Install from https://aka.ms/installazurecli" >&2; exit 1; }
az account show -o none 2>/dev/null || { echo "Not signed in. Run: az login" >&2; exit 1; }

# If SUBSCRIPTION is set, target every az call at it explicitly. Avoids
# both the "wrong default subscription" footgun and the side effect of
# `az account set` flipping the user's global default.
SUB_ARGS=()
if [ -n "${SUBSCRIPTION:-}" ]; then
    SUB_ARGS=(--subscription "$SUBSCRIPTION")
fi

echo "[posttalk] Subscription: $(az account show "${SUB_ARGS[@]}" --query name -o tsv)"
echo "[posttalk] Removing CETAS exports at ${BLOB_ACCOUNT}/${CONTAINER}/${CETAS_PREFIX}..."

# Capture both stdout and stderr so a failure shows up loudly instead of
# vanishing into /dev/null.
if ! DELETE_OUTPUT=$(az storage blob delete-batch \
        "${SUB_ARGS[@]}" \
        --source       "$CONTAINER" \
        --account-name "$BLOB_ACCOUNT" \
        --pattern      "${CETAS_PREFIX}*" \
        --auth-mode    login \
        --output       tsv 2>&1); then
    echo "[posttalk] az storage blob delete-batch failed:" >&2
    printf '%s\n' "$DELETE_OUTPUT" >&2
    exit 1
fi

DELETED=$(printf '%s\n' "$DELETE_OUTPUT" | grep -c . || true)
echo "[posttalk] Done (objects removed: ${DELETED})."
