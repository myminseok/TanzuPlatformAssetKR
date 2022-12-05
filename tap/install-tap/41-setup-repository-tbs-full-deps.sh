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

tanzu package repository delete tbs-full-deps-repository -n tap-install -y
tanzu package repository add tbs-full-deps-repository \
  --url ${IMGPKG_REGISTRY_HOSTNAME}/${IMGPKG_REPO}/tbs-full-deps -n tap-install