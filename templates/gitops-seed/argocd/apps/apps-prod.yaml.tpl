apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: apps-prod
  namespace: argocd
spec:
  project: default
  source:
    repoURL: https://github.com/${GITHUB_ORG}/${GITOPS_REPO}.git
    targetRevision: main
    path: apps/prod
    directory: { recurse: true }
  destination:
    server: https://kubernetes.default.svc
    namespace: apps-prod
  syncPolicy:
    automated: { prune: true, selfHeal: true }
