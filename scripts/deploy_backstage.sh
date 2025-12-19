#!/usr/bin/env bash
set -euo pipefail
./scripts/load_env.sh poc.env
if [[ -z "${INGRESS_IP:-}" ]]; then
  echo "INGRESS_IP is not set."
  exit 1
fi
helm upgrade --install backstage ./charts/backstage -n "${BACKSTAGE_NAMESPACE}" -f rendered/backstage/backstage-values.yaml
kubectl -n "${BACKSTAGE_NAMESPACE}" rollout status deploy/backstage --timeout=300s
echo "Backstage deployed at: https://${BACKSTAGE_HOST_PREFIX}.${INGRESS_IP}.sslip.io"
