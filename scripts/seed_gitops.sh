#!/usr/bin/env bash
set -euo pipefail

# Always run relative to repo root
REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$REPO_ROOT"

# Ensure envsubst exists (GitHub runner usually has it, but keep it safe)
if ! command -v envsubst >/dev/null 2>&1; then
  echo "envsubst not found. Install gettext-base (recommended in workflow)."
  exit 1
fi

# Use poc.env if present, else fall back to example
ENV_FILE="$REPO_ROOT/poc.env"
if [[ ! -f "$ENV_FILE" ]]; then
  echo "poc.env not found; using poc.env.example"
  ENV_FILE="$REPO_ROOT/poc.env.example"
fi

# Normalize CRLF just in case (safe on Linux)
sed -i 's/\r$//' "$ENV_FILE" || true

# Load and export variables
set -a
# shellcheck disable=SC1090
source "$ENV_FILE"
set +a

# Validate required vars
for v in PREFIX LOCATION GITHUB_ORG PLATFORM_REPO GITOPS_REPO EMAIL; do
  if [[ -z "${!v:-}" ]]; then
    echo "Missing required var: $v (from $ENV_FILE)"
    exit 1
  fi
done

if [[ -z "${GITOPS_TOKEN:-}" ]]; then
  echo "Missing required var: GITOPS_TOKEN (must be passed from workflow env)"
  exit 1
fi

echo "Loaded env from: $ENV_FILE"
echo "GITHUB_ORG=$GITHUB_ORG"
echo "GITOPS_REPO=$GITOPS_REPO"

# Paths to seed templates
ROOT_TPL="$REPO_ROOT/templates/gitops-seed/argocd/root-app.yaml.tpl"
DEV_TPL="$REPO_ROOT/templates/gitops-seed/argocd/apps/apps-dev.yaml.tpl"
PROD_TPL="$REPO_ROOT/templates/gitops-seed/argocd/apps/apps-prod.yaml.tpl"

for f in "$ROOT_TPL" "$DEV_TPL" "$PROD_TPL"; do
  if [[ ! -f "$f" ]]; then
    echo "Missing seed template: $f"
    exit 1
  fi
done

# Clone env-gitops using PAT (avoid pushing to platform repo by mistake)
WORKDIR="$REPO_ROOT/env-gitops"
rm -rf "$WORKDIR"

echo "Cloning https://github.com/${GITHUB_ORG}/${GITOPS_REPO}.git"
git clone "https://${GITOPS_TOKEN}@github.com/${GITHUB_ORG}/${GITOPS_REPO}.git" "$WORKDIR"

cd "$WORKDIR"
git checkout main || git checkout -b main

# Ensure folders exist
mkdir -p argocd/apps apps/dev apps/prod

# Render templates into env-gitops repo
echo "Rendering GitOps seed templates into env-gitops..."
envsubst < "$ROOT_TPL" > "argocd/root-app.yaml"
envsubst < "$DEV_TPL"  > "argocd/apps/apps-dev.yaml"
envsubst < "$PROD_TPL" > "argocd/apps/apps-prod.yaml"

# Keep empty env folders tracked
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
