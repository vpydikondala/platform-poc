#!/usr/bin/env bash
set -euo pipefail

bash ./scripts/load_env.sh poc.env

if [[ -z "${INGRESS_IP:-}" ]]; then
  echo "INGRESS_IP is not set. Export INGRESS_IP before running."
  exit 1
fi

# ---- cert-manager guard: fail fast with a clear message ----
if ! kubectl get crd certificates.cert-manager.io >/dev/null 2>&1; then
  echo "ERROR: cert-manager CRDs not installed (certificates.cert-manager.io missing)."
  echo "Run scripts/bootstrap_platform.sh (cert-manager install) first."
  exit 1
fi
# -----------------------------------------------------------

bash ./scripts/render.sh templates rendered

kubectl apply -f rendered/k8s/argocd_ingress.yaml
kubectl apply -f rendered/k8s/backstage_ingress.yaml

echo "Applied Argo CD and Backstage ingresses/certs."
