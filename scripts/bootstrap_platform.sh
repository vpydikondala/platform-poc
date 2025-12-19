#!/usr/bin/env bash
set -euo pipefail
./scripts/load_env.sh poc.env
./scripts/render.sh templates rendered
kubectl create ns ingress-nginx --dry-run=client -o yaml | kubectl apply -f -
kubectl create ns cert-manager --dry-run=client -o yaml | kubectl apply -f -
kubectl create ns "${ARGOCD_NAMESPACE}" --dry-run=client -o yaml | kubectl apply -f -
kubectl create ns "${BACKSTAGE_NAMESPACE}" --dry-run=client -o yaml | kubectl apply -f -
kubectl create ns apps-dev --dry-run=client -o yaml | kubectl apply -f -
kubectl create ns apps-prod --dry-run=client -o yaml | kubectl apply -f -

helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
helm repo update
helm upgrade --install ingress-nginx ingress-nginx/ingress-nginx -n ingress-nginx -f rendered/helm-values/ingress-nginx.yaml

helm repo add jetstack https://charts.jetstack.io
helm repo update
helm upgrade --install cert-manager jetstack/cert-manager -n cert-manager -f rendered/helm-values/cert-manager.yaml --set crds.enabled=true

kubectl apply -f rendered/k8s/clusterissuer.yaml

helm repo add argo https://argoproj.github.io/argo-helm
helm repo update
helm upgrade --install "${ARGOCD_RELEASE}" argo/argo-cd -n "${ARGOCD_NAMESPACE}" -f rendered/helm-values/argocd.yaml

echo "Installed ingress-nginx, cert-manager, ClusterIssuer, Argo CD."
