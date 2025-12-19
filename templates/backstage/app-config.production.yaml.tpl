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
    - type: github-discovery
      target: https://github.com/${GITHUB_ORG}/*/blob/main/catalog-info.yaml
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

argocd:
  appLocatorMethods:
    - type: config
      instances:
        - name: argo
          url: ${ARGOCD_URL}
