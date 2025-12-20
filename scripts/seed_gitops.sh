#!/usr/bin/env bash
set -euo pipefail

# Always run relative to repo root (this script lives in scripts/)
REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$REPO_ROOT"

# Use poc.env if present, else fall back to example
ENV_FILE="$REPO_ROOT/poc.env"
if [[ ! -f "$ENV_FILE" ]]; then
  echo "poc.env not found at repo root; using poc.env.example"
  ENV_FILE="$REPO_ROOT/poc.env.example"
fi

bash "$REPO_ROOT/scripts/load_env.sh" "$ENV_FILE"
bash "$REPO_ROOT/scripts/render.sh" "$REPO_ROOT/templates" "$REPO_ROOT/rendered"

# Hard fail if still missing
: "${GITHUB_ORG:?Missing GITHUB_ORG}"
: "${GITOPS_REPO:?Missing GITOPS_REPO}"
: "${GITOPS_TOKEN:?Missing GITOPS_TOKEN}"

echo "Seeding GitOps repo: ${GITHUB_ORG}/${GITOPS_REPO}"

WORKDIR="$REPO_ROOT/env-gitops"

# Clone env-gitops using PAT (avoid pushing to platform repo by mistake)
rm -rf "$WORKDIR"
git clone "https://${GITOPS_TOKEN}@github.com/${GITHUB_ORG}/${GITOPS_REPO}.git" "$WORKDIR"

cd "$WORKDIR"
git checkout main || git checkout -b main

# Ensure folders exist
mkdir -p argocd/apps apps/dev apps/prod

# Copy rendered baseline files into env-gitops repo
# NOTE: these paths assume your render outputs are here; adjust if needed
cp -f "$REPO_ROOT/rendered/env-gitops/argocd/root-app.yaml" "argocd/root-app.yaml"
cp -f "$REPO_ROOT/rendered/env-gitops/argocd/apps/apps-dev.yaml" "argocd/apps/apps-dev.yaml"
cp -f "$REPO_ROOT/rendered/env-gitops/argocd/apps/apps-prod.yaml" "argocd/apps/apps-prod.yaml"

# Keep empty dirs
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
