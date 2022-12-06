## Supply Chain Choreographer in Tanzu Application Platform GUI
## https://docs.vmware.com/en/VMware-Tanzu-Application-Platform/1.3/tap/GUID-tap-gui-plugins-scc-tap-gui.html#scan
## https://docs.vmware.com/en/VMware-Tanzu-Application-Platform/1.0/tap/GUID-scst-store-create_service_account_access_token.html
#!/bin/bash
SCRIPTDIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
source $SCRIPTDIR/../common-scripts/common.sh
load_env_file $SCRIPTDIR/../tap-env

kubectl apply -f $SCRIPTDIR/metadata-store-read-client.yml
echo "---------------------------------------------------------------------------------------"
echo "[MANUAL]: Manully copy following info to VIEW cluster"
echo "---------------------------------------------------------------------------------------"
echo "  file: $TAP_ENV_DIR/tap-values-view-2nd-overlay-TEMPLATE.yml"
echo "  > tap_gui.app_config.proxy./metadata-store.headers.Authorization"
echo ""
kubectl get secret $(kubectl get sa -n metadata-store metadata-store-read-client -o json | jq -r '.secrets[0].name') -n metadata-store -o json | jq -r '.data.token' | base64 -d
echo ""
