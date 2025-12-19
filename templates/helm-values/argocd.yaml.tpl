server:
  replicas: 1
  service:
    type: ClusterIP
  extraArgs:
    - --insecure
dex:
  enabled: false
