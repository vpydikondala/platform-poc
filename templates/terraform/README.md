Why not Helm/Terraform directly everywhere?

This PoC intentionally uses simple envsubst templates to:

reduce cognitive load

keep everything readable

avoid complex templating logic

In production, you may:

split Terraform into modules

replace envsubst with Helmfile or Terragrunt


---

# 8) `templates/terraform/README.md`

```md
# Terraform templates (Azure infrastructure)

These Terraform templates provision all Azure infrastructure required by the platform.

---

## What is created

- Resource Group
- AKS cluster (2 nodes)
- Azure Container Registry (ACR)
- Azure Storage Account + Blob Container (TechDocs)
- Azure Key Vault
- User Assigned Managed Identity (Backstage)
- Azure PostgreSQL Flexible Server + database

---

## Why templates instead of modules?

For this PoC:
- Everything lives in a single file for clarity
- Easier to audit and understand end-to-end

For production:
- Split into modules
- Add remote state backend
- Add policy-as-code (OPA/Azure Policy)

---

## How it is executed

Terraform is executed **only** by GitHub Actions:
- Workflow: `01 - Infra Apply (Terraform)`

Local runs are intentionally discouraged to ensure consistency.

---

## Outputs

Terraform outputs are captured and passed to later workflows:
- AKS name
- ACR name
- Storage account
- Managed identity client ID
- Postgres connection info

These outputs drive Backstage and Argo CD configuration.

