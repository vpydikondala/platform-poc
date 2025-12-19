#!/usr/bin/env bash
set -euo pipefail
NS="ingress-nginx"
SVC="ingress-nginx-controller"
echo "Waiting for External IP on $NS/$SVC ..."
for i in {1..90}; do
  IP="$(kubectl -n "$NS" get svc "$SVC" -o jsonpath='{.status.loadBalancer.ingress[0].ip}' 2>/dev/null || true)"
  if [[ -n "$IP" ]]; then
    echo "INGRESS_IP=$IP" | tee -a "$GITHUB_ENV"
    echo "Got ingress IP: $IP"
    exit 0
  fi
  sleep 10
done
echo "Timed out waiting for ingress IP"
exit 1
