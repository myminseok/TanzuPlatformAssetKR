## https://docs.vmware.com/en/VMware-Tanzu-Application-Platform/1.3/tap/GUID-tbs-offline-install-deps.html
#!/bin/bash
SCRIPTDIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
source $SCRIPTDIR/common-scripts/common.sh
load_env_file $SCRIPTDIR/tap-env

print_current_k8s

parse_args "$@"
if [ "$YES" != "y" ]; then
 confirm_target_k8s
fi

set -x

set +e
tanzu package repository delete tbs-full-deps-repository -n tap-install -y
set -e

if [ -z $TAP_VERSION ]; then
  TAP_VERSION=$(tanzu package available list buildservice.tanzu.vmware.com --namespace tap-install -o json | jq -r '.[] | select(.name=="buildservice.tanzu.vmware.com") | .version')
  if [ "x$TAP_VERSION" == "x" ]; then
    echo "ERROR no buildservice.tanzu.vmware.com found"
    exit 1
  fi
fi
echo "Relocating full-tbs-deps-package-repo for buildservice.tanzu.vmware.com version:$TAP_VERSION"


url=${IMGPKG_REGISTRY_HOSTNAME}/$IMGPKG_REGISTRY_OWNER/${IMGPKG_REPO}/tbs-full-deps:$TAP_VERSION
if [ "x$IMGPKG_REGISTRY_OWNER" == "x" ]; then
  url=${IMGPKG_REGISTRY_HOSTNAME}/${IMGPKG_REPO}/tbs-full-deps:$TAP_VERSION
fi

tanzu package repository add tbs-full-deps-repository \
  --url $url -n tap-install
