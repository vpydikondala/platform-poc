apiVersion: cert-manager.io/v1
kind: Certificate
metadata:
  name: backstage-tls
  namespace: ${BACKSTAGE_NAMESPACE}
spec:
  secretName: backstage-tls
  issuerRef:
    name: letsencrypt-http01
    kind: ClusterIssuer
  dnsNames:
    - ${BACKSTAGE_HOST_PREFIX}.${INGRESS_IP}.sslip.io
---
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: backstage
  namespace: ${BACKSTAGE_NAMESPACE}
  annotations:
    cert-manager.io/cluster-issuer: letsencrypt-http01
    nginx.ingress.kubernetes.io/ssl-redirect: "true"
spec:
  ingressClassName: nginx
  tls:
    - hosts: [${BACKSTAGE_HOST_PREFIX}.${INGRESS_IP}.sslip.io]
      secretName: backstage-tls
  rules:
    - host: ${BACKSTAGE_HOST_PREFIX}.${INGRESS_IP}.sslip.io
      http:
        paths:
          - path: /
            pathType: Prefix
            backend:
              service:
                name: ${BACKSTAGE_SERVICE_NAME}
                port: { number: 80 }
