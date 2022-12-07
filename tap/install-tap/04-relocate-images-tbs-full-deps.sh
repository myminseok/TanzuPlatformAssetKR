## https://docs.vmware.com/en/VMware-Tanzu-Application-Platform/1.3/tap/GUID-tbs-offline-install-deps.html
## 9.6GB
#!/bin/bash
SCRIPTDIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
source $SCRIPTDIR/common-scripts/common.sh
load_env_file $SCRIPTDIR/tap-env

set -e

check_executable "imgpkg"

## tanzu package available list buildservice.tanzu.vmware.com --namespace tap-install -o json | jq -r '.[] | select(.name=="buildservice.tanzu.vmware.com") | .version')
VERSION=${1:-1.7.2}

echo "==============================================================="
echo "[MANUAL] Make sure following prerequisites"
echo "---------------------------------------------------------------"
echo "PREREQUSITE: docker login registry.tanzu.vmware.com"
echo "PREREQUSITE: docker login $IMGPKG_REGISTRY_HOSTNAME"
echo "PREREQUSITE create repo  $IMGPKG_REGISTRY_HOSTNAME/$IMGPKG_REPO as PUBLIC"
echo ""
echo "Relocating full-tbs-deps-package-repo for buildservice.tanzu.vmware.com version:$VERSION"

set -x

if [ -z $IMGPKG_REGISTRY_CA_CERTIFICATE ]; then
  imgpkg copy -b registry.tanzu.vmware.com/tanzu-application-platform/full-tbs-deps-package-repo:${VERSION} \
  --to-repo ${IMGPKG_REGISTRY_HOSTNAME}/${IMGPKG_REPO}/tbs-full-deps
else
  REGISTRY_CA_PATH="/tmp/imgpkg_registry_ca.crt"
  echo "Env IMGPKG_REGISTRY_CA_CERTIFICATE detected. Creating CA file to $REGISTRY_CA_PATH"
  echo "$IMGPKG_REGISTRY_CA_CERTIFICATE" | base64 -d > $REGISTRY_CA_PATH
  
  imgpkg copy -b registry.tanzu.vmware.com/tanzu-application-platform/full-tbs-deps-package-repo:${VERSION} \
  --to-repo ${IMGPKG_REGISTRY_HOSTNAME}/${IMGPKG_REPO}/tbs-full-deps \
  --registry-ca-cert-path $REGISTRY_CA_PATH
fi