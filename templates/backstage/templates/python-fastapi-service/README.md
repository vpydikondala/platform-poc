# Python FastAPI Golden Path

This directory defines a **complete golden path** for building and deploying
Python FastAPI services to AKS using Argo CD GitOps.

---

## Components of the golden path

### 1) `template.yaml`
Defines:
- UI fields shown in Backstage
- Validation rules
- Scaffolder steps:
  - render service repo
  - create GitHub repo
  - render GitOps manifests
  - open PR into env-gitops
  - register service in catalog

---

### 2) `skeleton-service/`
This becomes the **actual service repository**.

Includes:
- Application code
- Helm chart
- CI workflows
- TechDocs
- Catalog registration

---

### 3) `skeleton-gitops/`
This becomes content committed into `env-gitops`.

Includes:
- Argo CD Application definitions
- Environment-specific values (dev/prod)

---

## Why this structure?

It cleanly separates:
- **Service concerns** → service repo
- **Runtime state** → env-gitops
- **Platform logic** → platform-poc

This is a foundational GitOps pattern used by mature platform teams.

