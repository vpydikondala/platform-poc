#!/usr/bin/env bash
set -euo pipefail
ENV_FILE="${1:-poc.env}"
if [[ ! -f "$ENV_FILE" ]]; then
  echo "Missing $ENV_FILE. Copy poc.env.example to poc.env and edit it."
  exit 1
fi
# shellcheck disable=SC1090
source "$ENV_FILE"
for v in PREFIX LOCATION GITHUB_ORG PLATFORM_REPO GITOPS_REPO EMAIL; do
  if [[ -z "${!v:-}" ]]; then
    echo "Missing required var: $v"
    exit 1
  fi
done
