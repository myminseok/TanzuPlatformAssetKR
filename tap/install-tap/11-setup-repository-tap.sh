#!/bin/bash
SCRIPTDIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
source $SCRIPTDIR/common-scripts/common.sh
load_env_file $SCRIPTDIR/tap-env


verify_tap_env_param "IMGPKG_REGISTRY_HOSTNAME", "$IMGPKG_REGISTRY_HOSTNAME"
verify_tap_env_param "IMGPKG_REPO", "$IMGPKG_REPO"
verify_tap_env_param "IMGPKG_REGISTRY_USERNAME", "$IMGPKG_REGISTRY_USERNAME"
verify_tap_env_param "IMGPKG_REGISTRY_PASSWORD", "$IMGPKG_REGISTRY_PASSWORD"
verify_tap_env_param "TAP_VERSION", "$TAP_VERSION"

if [ "$YES" != "y" ]; then
 confirm_target_k8s
fi


set +e
kubectl create ns tap-install
set -e
set -x

if [ "$1" == "-d" ]; then
  tanzu package repository delete  tanzu-tap-repository --namespace tap-install -y -f
  tanzu secret registry delete tap-registry -n tap-install -y 
fi


tanzu secret registry add tap-registry \
    --server   $IMGPKG_REGISTRY_HOSTNAME \
    --username $IMGPKG_REGISTRY_USERNAME \
    --password $IMGPKG_REGISTRY_PASSWORD \
    --namespace tap-install \
    --export-to-all-namespaces \
    --yes

tanzu package repository add tanzu-tap-repository \
  --url ${IMGPKG_REGISTRY_HOSTNAME}/${IMGPKG_REPO}/tap-packages:$TAP_VERSION \
  --namespace tap-install


tanzu package repository get tanzu-tap-repository --namespace tap-install

