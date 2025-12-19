# platform-poc — AKS + Backstage + Argo CD (GitOps) PoC

This repository bootstraps an Internal Developer Platform (IDP) on Azure using:
- **AKS** (Kubernetes)
- **Argo CD** for GitOps deployments
- **Backstage** as the internal developer portal (single pane of glass)
- **NGINX Ingress** for north-south traffic
- **cert-manager + Let’s Encrypt** for TLS certificates
- **Azure Container Registry (ACR)** for container images
- **Azure Storage (Blob)** for TechDocs publishing
- **Azure PostgreSQL Flexible Server (managed)** for Backstage database

It is designed to be:
- **automation-first** (run via GitHub Actions)
- **GitOps-first** (env-gitops is the single source of truth)
- **developer self-service** (Backstage scaffolder creates new services and deploys them)

---

## Repositories in this PoC

### 1) platform-poc (this repo)
Contains:
- Terraform template to provision Azure infrastructure (AKS, ACR, KV, Storage, Postgres)
- Bootstrap scripts for platform components (NGINX Ingress, cert-manager, Argo CD)
- Backstage Helm chart + Backstage scaffolder templates
- GitHub Actions workflows to run everything end-to-end

### 2) env-gitops (separate repo)
Contains:
- Argo CD root application (app-of-apps)
- Environment folders holding desired state for workloads (dev/prod)

---

## High level flow

1. **Terraform provisions infra**
   - AKS, ACR, KV, Storage, Postgres
2. **Bootstrap installs platform components**
   - ingress-nginx + cert-manager + ClusterIssuer
   - Argo CD + ingress + TLS
   - Backstage + ingress + TLS
3. **Seed env-gitops**
   - creates/updates baseline Argo “root app”
   - creates dev/prod app-of-apps
4. **Developers create services in Backstage**
   - Backstage scaffolder generates:
     - a new service repo
     - a PR into env-gitops to deploy it via Argo CD

---

## One ingress IP (important)

This PoC uses **one NGINX ingress controller** with one LoadBalancer service,
so it has **one public IP**.

All applications (Backstage, Argo CD, services) are published using different hostnames
that point to that single IP, e.g.:

- Backstage: `https://backstage.<INGRESS_IP>.sslip.io`
- Argo CD: `https://argocd.<INGRESS_IP>.sslip.io`
- Service dev: `https://orders-api.<INGRESS_IP>.sslip.io`
- Service prod: `https://orders-api-prod.<INGRESS_IP>.sslip.io`

NGINX routes traffic based on hostname.

---

## What you must configure

### GitHub Secrets in platform-poc
Azure OIDC:
- `AZURE_CLIENT_ID`
- `AZURE_TENANT_ID`
- `AZURE_SUBSCRIPTION_ID`

Backstage:
- `BACKSTAGE_GITHUB_TOKEN`  
  (PoC: PAT is fine; production: GitHub App recommended)

GitOps:
- `GITOPS_TOKEN` (write access to env-gitops)

Database:
- `POSTGRES_ADMIN_PASSWORD`

---

## How to run (100% via GitHub Actions)

Run workflows **in order**:

1) **01 - Infra Apply (Terraform)**
- renders Terraform templates
- runs terraform apply
- exports outputs as an artifact for later workflows

2) **02 - Bootstrap Platform**
- installs ingress-nginx + cert-manager + Argo CD
- waits for ingress public IP
- applies ingresses + TLS certs for Argo and Backstage
- deploys Backstage via Helm

3) **03 - Seed env-gitops**
- checks out env-gitops
- writes baseline `root` + app-of-apps definitions
- applies root app into Argo CD

---

## After bootstrap: expected URLs

- Argo CD: `https://argocd.<INGRESS_IP>.sslip.io`
- Backstage: `https://backstage.<INGRESS_IP>.sslip.io`

---

## Troubleshooting quick checks

Ingress IP:
- `kubectl -n ingress-nginx get svc ingress-nginx-controller`

Certificates:
- `kubectl get challenges,orders -A`

Argo apps:
- `kubectl -n argocd get applications`

Backstage:
- `kubectl -n platform get pods,svc,ingress`

---

## Cleanup
Delete the Azure resource group: `${PREFIX}-rg`
