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


REGISTRY_CA_PATH_ARG=""
if [ ! -z $IMGPKG_REGISTRY_CA_CERTIFICATE ]; then
  REGISTRY_CA_PATH="/tmp/imgpkg_registry_ca.crt"
  echo "Env IMGPKG_REGISTRY_CA_CERTIFICATE detected. Creating CA file to $REGISTRY_CA_PATH"
  echo "$IMGPKG_REGISTRY_CA_CERTIFICATE" | base64 -d > $REGISTRY_CA_PATH
  REGISTRY_CA_PATH_ARG="--registry-ca-cert-path $REGISTRY_CA_PATH"
fi

public_repo_url="registry.tanzu.vmware.com/tanzu-application-platform/full-tbs-deps-package-repo:${VERSION}"
relocated_repo_url="${IMGPKG_REGISTRY_HOSTNAME}/${IMGPKG_REPO}/tbs-full-deps"

get_value_from_args 'DOWNLOAD_TAR_PATH' '--download' $@
if [ ! -z $DOWNLOAD_TAR_PATH ]; then
  echo "Downloading $public_repo_url to $DOWNLOAD_TAR_PATH "
  set -x
  DOWNLOAD_DIR=$(dirname "${DOWNLOAD_TAR_PATH}")
  mkdir -p $DOWNLOAD_DIR
  imgpkg copy -b $public_repo_url --to-tar ${DOWNLOAD_TAR_PATH} \
    --include-non-distributable-layers $REGISTRY_CA_PATH_ARG
  exit 0 
fi

get_value_from_args 'UPLOAD_TAR_PATH' '--upload' $@
if [[ ! -z $UPLOAD_TAR_PATH &&  ! -f $UPLOAD_TAR_PATH ]]; then
    echo "ERROR: File not found: $UPLOAD_TAR_PATH "
    print_help
    exit 1
  fi 
  echo "Uploading $UPLOAD_TAR_PATH to $relocated_repo_url"
  set -x
  imgpkg copy --tar ${UPLOAD_TAR_PATH} --to-repo $relocated_repo_url  $REGISTRY_CA_PATH_ARG
  exit 0 
fi

echo "Downloading and Uploading to $IMGPKG_REGISTRY_HOSTNAME directly."
set -x
imgpkg copy -b $public_repo_url --to-repo $relocated_repo_url $REGISTRY_CA_PATH_ARG