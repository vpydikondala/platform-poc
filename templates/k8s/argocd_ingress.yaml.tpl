apiVersion: cert-manager.io/v1
kind: Certificate
metadata:
  name: argocd-tls
  namespace: ${ARGOCD_NAMESPACE}
spec:
  secretName: argocd-tls
  issuerRef:
    name: letsencrypt-http01
    kind: ClusterIssuer
  dnsNames:
    - ${ARGOCD_HOST_PREFIX}.${INGRESS_IP}.sslip.io
---
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: argocd
  namespace: ${ARGOCD_NAMESPACE}
  annotations:
    cert-manager.io/cluster-issuer: letsencrypt-http01
    nginx.ingress.kubernetes.io/ssl-redirect: "true"
spec:
  ingressClassName: nginx
  tls:
    - hosts: [${ARGOCD_HOST_PREFIX}.${INGRESS_IP}.sslip.io]
      secretName: argocd-tls
  rules:
    - host: ${ARGOCD_HOST_PREFIX}.${INGRESS_IP}.sslip.io
      http:
        paths:
          - path: /
            pathType: Prefix
            backend:
              service:
                name: argocd-server
                port: { number: 80 }
