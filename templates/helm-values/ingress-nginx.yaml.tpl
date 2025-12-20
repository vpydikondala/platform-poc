controller:
  replicaCount: 1
  service:
    type: LoadBalancer
    annotations:
      # Force Standard LB health probes to TCP so they don't fail on HTTP 404s.
      # This prevents the LB from marking backends unhealthy and timing out on the public IP.
      service.beta.kubernetes.io/port_80_health-probe_protocol: "Tcp"
      service.beta.kubernetes.io/port_443_health-probe_protocol: "Tcp"

