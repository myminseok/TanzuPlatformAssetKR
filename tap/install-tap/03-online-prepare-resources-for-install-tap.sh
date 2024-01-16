#!/bin/bash
SCRIPTDIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
source $SCRIPTDIR/common-scripts/common.sh
load_env_file $SCRIPTDIR/tap-env


verify_tap_env_param "TAP_VERSION", "$TAP_VERSION"
verify_tap_env_param "INSTALL_REGISTRY_USERNAME", "$INSTALL_REGISTRY_USERNAME"
verify_tap_env_param "INSTALL_REGISTRY_PASSWORD", "$INSTALL_REGISTRY_PASSWORD"

echo "==============================================================="
echo "[MANUAL] PREREQUSITE "
echo "---------------------------------------------------------------"
echo "PREREQUSITE: please make sure the value of INSTALL_REGISTRY_USERNAME: $INSTALL_REGISTRY_USERNAME and secret for registry.tanzu.vmware.com in tap-env file"


print_current_k8s

parse_args "$@"
if [ "$YES" != "y" ]; then
 confirm_target_k8s
fi

set +e
kubectl create ns tap-install
set -e
set -x

if [ "$1" == "-d" ]; then
set +e
  tanzu package repository delete  tanzu-tap-repository --namespace tap-install -y 
  tanzu secret registry delete tap-registry -n tap-install -y 
  tanzu secret registry delete registry-credentials -n tap-install -y
set -e
fi

tanzu secret registry add tap-registry \
    --server   $INSTALL_REGISTRY_HOSTNAME \
    --username $INSTALL_REGISTRY_USERNAME \
    --password $INSTALL_REGISTRY_PASSWORD \
    --namespace tap-install \
    --export-to-all-namespaces \
    --yes
set +e
 kubectl get secretexports -A | grep tap-registry
set -e


## https://docs.vmware.com/en/VMware-Tanzu-Application-Platform/1.5/tap/install-offline-profile.html
tanzu secret registry add registry-credentials \
--server $BUILDSERVICE_REGISTRY_HOSTNAME  \
--username $BUILDSERVICE_REGISTRY_USERNAME \
--password $BUILDSERVICE_REGISTRY_PASSWORD \
--namespace tap-install \
--export-to-all-namespaces --yes

set +e
 kubectl get secretexports -A | grep registry-credentials
set -e

tanzu package repository add tanzu-tap-repository \
  --url ${INSTALL_REGISTRY_HOSTNAME}/tanzu-application-platform/tap-packages:$TAP_VERSION \
  --namespace tap-install


tanzu package repository get tanzu-tap-repository --namespace tap-install
