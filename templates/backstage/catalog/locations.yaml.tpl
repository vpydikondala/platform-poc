apiVersion: backstage.io/v1alpha1
kind: Location
metadata:
  name: platform-templates
spec:
  type: url
  targets:
    - https://github.com/${GITHUB_ORG}/${PLATFORM_REPO}/blob/main/templates/backstage/templates/python-fastapi-service/template.yaml
