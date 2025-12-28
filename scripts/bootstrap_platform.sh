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
echo "Installing cert-manager..."

helm repo add jetstack https://charts.jetstack.io
helm repo update

# Always ensure the namespace exists
kubectl create namespace cert-manager --dry-run=client -o yaml | kubectl apply -f -

# Install cert-manager + CRDs
helm upgrade --install cert-manager jetstack/cert-manager \
  --namespace cert-manager \
  --set installCRDs=true

echo "Waiting for cert-manager deployments..."
kubectl -n cert-manager rollout status deploy/cert-manager --timeout=180s
kubectl -n cert-manager rollout status deploy/cert-manager-webhook --timeout=180s
kubectl -n cert-manager rollout status deploy/cert-manager-cainjector --timeout=180s

echo "cert-manager installed and ready."

# Install Argo CD
helm repo add argo https://argoproj.github.io/argo-helm
helm repo update

helm upgrade --install argocd argo/argo-cd \
  --namespace "${ARGOCD_NAMESPACE}" \
  --create-namespace

echo "Base platform components installed."
