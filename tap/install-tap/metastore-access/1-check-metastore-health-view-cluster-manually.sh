## https://docs.vmware.com/en/VMware-Tanzu-Application-Platform/1.3/tap/GUID-cli-plugins-insight-cli-configuration.html
#!/bin/bash
SCRIPTDIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
source $SCRIPTDIR/../common-scripts/common.sh
load_env_file $SCRIPTDIR/../tap-env

echo "This script should run on VIEW cluster"
echo "PREREQUISITES: tanzu insight plugin should be installed."

kubectl get secret ingress-cert -n metadata-store -o json | jq -r '.data."ca.crt"' | base64 -d > /tmp/insight-ca.crt
echo "metadata-store ca.crt created in /tmp/insight-ca.crt"

tanzu insight config set-target https://metadata-store.${TAP_DOMAIN} --ca-cert /tmp/insight-ca.crt

export METADATA_STORE_ACCESS_TOKEN=$(kubectl get secrets metadata-store-read-write-client -n metadata-store -o jsonpath="{.data.token}" | base64 -d)
tanzu insight health
