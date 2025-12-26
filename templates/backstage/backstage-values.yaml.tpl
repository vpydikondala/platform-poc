image:
  repository: ${ACR_NAME}.azurecr.io/backstage
  tag: latest
  pullPolicy: Always

serviceAccount:
  name: backstage-sa
  azureClientId: ${BACKSTAGE_MI_CLIENT_ID}

env:
  # URLs
  BACKSTAGE_HOST: ${BACKSTAGE_HOST_PREFIX}.${INGRESS_IP}.sslip.io
  ARGOCD_URL: https://${ARGOCD_HOST_PREFIX}.${INGRESS_IP}.sslip.io

  # GitHub integration
  GITHUB_ORG: ${GITHUB_ORG}
  GITHUB_TOKEN: ${BACKSTAGE_GITHUB_TOKEN}

  # TechDocs (Azure Blob)
  TECHDOCS_STORAGE_ACCOUNT: ${STORAGE_ACCOUNT}
  TECHDOCS_CONTAINER: ${TECHDOCS_CONTAINER}
  TECHDOCS_STORAGE_KEY: ${TECHDOCS_STORAGE_KEY}

  # Postgres
  POSTGRES_HOST: ${POSTGRES_HOST}
  POSTGRES_USER: ${POSTGRES_USER}
  POSTGRES_PASSWORD: ${POSTGRES_PASSWORD}
  POSTGRES_DB: ${POSTGRES_DB}

  # Azure Auth (AAD login)
  AZURE_CLIENT_ID: ${AZURE_CLIENT_ID}
  AZURE_TENANT_ID: ${AZURE_TENANT_ID}

  # Backstage
  NODE_ENV: production
