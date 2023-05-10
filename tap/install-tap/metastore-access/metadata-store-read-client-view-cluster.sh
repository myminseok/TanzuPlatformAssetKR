## Supply Chain Choreographer in Tanzu Application Platform GUI
## https://docs.vmware.com/en/VMware-Tanzu-Application-Platform/1.3/tap/GUID-tap-gui-plugins-scc-tap-gui.html#scan
## https://docs.vmware.com/en/VMware-Tanzu-Application-Platform/1.1/tap/GUID-scst-store-create-service-account-access-token.html
#!/bin/bash
SCRIPTDIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
source $SCRIPTDIR/../common-scripts/common.sh
load_env_file $SCRIPTDIR/../tap-env

echo "This script should run on VIEW cluster"

kubectl apply -f $SCRIPTDIR/metadata-store-read-client.yml

TOKEN=$(kubectl -n metadata-store get secret metadata-store-read-client -o=json \
| jq -r '.data["token"]' \
| base64 --decode)

echo "---------------------------------------------------------------------------------------"
echo "[MANUAL]: Manully update tap-values file on VIEW cluster( Not Required on FULL Cluster)"
echo "---------------------------------------------------------------------------------------"
echo "  update file: $TAP_ENV_DIR/tap-values-view-2nd-overlay-TEMPLATE.yml"
echo "  > tap_gui.app_config.proxy./metadata-store.headers.Authorization"
echo ""
echo "  and run multi-view-cluster/23-update-tap.sh"
echo ""
echo "metadata-store-read-client token: $TOKEN"