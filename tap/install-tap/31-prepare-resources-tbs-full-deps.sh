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

## make sure tap-registry is in place. otherwise tanzu package repository add full-deps-package-repo will be failed.
# tanzu secret registry add tap-registry \
#     --server   $INSTALL_REGISTRY_HOSTNAME \
#     --username $INSTALL_REGISTRY_USERNAME \
#     --password $INSTALL_REGISTRY_PASSWORD \
#     --namespace tap-install \
#     --export-to-all-namespaces \
#     --yes

set +e
 kubectl get secretexports -A | grep tap-registry
set -e



set +e
tanzu package repository delete full-deps-package-repo -n tap-install -y
set -e

if [ -z $TAP_VERSION ]; then
  TAP_VERSION=$(tanzu package available list buildservice.tanzu.vmware.com --namespace tap-install -o json | jq -r '.[] | select(.name=="buildservice.tanzu.vmware.com") | .version')
  if [ "x$TAP_VERSION" == "x" ]; then
    echo "ERROR no buildservice.tanzu.vmware.com found"
    exit 1
  fi
fi
echo "Creating package repository add full-deps-package-repo for buildservice.tanzu.vmware.com version:$TAP_VERSION"

url=${IMGPKG_REGISTRY_HOSTNAME}/${IMGPKG_REPO}/full-deps-package-repo:$TAP_VERSION

tanzu package repository add full-deps-package-repo \
  --url $url -n tap-install


tanzu package repository list -A 