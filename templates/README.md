
---

# 7) `templates/README.md` (top-level templates folder)

```md
# templates (platform-poc)

This directory contains **all rendered-input templates** used to generate:
- Infrastructure manifests
- Helm values
- Kubernetes resources
- Backstage scaffolder outputs
- GitOps seed data

Templates are rendered using `envsubst` during GitHub Actions workflows.

---

## Template philosophy

- Templates are **parameterized**, not environment-specific
- No secrets are hardcoded
- Rendering happens only in automation (CI/CD)
- The rendered output is never committed back to this repo

---

## Directory layout

templates/
├─ terraform/ # Azure infrastructure (AKS, ACR, KV, Storage, Postgres)
├─ helm-values/ # Helm values for platform components
├─ k8s/ # Raw Kubernetes resources (Ingress, ClusterIssuer)
├─ gitops-seed/ # Initial Argo CD app-of-apps
└─ backstage/ # Backstage configuration + scaffolder templates


---

## How templates are rendered

Rendering is done by:
```bash
scripts/render.sh templates rendered

Inputs:

poc.env

GitHub Actions secrets

Terraform outputs

Output:
rendered/
  terraform/
  helm-values/
  k8s/
  gitops-seed/
  backstage/

The rendered/ directory is ephemeral and safe to delete.

