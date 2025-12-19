apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: apps-dev
  namespace: argocd
spec:
  project: default
  source:
    repoURL: https://github.com/${GITHUB_ORG}/${GITOPS_REPO}.git
    targetRevision: main
    path: apps/dev
    directory: { recurse: true }
  destination:
    server: https://kubernetes.default.svc
    namespace: apps-dev
  syncPolicy:
    automated: { prune: true, selfHeal: true }
