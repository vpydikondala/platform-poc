#!/usr/bin/env bash
set -euo pipefail
./scripts/load_env.sh poc.env
if [[ -z "${INGRESS_IP:-}" ]]; then
  echo "INGRESS_IP is not set. Export INGRESS_IP before running."
  exit 1
fi
./scripts/render.sh templates rendered
kubectl apply -f rendered/k8s/argocd_ingress.yaml
kubectl apply -f rendered/k8s/backstage_ingress.yaml
echo "Applied Argo CD and Backstage ingresses/certs."
