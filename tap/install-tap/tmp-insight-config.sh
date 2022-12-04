##https://docs.vmware.com/en/VMware-Tanzu-Application-Platform/1.3/tap/GUID-cli-plugins-insight-cli-configuration.html

#!/bin/bash -e
# This script only works on mac

# Update local hosts file
METADATA_STORE_IP=$(kubectl get svc metadata-store-app -n metadata-store -o jsonpath="{.status.loadBalancer.ingress[0].ip}")
# delete any previously added entry for meta data store
sudo sed -i '/metadata-store-app/d' /etc/hosts
echo "$METADATA_STORE_IP metadata-store-app" | sudo tee -a /etc/hosts > /dev/null

METADATA_STORE_ACCESS_TOKEN=$(kubectl get secrets -n metadata-store -o jsonpath="{.items[?(@.metadata.annotations['kubernetes\.io/service-account\.name']=='metadata-store-read-write-client')].data.token}" | base64 -d)
echo $METADATA_STORE_ACCESS_TOKEN
kubectl get secret -n metadata-store app-tls-cert -o jsonpath='{.data.ca\.crt}' | base64 -d > metadata-app-tls-cert.ca
# configure insight
insight config set-target https://metadata-store-app:8443 --ca-cert ./metadata-app-tls-cert.ca  --access-token $METADATA_STORE_ACCESS_TOKEN
rm -rf ./metadata-app-tls-cert.ca
insight health
