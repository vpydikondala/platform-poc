#!/usr/bin/env bash
set -euo pipefail

# Default values (can be overridden via env)
: "${BACKSTAGE_NAMESPACE:=platform}"
: "${BACKSTAGE_SERVICE_NAME:=backstage}"
: "${BACKSTAGE_HOST_PREFIX:=backstage}"
: "${ARGOCD_HOST_PREFIX:=argocd}"
: "${TECHDOCS_CONTAINER:=techdocs}"

# Load environment variables from poc.env
bash ./scripts/load_env.sh poc.env

# Ensure INGRESS_IP is set
if [[ -z "${INGRESS_IP:-}" ]]; then
  echo "INGRESS_IP is not set. Exiting."
  exit 1
fi

# Render Helm values for Backstage
mkdir -p rendered/backstage
envsubst < templates/backstage/backstage-values.yaml.tpl > rendered/backstage/backstage-values.yaml

# Deploy Backstage via Helm
helm upgrade --install backstage ./charts/backstage \
  -n "${BACKSTAGE_NAMESPACE}" \
  -f rendered/backstage/backstage-values.yaml

# Wait for rollout to complete
kubectl -n "${BACKSTAGE_NAMESPACE}" rollout status deploy/backstage --timeout=300s

# Print access URL
echo "Backstage deployed at: https://${BACKSTAGE_HOST_PREFIX}.${INGRESS_IP}.sslip.io"
