app:
  title: IDP PoC
  baseUrl: https://${BACKSTAGE_HOST}

backend:
  baseUrl: https://${BACKSTAGE_HOST}
  listen:
    port: 7007

auth:
  environment: production
  providers:
    guest: {}

integrations:
  github:
    - host: github.com
      token: ${GITHUB_TOKEN}

catalog:
  rules:
    - allow: [Component, API, Resource, System, Domain, Group, User, Template, Location]
  locations:
    # Remove github-discovery for PoC (requires additional backend module wiring)
    - type: url
      target: https://github.com/${GITHUB_ORG}/${PLATFORM_REPO}/blob/main/templates/backstage/catalog/locations.yaml

techdocs:
  builder: local
  generator:
    runIn: 'local'
  publisher:
    type: azureBlobStorage
    azureBlobStorage:
      containerName: ${TECHDOCS_CONTAINER}
      credentials:
        accountName: ${TECHDOCS_STORAGE_ACCOUNT}
        accountKey: ${TECHDOCS_STORAGE_KEY}

argocd:
  appLocatorMethods:
    - type: config
      instances:
        - name: argo
          url: ${ARGOCD_URL}
