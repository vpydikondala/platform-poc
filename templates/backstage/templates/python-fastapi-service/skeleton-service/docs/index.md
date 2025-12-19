# {{ name }}

Python FastAPI service deployed to AKS using Argo CD GitOps.

## Endpoints
- `/`
- `/healthz`

## Deployment model
- Image built via GitHub Actions
- Deployment controlled by GitOps (env-gitops repo)
- Argo CD reconciles desired state automatically
