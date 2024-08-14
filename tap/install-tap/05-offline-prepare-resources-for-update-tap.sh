## https://docs.vmware.com/en/VMware-Tanzu-Application-Platform/1.11/tap/install-offline-profile.html

#!/bin/bash
SCRIPTDIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
source $SCRIPTDIR/common-scripts/common.sh
load_env_file $SCRIPTDIR/tap-env

verify_tap_env_param "IMGPKG_REGISTRY_HOSTNAME", "$IMGPKG_REGISTRY_HOSTNAME"
verify_tap_env_param "IMGPKG_REPO", "$IMGPKG_REPO"
verify_tap_env_param "IMGPKG_REGISTRY_USERNAME", "$IMGPKG_REGISTRY_USERNAME"
verify_tap_env_param "IMGPKG_REGISTRY_PASSWORD", "$IMGPKG_REGISTRY_PASSWORD"
verify_tap_env_param "TAP_VERSION", "$TAP_VERSION"

verify_tap_env_param "BUILDSERVICE_REGISTRY_HOSTNAME", "$BUILDSERVICE_REGISTRY_HOSTNAME"
verify_tap_env_param "BUILDSERVICE_REGISTRY_USERNAME", "$BUILDSERVICE_REGISTRY_USERNAME"
verify_tap_env_param "BUILDSERVICE_REGISTRY_PASSWORD", "$BUILDSERVICE_REGISTRY_PASSWORD"

print_current_k8s

parse_args "$@"
if [ "$YES" != "y" ]; then
 confirm_target_k8s
fi

set +e
kubectl create ns tap-install
set -e
set -x

docker login $IMGPKG_REGISTRY_HOSTNAME -u $IMGPKG_REGISTRY_USERNAME -p $IMGPKG_REGISTRY_PASSWORD

if [ "$1" == "-d" ]; then
set +e
  tanzu package repository delete  tanzu-tap-repository --namespace tap-install -y 
  tanzu secret registry delete tap-registry -n tap-install -y 
  tanzu secret registry delete registry-credentials -n tap-install -y
set -e
fi

tanzu secret registry add tap-registry \
    --server   $IMGPKG_REGISTRY_HOSTNAME \
    --username $IMGPKG_REGISTRY_USERNAME \
    --password $IMGPKG_REGISTRY_PASSWORD \
    --namespace tap-install \
    --export-to-all-namespaces \
    --yes
set +e
 kubectl get secretexports -A | grep tap-registry
set -e


## https://docs.vmware.com/en/VMware-Tanzu-Application-Platform/1.5/tap/install-offline-profile.html
tanzu secret registry update registry-credentials \
--username $BUILDSERVICE_REGISTRY_USERNAME \
--password $BUILDSERVICE_REGISTRY_PASSWORD \
--namespace tap-install \
--export-to-all-namespaces --yes


set +e
 kubectl get secretexports -A | grep registry-credentials
set -e

url=${IMGPKG_REGISTRY_HOSTNAME}/${IMGPKG_REPO}/tap-packages:$TAP_VERSION

tanzu package repository update tanzu-tap-repository \
  --url $url \
  --namespace tap-install


tanzu package repository get tanzu-tap-repository --namespace tap-install
