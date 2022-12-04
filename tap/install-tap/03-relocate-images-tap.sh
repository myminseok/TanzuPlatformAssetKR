#!/bin/bash
SCRIPTDIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
source $SCRIPTDIR/common-scripts/common.sh
load_env_file $SCRIPTDIR/tap-env

echo ""
echo "PREREQUSITE: docker login registry.tanzu.vmware.com"
echo "PREREQUSITE: docker login $IMGPKG_REGISTRY_HOSTNAME"
echo ""
echo "create repo: $IMGPKG_REGISTRY_HOSTNAME/$IMGPKG_REPO as PUBLIC"


if [ -z $IMGPKG_REGISTRY_CA_CERTIFICATE ]; then
  echo "ERROR: ENV `IMGPKG_REGISTRY_CA_CERTIFICATE` not found"
  exit 1
fi

IMGPKG_REGISTRY_HOSTNAME="infra-harbor2.lab.pcfdemo.net"
IMGPKG_REPO="tap"

REGISTRY_CA_PATH="/tmp/imgpkg_registry_ca.crt"
echo $IMGPKG_REGISTRY_CA_CERTIFICATE | base64 -d > $REGISTRY_CA_PATH
echo " CA file created $REGISTRY_CA_PATH"

set -x

imgpkg copy -b registry.tanzu.vmware.com/tanzu-application-platform/tap-packages:${TAP_VERSION} \
--to-repo ${IMGPKG_REGISTRY_HOSTNAME}/${IMGPKG_REPO}/tap-packages \
--include-non-distributable-layers \
--registry-ca-cert-path $REGISTRY_CA_PATH