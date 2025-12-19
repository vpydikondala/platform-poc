# Backstage Helm Chart (platform-poc)

This Helm chart deploys **Backstage** into AKS as part of the Internal Developer Platform.

It is intentionally **simple and opinionated** for this PoC, focusing on:
- GitHub-based scaffolding
- Argo CD integration
- TechDocs publishing
- Azure-native managed services

---

## What this chart deploys

### Kubernetes resources
- Deployment (`Deployment`)
- Service (`ClusterIP`)
- ServiceAccount (with Azure Workload Identity)
- ConfigMap (Backstage app-config)
- Secret (runtime secrets via env vars)

Ingress and TLS are handled **outside** this chart (via templates + cert-manager).

---

## Key design decisions

### 1) Externalized ingress
Ingress is managed separately so that:
- TLS (cert-manager) is consistent across all apps
- Hostnames are generated dynamically using ingress IP (`sslip.io`)
- The chart stays environment-agnostic

### 2) Azure Workload Identity
Backstage runs with a **User Assigned Managed Identity**, allowing it to:
- Write TechDocs to Azure Blob Storage
- Read secrets from Azure Key Vault (future-ready)

No Kubernetes secrets are required for Azure auth.

---

## Values overview (`values.yaml`)

### Image
```yaml
image:
  repository: ghcr.io/your-org/backstage
  tag: latest

Note: Use a prebuilt Backstage image. For production, pin to a specific tag.

##Service Account
serviceAccount:
  name: backstage-sa
  azureClientId: <managed-identity-client-id>
Note: This enables Azure Workload Identity.

##Environment variables
env:
  BACKSTAGE_HOST
  ARGOCD_URL
  GITHUB_ORG
  GITHUB_TOKEN
  TECHDOCS_STORAGE_ACCOUNT
  TECHDOCS_CONTAINER
  POSTGRES_HOST
  POSTGRES_USER
  POSTGRES_PASSWORD
  POSTGRES_DB

Note: All values are injected via Helm values rendered from templates.

##app-config.production.yaml
Mounted as:

/app/app-config.production.yaml

###
Configured features:

GitHub discovery provider

Backstage Scaffolder

TechDocs (Azure Blob publisher)

Argo CD plugin

PostgreSQL database (managed Azure Postgres)

##How this chart is deployed

This chart is not installed manually.

It is installed automatically by:

GitHub Actions workflow:
02 - Bootstrap Platform

Script:
scripts/deploy_backstage.sh

##How to validate
kubectl -n platform get pods
kubectl -n platform get svc backstage
kubectl -n platform logs deploy/backstage

Expected URL: https://backstage.<INGRESS_IP>.sslip.io

##Aditional notes for production
Production considerations (out of scope for PoC)

Use GitHub App instead of PAT

Enable Azure AD authentication

Run multiple replicas

Add resource requests/limits

Move secrets fully to Key Vault



