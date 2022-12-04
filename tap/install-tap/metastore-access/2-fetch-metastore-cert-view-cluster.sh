echo "Should run on VIEW cluster"

CA_CERT=$(kubectl get secret -n metadata-store ingress-cert -o json | jq -r ".data.\"ca.crt\"")

## verify
if [[ "x$CA_CERT" == "x" ]]; then
  echo ""
  echo "!! ERROR: ingress-cert is invalid. "
  echo "!! ERROR: kubectl get secret -n metadata-store ingress-cert -o json "
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
  echo "!! ERROR: metadata-store-read-write-client is invalid. "
  echo "!! ERROR: kubectl get secrets metadata-store-read-write-client -n metadata-store "
  echo ""
  exit 1
fi
echo "$AUTH_TOKEN" > /tmp/secret-metadata-store-read-write-client.txt
cat /tmp/secret-metadata-store-read-write-client.txt
