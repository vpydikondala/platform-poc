#!/usr/bin/env bash
set -euo pipefail

# Always run relative to repo root (this script lives in scripts/)
REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$REPO_ROOT"

# Choose env file
ENV_FILE="$REPO_ROOT/poc.env"
if [[ ! -f "$ENV_FILE" ]]; then
  echo "poc.env not found; using poc.env.example"
  ENV_FILE="$REPO_ROOT/poc.env.example"
fi

# Normalize line endings if file was created on Windows (safe no-op on Linux)
# This prevents subtle 'source' issues due to CRLF
sed -i 's/\r$//' "$ENV_FILE" || true

# Load + export variables (do NOT rely on load_env.sh exporting)
set -a
# shellcheck disable=SC1090
source "$ENV_FILE"
set +a

# Validate required core vars
for v in PREFIX LOCATION GITHUB_ORG PLATFORM_REPO GITOPS_REPO EMAIL; do
  if [[ -z "${!v:-}" ]]; then
    echo "Missing required var: $v (from $ENV_FILE)"
    echo "DEBUG: Showing lines containing $v:"
    grep -n "^${v}=" "$ENV_FILE" || true
    exit 1
  fi
done

# Validate token passed from workflow
if [[ -z "${GITOPS_TOKEN:-}" ]]; then
  echo "Missing required var: GITOPS_TOKEN (must be passed from workflow env)"
  exit 1
fi

echo "Loaded env from: $ENV_FILE"
echo "GITHUB_ORG=$GITHUB_ORG"
echo "GITOPS_REPO=$GITOPS_REPO"

# Render templates
bash "$REPO_ROOT/scripts/render.sh" "$REPO_ROOT/templates" "$REPO_ROOT/rendered"

WORKDIR="$REPO_ROOT/env-gitops"
rm -rf "$WORKDIR"

echo "Cloning https://github.com/${GITHUB_ORG}/${GITOPS_REPO}.git"
git clone "https://${GITOPS_TOKEN}@github.com/${GITHUB_ORG}/${GITOPS_REPO}.git" "$WORKDIR"

cd "$WORKDIR"
git checkout main || git checkout -b main

mkdir -p argocd/apps apps/dev apps/prod

# Copy rendered baseline files into env-gitops repo
cp -f "$REPO_ROOT/rendered/env-gitops/argocd/root-app.yaml" "argocd/root-app.yaml"
cp -f "$REPO_ROOT/rendered/env-gitops/argocd/apps/apps-dev.yaml" "argocd/apps/apps-dev.yaml"
cp -f "$REPO_ROOT/rendered/env-gitops/argocd/apps/apps-prod.yaml" "argocd/apps/apps-prod.yaml"

touch apps/dev/.gitkeep apps/prod/.gitkeep

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
