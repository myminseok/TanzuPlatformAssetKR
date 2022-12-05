#!/bin/bash
SCRIPTDIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
source $SCRIPTDIR/common-scripts/common.sh
load_env_file $SCRIPTDIR/tap-env

verify_tap_env_param "IMGPKG_REGISTRY_HOSTNAME", "$IMGPKG_REGISTRY_HOSTNAME"
verify_tap_env_param "IMGPKG_REPO", "$IMGPKG_REPO"
verify_tap_env_param "IMGPKG_REGISTRY_USERNAME", "$IMGPKG_REGISTRY_USERNAME"
verify_tap_env_param "IMGPKG_REGISTRY_PASSWORD", "$IMGPKG_REGISTRY_PASSWORD"
verify_tap_env_param "TAP_VERSION", "$TAP_VERSION"
verify_tap_env_param "IMGPKG_REGISTRY_CA_CERTIFICATE", "$IMGPKG_REGISTRY_CA_CERTIFICATE"


echo ""
echo "PREREQUSITE: docker login registry.tanzu.vmware.com"
echo "PREREQUSITE: docker login $IMGPKG_REGISTRY_HOSTNAME"
echo "PREREQUSITE create repo  $IMGPKG_REGISTRY_HOSTNAME/$IMGPKG_REPO as PUBLIC"


REGISTRY_CA_PATH="/tmp/imgpkg_registry_ca.crt"
rm -rf $REGISTRY_CA_PATH
echo "$IMGPKG_REGISTRY_CA_CERTIFICATE" | base64 -d > $REGISTRY_CA_PATH
echo "IMGPKG_REGISTRY_CA_CERTIFICATE CA file created $REGISTRY_CA_PATH"
set -x

imgpkg copy -b registry.tanzu.vmware.com/tanzu-application-platform/tap-packages:${TAP_VERSION} \
--to-repo ${IMGPKG_REGISTRY_HOSTNAME}/${IMGPKG_REPO}/tap-packages \
--include-non-distributable-layers \
--registry-ca-cert-path $REGISTRY_CA_PATH