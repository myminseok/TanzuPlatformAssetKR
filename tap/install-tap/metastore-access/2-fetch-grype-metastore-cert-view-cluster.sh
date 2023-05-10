#!/bin/bash
SCRIPTDIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
echo "This script should run on VIEW cluster"

set +e
CA_CERT=$(kubectl get secret -n metadata-store ingress-cert -o json | jq -r ".data.\"ca.crt\"")
set -e
## verify
if [[ "x$CA_CERT" == "x" ]]; then
  echo ""
  echo "  [ERROR] NOT FOUND secret 'ingress-cert'. "
  echo "    kubectl get secret -n metadata-store ingress-cert -o json "
  echo ""
  exit 1
else
  echo "  [OK] secret ingress-cert -n metadata-store is created "
  echo "    kubectl get secret -n metadata-store ingress-cert -o json "
fi

cat <<EOF > /tmp/store_ca.yaml
---
apiVersion: v1
kind: Secret
type: Opaque
metadata:
  name: store-ca-cert
  namespace: metadata-store-secrets
data:
  ca.crt: $CA_CERT
EOF

## https://docs.vmware.com/en/VMware-Tanzu-Application-Platform/1.0/tap/GUID-scst-store-create_service_account_access_token.html
## By default, Supply Chain Security Tools - Store comes with read-write service account installed. This service account is cluster-wide.
set +e
AUTH_TOKEN=$(kubectl get secrets metadata-store-read-write-client -n metadata-store -o jsonpath="{.data.token}" | base64 -d)
set -e
## verify
if [[ "x$AUTH_TOKEN" == "x" ]]; then
  echo ""
  echo ""
  echo "  [ERROR] NOT FOUND secret 'metadata-store-read-write-client' "
  echo "   kubectl get secrets metadata-store-read-write-client -n metadata-store "
  echo "check if TAP is installed successfully"
  echo "   kubectl get app -A"
  exit 1
else
  echo "  [OK] secret 'metadata-store-read-write-client' -n metadata-store found "
  echo "     kubectl get secrets metadata-store-read-write-client -n metadata-store "
fi
echo ""
echo "metadata-store-read-write-client token: $AUTH_TOKEN" 
echo "$AUTH_TOKEN" > /tmp/secret-metadata-store-read-write-client.txt
