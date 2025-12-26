#!/usr/bin/env bash
set -euo pipefail

ENV_FILE="${1:-poc.env}"
if [[ ! -f "$ENV_FILE" ]]; then
  echo "Missing $ENV_FILE. Copy poc.env.example to poc.env and edit it."
  exit 1
fi

# Export all variables defined in the env file so child scripts inherit them
set -a
# shellcheck disable=SC1090
source "$ENV_FILE"
set +a

# Validate required vars for deployment
REQUIRED_VARS=(
  PREFIX LOCATION GITHUB_ORG PLATFORM_REPO GITOPS_REPO EMAIL
  BACKSTAGE_IMAGE BACKSTAGE_IMAGE_TAG BACKSTAGE_HOST_PREFIX INGRESS_IP
  ARGOCD_HOST_PREFIX BACKSTAGE_GITHUB_TOKEN STORAGE_ACCOUNT TECHDOCS_CONTAINER
  TECHDOCS_STORAGE_KEY POSTGRES_HOST POSTGRES_USER POSTGRES_PASSWORD POSTGRES_DB
  BACKSTAGE_AUTH_MODE AZURE_CLIENT_ID AZURE_TENANT_ID
)

for v in "${REQUIRED_VARS[@]}"; do
  if [[ -z "${!v:-}" ]]; then
    echo "Missing required var: $v"
    exit 1
  fi
done
