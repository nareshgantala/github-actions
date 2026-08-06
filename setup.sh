#!/bin/bash
set -euo pipefail

# ── Azure Authentication (Service Principal) ──
if [[ -n "${AZURE_CLIENT_ID:-}" && -n "${AZURE_CLIENT_SECRET:-}" && -n "${AZURE_TENANT_ID:-}" ]]; then
  echo "Logging in to Azure with Service Principal..."
  az login --service-principal \
    --username "$AZURE_CLIENT_ID" \
    --password "$AZURE_CLIENT_SECRET" \
    --tenant "$AZURE_TENANT_ID"

  # Set default subscription if provided
  if [[ -n "${AZURE_SUBSCRIPTION_ID:-}" ]]; then
    az account set --subscription "$AZURE_SUBSCRIPTION_ID"
  fi

  echo "Azure authentication successful."
  az account show --output table
else
  echo "WARNING: Azure credentials not set — skipping Azure login."
fi

# ── AKS Authentication ──
if [[ -n "${AKS_RESOURCE_GROUP:-}" && -n "${AKS_CLUSTER_NAME:-}" ]]; then
  echo "Fetching AKS credentials..."
  az aks get-credentials \
    --resource-group "$AKS_RESOURCE_GROUP" \
    --name "$AKS_CLUSTER_NAME" \
    --overwrite-existing
  echo "AKS credentials configured."
else
  echo "WARNING: AKS credentials not set — skipping AKS login."
fi

# ── ACR Authentication ──
if [[ -n "${ACR_NAME:-}" && -n "${ACR_CLIENT_ID:-}" && -n "${ACR_CLIENT_SECRET:-}" ]]; then
  echo "Logging in to ACR ($ACR_NAME)..."
  docker login "$ACR_NAME" --username "$ACR_CLIENT_ID" --password "$ACR_CLIENT_SECRET"
  echo "ACR authentication successful."
else
  echo "WARNING: ACR credentials not set — skipping ACR login."
fi

# ── Configure and start the GitHub Actions runner ──
./config.sh --url "$RUNNER_URL" --token "$RUNNER_TOKEN" --name "$RUNNER_NAME" --unattended --replace

# Cleanup runner on exit
cleanup() {
  echo "Removing runner..."
  ./config.sh remove --token "$RUNNER_TOKEN" || true
}
trap cleanup EXIT

./run.sh
