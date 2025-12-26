#!/usr/bin/env bash
set -euo pipefail

# Load base env (NO ingress dependency here)
bash ./scripts/load_env.sh poc.env

: "${BACKSTAGE_NAMESPACE:=platform}"
: "${ARGOCD_NAMESPACE:=argocd}"

echo "Installing platform base components..."

# Install ingress-nginx
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
helm repo update

helm upgrade --install ingress-nginx ingress-nginx/ingress-nginx \
  --namespace ingress-nginx \
  --create-namespace

# Install cert-manager
echo "Checking cert-manager..."

if kubectl get validatingwebhookconfiguration webhook.cert-manager.io >/dev/null 2>&1; then
  echo "cert-manager webhook already exists (AKS managed). Skipping install."
else
  echo "WARNING: cert-manager webhook not found. TLS may not work."
fi


# Install Argo CD
helm repo add argo https://argoproj.github.io/argo-helm
helm repo update

helm upgrade --install argocd argo/argo-cd \
  --namespace "${ARGOCD_NAMESPACE}" \
  --create-namespace

echo "Base platform components installed."
