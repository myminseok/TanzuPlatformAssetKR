## https://docs.vmware.com/en/VMware-Tanzu-Application-Platform/1.6/tap/tap-gui-cluster-view-setup.html
## https://docs.vmware.com/en/VMware-Tanzu-Application-Platform/1.5/tap/tap-gui-cluster-view-setup.html
#!/bin/bash
SCRIPTDIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
source $SCRIPTDIR/../common-scripts/common.sh
load_env_file $SCRIPTDIR/../tap-env

echo "This script should run on ALL cluster"

kubectl apply -f $SCRIPTDIR/tap-gui-viewer-service-account-rbac.yml

kubectl apply -f $SCRIPTDIR/tap-gui-viewer-sa-secret.yml


CLUSTER_URL=$(kubectl config view --minify -o jsonpath='{.clusters[0].cluster.server}')

CLUSTER_TOKEN=$(kubectl -n tap-gui get secret tap-gui-viewer -o=json \
| jq -r '.data["token"]' \
| base64 --decode)

CLUSTER_CA_CERTIFICATES=$(kubectl config view --raw -o jsonpath='{.clusters[?(@.name=="tkc-run")].cluster.certificate-authority-data}')

echo "---------------------------------------------------------------------------------------"
echo "[MANUAL]: Manully update tap-values file on VIEW cluster( Not Required on FULL Cluster)"
echo "---------------------------------------------------------------------------------------"
echo "  update file: $TAP_ENV_DIR/tap-values-view-2nd-overlay-TEMPLATE.yml"
echo "  > tap_gui.app_config.kubernetes.clusterLocatorMethods"
echo ""
echo "  and run multi-view-cluster/23-update-tap.sh"
echo ""
CURRENT_CONTEXT=$(kubectl config current-context)
echo CONTEXT: $CURRENT_CONTEXT
echo CLUSTER_URL: $CLUSTER_URL
echo "CLUSTER_TOKEN will not be changed even if running this script multiple times"
echo CLUSTER_TOKEN: $CLUSTER_TOKEN
echo CLUSTER_CA_CERTIFICATES: $CLUSTER_CA_CERTIFICATES