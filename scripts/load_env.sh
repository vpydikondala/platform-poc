#!/usr/bin/env bash
set -euo pipefail

ENV_FILE="${1:-poc.env}"

if [[ ! -f "$ENV_FILE" ]]; then
  echo "Missing $ENV_FILE. Copy poc.env.example to poc.env."
  exit 1
fi

# Export env vars
set -a
# shellcheck disable=SC1090
source "$ENV_FILE"
set +a

# ===== Base required vars (static, always present) =====
REQUIRED_VARS=(
  PREFIX
  LOCATION
  GITHUB_ORG
  PLATFORM_REPO
  GITOPS_REPO
  EMAIL
  BACKSTAGE_NAMESPACE
  BACKSTAGE_SERVICE_NAME
  BACKSTAGE_HOST_PREFIX
  ARGOCD_HOST_PREFIX
)

for v in "${REQUIRED_VARS[@]}"; do
  if [[ -z "${!v:-}" ]]; then
    echo "Missing required var: $v"
    exit 1
  fi
done

echo "Environment loaded successfully from $ENV_FILE"
