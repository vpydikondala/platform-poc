#!/usr/bin/env bash
set -euo pipefail
./scripts/load_env.sh poc.env
RG="${PREFIX}-rg"
AKS="${PREFIX}-aks"
az aks get-credentials -g "$RG" -n "$AKS" --overwrite-existing
kubectl get nodes
