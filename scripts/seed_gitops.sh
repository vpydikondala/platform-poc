#!/usr/bin/env bash
set -euo pipefail
bash ./scripts/load_env.sh poc.env
if [[ ! -d "env-gitops/.git" ]]; then
  echo "Expected env-gitops repo checked out at ./env-gitops"
  exit 1
fi
bash ./scripts/render.sh templates rendered
rsync -a --delete rendered/gitops-seed/ env-gitops/
pushd env-gitops >/dev/null
git config user.email "actions@github.com"
git config user.name "GitHub Actions"
git add .
git commit -m "Seed GitOps baseline (root app + env apps)" || echo "No changes"
git push
popd >/dev/null
kubectl apply -f rendered/gitops-seed/argocd/root-app.yaml
echo "Seeded env-gitops and applied Argo root app."
