# Backstage templates (platform-poc)

This directory configures Backstage itself and defines **developer golden paths**.

---

## Contents

backstage/
├─ app-config.production.yaml.tpl # Backstage runtime config
├─ backstage-values.yaml.tpl # Helm values for Backstage
├─ catalog/
│ └─ locations.yaml.tpl # Registers templates in Backstage catalog
└─ templates/
└─ python-fastapi-service/ # Golden path service template


---

## app-config.production.yaml.tpl

Defines:
- GitHub integration
- Catalog discovery
- TechDocs publisher (Azure Blob)
- Argo CD plugin configuration
- PostgreSQL database

This file is rendered and mounted into the Backstage pod.

---

## catalog/locations.yaml.tpl

Registers:
- Scaffolder templates
- Additional catalog locations

Without this file, templates would not appear in Backstage UI.

---

## Scaffolder templates

Located under: templates/python-fastapi-service/


These define:
- UI form shown to developers
- Actions to create repos
- Actions to open PRs to env-gitops
- Catalog registration

This is the **core self-service experience**.

---

## Extending golden paths

To add another golden path:
1. Copy `python-fastapi-service/`
2. Adjust the skeleton + template.yaml
3. Add the new template to `locations.yaml.tpl`
4. Redeploy Backstage

Examples:
- Node.js service
- Java Spring Boot service
- Terraform module
- CronJob / batch job


