## Supply Chain Choreographer in Tanzu Application Platform GUI
## https://docs.vmware.com/en/VMware-Tanzu-Application-Platform/1.5/tap/tap-gui-plugins-scc-tap-gui.html
## https://docs.vmware.com/en/VMware-Tanzu-Application-Platform/1.3/tap/GUID-tap-gui-plugins-scc-tap-gui.html#scan
## https://docs.vmware.com/en/VMware-Tanzu-Application-Platform/1.1/tap/GUID-scst-store-create-service-account-access-token.html
#!/bin/bash
SCRIPTDIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
source $SCRIPTDIR/../common-scripts/common.sh
load_env_file $SCRIPTDIR/../tap-env

echo "This script should run on VIEW cluster"


set +e
kubectl create ns "metadata-store"
#kubectl delete -f $SCRIPTDIR/metadata-store-read-client.yml
set -e

## For Kubernetes v1.24 and later, services account secrets are no longer automatically created. This is why the example adds a Secret resource in the earlier YAML.
kubectl apply -f $SCRIPTDIR/metadata-store-read-client.yml
TOKEN=$(kubectl -n metadata-store get secret metadata-store-read-client -o=json \
| jq -r '.data["token"]' \
| base64 --decode)

echo "---------------------------------------------------------------------------------------"
echo "[MANUAL]: apply to following config where it is required to access as readlonly permission."
echo "---------------------------------------------------------------------------------------"
echo ""
echo "metadata-store-read-client token: $TOKEN"