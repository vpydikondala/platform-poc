#!/usr/bin/env bash
set -euo pipefail

bash ./scripts/load_env.sh poc.env
bash ./scripts/render.sh templates rendered

: "${GITHUB_ORG:?Missing GITHUB_ORG}"
: "${GITOPS_REPO:?Missing GITOPS_REPO}"
: "${GITOPS_TOKEN:?Missing GITOPS_TOKEN}"

WORKDIR="$(pwd)/env-gitops"

# Fresh clone of env-gitops using token (avoid pushing to platform repo by mistake)
rm -rf "$WORKDIR"
git clone "https://${GITOPS_TOKEN}@github.com/${GITHUB_ORG}/${GITOPS_REPO}.git" "$WORKDIR"

cd "$WORKDIR"
git checkout main || git checkout -b main

# Ensure folders exist
mkdir -p argocd/apps apps/dev apps/prod

# Copy rendered baseline files into env-gitops repo
cp -f ../rendered/env-gitops/argocd/root-app.yaml argocd/root-app.yaml
cp -f ../rendered/env-gitops/argocd/apps/apps-dev.yaml argocd/apps/apps-dev.yaml
cp -f ../rendered/env-gitops/argocd/apps/apps-prod.yaml argocd/apps/apps-prod.yaml

# Add .gitkeep so empty folders persist
touch apps/dev/.gitkeep apps/prod/.gitkeep

# Commit and push
git config user.email "actions@github.com"
git config user.name "github-actions"

git add -A
if git diff --cached --quiet; then
  echo "No GitOps baseline changes to commit."
  exit 0
fi

git commit -m "Seed GitOps baseline (root app + env apps)"
git push origin main

echo "Seeded env-gitops baseline successfully."
