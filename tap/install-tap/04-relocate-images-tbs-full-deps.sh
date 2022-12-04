## https://docs.vmware.com/en/VMware-Tanzu-Application-Platform/1.3/tap/GUID-tbs-offline-install-deps.html
## 9.6GB
#!/bin/bash
SCRIPTDIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
source $SCRIPTDIR/common-scripts/common.sh
load_env_file $SCRIPTDIR/tap-env

set -e;


#VERSION=1.7.2
VERSION=$(tanzu package available list buildservice.tanzu.vmware.com --namespace tap-install -o json | jq -r '.[] | select(.name=="buildservice.tanzu.vmware.com") | .version')
if [ "$VERSION" == "" ]; then
  echo "ERROR no buildservice.tanzu.vmware.com found"
  exit 1
fi
echo $VERSION


if [ -z $IMGPKG_REGISTRY_CA_CERTIFICATE ]; then
  echo "ERROR: ENV `IMGPKG_REGISTRY_CA_CERTIFICATE` not found"
  exit 1
fi

set -x

REGISTRY_CA_PATH="/tmp/imgpkg_registry_ca.crt"
echo $IMGPKG_REGISTRY_CA_CERTIFICATE | base64 -d > $REGISTRY_CA_PATH
echo "CA file created $REGISTRY_CA_PATH"

imgpkg copy -b registry.tanzu.vmware.com/tanzu-application-platform/full-tbs-deps-package-repo:${VERSION} \
--to-repo ${IMGPKG_REGISTRY_HOSTNAME}/${IMGPKG_REPO}/tbs-full-deps \
--registry-ca-cert-path $REGISTRY_CA_PATH


