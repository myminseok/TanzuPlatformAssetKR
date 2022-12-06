#!/bin/bash
SCRIPTDIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
echo "This script should run on VIEW cluster"

CA_CERT=$(kubectl get secret -n metadata-store ingress-cert -o json | jq -r ".data.\"ca.crt\"")

## verify
if [[ "x$CA_CERT" == "x" ]]; then
  echo ""
  echo "ERROR: NOT FOUND secret 'ingress-cert'. "
  echo "  kubectl get secret -n metadata-store ingress-cert -o json "
  echo ""
  exit 1
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
cat /tmp/store_ca.yaml

AUTH_TOKEN=$(kubectl get secrets metadata-store-read-write-client -n metadata-store -o jsonpath="{.data.token}" | base64 -d)
## verify
if [[ "x$AUTH_TOKEN" == "x" ]]; then
  echo ""
  echo ""
  echo "ERROR: NOT FOUND secret 'metadata-store-read-write-client' "
  echo "   kubectl get secrets metadata-store-read-write-client -n metadata-store "
  echo ""
  exit 1
fi
echo "$AUTH_TOKEN" > /tmp/secret-metadata-store-read-write-client.txt
cat /tmp/secret-metadata-store-read-write-client.txt
