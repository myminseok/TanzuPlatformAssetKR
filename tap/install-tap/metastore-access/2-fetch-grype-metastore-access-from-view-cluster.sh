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

## the read-write token, which is created by default when installing Tanzu Application Platform This service account is cluster-wide.
## https://docs.vmware.com/en/VMware-Tanzu-Application-Platform/1.3/tap/GUID-scst-store-create-service-account.html#create-readwrite-service-account-0
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
echo "---------------------------------------------------------------------------------------"
echo "[MANUAL]: Manully update tap-values file on FULL/ VIEW cluster"
echo "---------------------------------------------------------------------------------------"
echo "  update file: $TAP_ENV_DIR/tap-values-view-2nd-overlay-TEMPLATE.yml"
echo "  > tap_gui.app_config.proxy./metadata-store.headers.Authorization"
echo ""
echo "  and run multi-view-cluster/23-update-tap.sh"
echo ""
echo "metadata-store-read-write-client token: $AUTH_TOKEN" 
echo "$AUTH_TOKEN" > /tmp/secret-metadata-store-read-write-client.txt