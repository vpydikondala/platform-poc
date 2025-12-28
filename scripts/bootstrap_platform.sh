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

# Install cert-manager (only if not already installed)
echo "Checking cert-manager..."

if kubectl get crd certificates.cert-manager.io >/dev/null 2>&1; then
  echo "cert-manager CRDs already present. Assuming cert-manager is installed/managed. Skipping Helm install."
else
  echo "Installing cert-manager via Helm..."
  helm repo add jetstack https://charts.jetstack.io
  helm repo update

  kubectl create namespace cert-manager --dry-run=client -o yaml | kubectl apply -f -

  helm upgrade --install cert-manager jetstack/cert-manager \
    --namespace cert-manager \
    --set installCRDs=true

  echo "cert-manager installed."
fi

# Install Argo CD
helm repo add argo https://argoproj.github.io/argo-helm
helm repo update

helm upgrade --install argocd argo/argo-cd \
  --namespace "${ARGOCD_NAMESPACE}" \
  --create-namespace

echo "Base platform components installed."
