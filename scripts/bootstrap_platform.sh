#!/usr/bin/env bash
set -euo pipefail

# Load PoC config and export variables for child processes
bash ./scripts/load_env.sh poc.env

# Defaults (avoid "unbound variable" issues)
: "${ARGOCD_NAMESPACE:=argocd}"
: "${BACKSTAGE_NAMESPACE:=platform}"
: "${ARGOCD_RELEASE:=argocd}"

# Render templates (envsubst)
bash ./scripts/render.sh templates rendered

# Namespaces (idempotent)
kubectl create ns ingress-nginx --dry-run=client -o yaml | kubectl apply -f -
kubectl create ns cert-manager  --dry-run=client -o yaml | kubectl apply -f -
kubectl create ns "${ARGOCD_NAMESPACE}"    --dry-run=client -o yaml | kubectl apply -f -
kubectl create ns "${BACKSTAGE_NAMESPACE}" --dry-run=client -o yaml | kubectl apply -f -
kubectl create ns apps-dev  --dry-run=client -o yaml | kubectl apply -f -
kubectl create ns apps-prod --dry-run=client -o yaml | kubectl apply -f -

# -------------------------
# Install/upgrade ingress-nginx
# -------------------------
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
helm repo update

helm upgrade --install ingress-nginx ingress-nginx/ingress-nginx \
  -n ingress-nginx \
  -f rendered/helm-values/ingress-nginx.yaml \
  --wait --timeout 10m

# -------------------------
# Install/upgrade cert-manager (SSA-safe conflict recovery)
# -------------------------
helm repo add jetstack https://charts.jetstack.io
helm repo update

echo "Installing/upgrading cert-manager (SSA)..."
set +e
helm upgrade --install cert-manager jetstack/cert-manager \
  -n cert-manager \
  -f rendered/helm-values/cert-manager.yaml \
  --set crds.enabled=true \
  --wait --timeout 10m \
  --rollback-on-failure \
  --force-conflicts
CM_RC=$?
set -e

if [[ $CM_RC -ne 0 ]]; then
  echo "cert-manager install failed; attempting cleanup of webhook configurations and retrying..."
  kubectl delete validatingwebhookconfiguration cert-manager-webhook --ignore-not-found=true
  kubectl delete mutatingwebhookconfiguration cert-manager-webhook --ignore-not-found=true

  helm upgrade --install cert-manager jetstack/cert-manager \
    -n cert-manager \
    -f rendered/helm-values/cert-manager.yaml \
    --set crds.enabled=true \
    --wait --timeout 10m \
    --rollback-on-failure \
    --force-conflicts
fi

# ClusterIssuer (Let's Encrypt) - required for TLS
kubectl apply -f rendered/k8s/clusterissuer.yaml

# -------------------------
# Install/upgrade Argo CD
# -------------------------
helm repo add argo https://argoproj.github.io/argo-helm
helm repo update

helm upgrade --install "${ARGOCD_RELEASE}" argo/argo-cd \
  -n "${ARGOCD_NAMESPACE}" \
  -f rendered/helm-values/argocd.yaml \
  --wait --timeout 15m

echo "Installed ingress-nginx, cert-manager, ClusterIssuer, Argo CD."
