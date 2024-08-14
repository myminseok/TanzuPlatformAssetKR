## https://docs.vmware.com/en/VMware-Tanzu-Application-Platform/1.11/tap/install-offline-tbs-offline-install-deps.html
## 

#!/bin/bash
SCRIPTDIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
source $SCRIPTDIR/common-scripts/common.sh
load_env_file $SCRIPTDIR/tap-env

set -e

function print_help {
  echo ""
  echo "Download/Upload packages."
  echo "Usage: $0 [--download /path/to/tar] [--upload /path/to/tar]"
  echo "  By default, if no option, Download and upload packages DIRECTLY WITHOUT saving to tar."
  echo "  --download) optional. download packages and save to tar. folder will be created if not exist"
  echo "  --upload  ) optional. upload packages from the tar."
  echo "  note that, '=' in --key=value is optional"
  echo ""
}

if is_arg_exist '-h' $@; then
  print_help
  exit 0
fi

verify_tap_env_param "INSTALL_REGISTRY_HOSTNAME", "$INSTALL_REGISTRY_HOSTNAME"
verify_tap_env_param "IMGPKG_REGISTRY_HOSTNAME", "$IMGPKG_REGISTRY_HOSTNAME"
verify_tap_env_param "IMGPKG_REGISTRY_USERNAME", "$IMGPKG_REGISTRY_USERNAME"
verify_tap_env_param "IMGPKG_REGISTRY_PASSWORD", "$IMGPKG_REGISTRY_PASSWORD"
verify_tap_env_param "IMGPKG_REPO", "$IMGPKG_REPO"
verify_tap_env_param "TAP_VERSION", "$TAP_VERSION"

echo "==============================================================="
echo "[MANUAL] PREREQUSITE "
echo "---------------------------------------------------------------"
echo "PREREQUSITE: docker login $INSTALL_REGISTRY_HOSTNAME"
echo "PREREQUSITE: docker login $IMGPKG_REGISTRY_HOSTNAME"
echo "PREREQUSITE: create repo  $IMGPKG_REGISTRY_HOSTNAME/$IMGPKG_REPO as PUBLIC"
docker login $IMGPKG_REGISTRY_HOSTNAME -u $IMGPKG_REGISTRY_USERNAME -p $IMGPKG_REGISTRY_PASSWORD

check_executable "imgpkg"

echo "INFO) For TAp 1.11, repo size is 13 GiB"
echo "INFO) For TAp 1.8, repo size is 22.88 GiB"
echo "INFO) For TAp 1.6, repo size is 11.24 GiB"

echo "Relocating full-tbs-deps-package-repo for buildservice.tanzu.vmware.com version:$TAP_VERSION"

REGISTRY_CA_PATH_ARG=""
if [ ! -z $IMGPKG_REGISTRY_CA_CERTIFICATE ]; then
  REGISTRY_CA_PATH="/tmp/imgpkg_registry_ca.crt"
  echo "Env IMGPKG_REGISTRY_CA_CERTIFICATE detected. Creating CA file to $REGISTRY_CA_PATH"
  echo "$IMGPKG_REGISTRY_CA_CERTIFICATE" | base64 -d > $REGISTRY_CA_PATH
  REGISTRY_CA_PATH_ARG="--registry-ca-cert-path $REGISTRY_CA_PATH"
fi

public_repo_url="$INSTALL_REGISTRY_HOSTNAME/tanzu-application-platform/full-deps-package-repo:${TAP_VERSION}"
relocated_repo_url="${IMGPKG_REGISTRY_HOSTNAME}/${IMGPKG_REPO}/full-deps-package-repo"

get_value_from_args 'DOWNLOAD_TAR_PATH' '--download' $@
if [ ! -z $DOWNLOAD_TAR_PATH ]; then
  echo "Downloading $public_repo_url to $DOWNLOAD_TAR_PATH "
  set -x
  DOWNLOAD_DIR=$(dirname "${DOWNLOAD_TAR_PATH}")
  mkdir -p $DOWNLOAD_DIR
  imgpkg copy -b $public_repo_url \
    --to-tar ${DOWNLOAD_TAR_PATH} \
    --include-non-distributable-layers $REGISTRY_CA_PATH_ARG
    ## --debug 2>&1 | tee download.log
        
  echo ""
  echo "Successfully downloaded to $DOWNLOAD_TAR_PATH"
  exit 0 
fi

get_value_from_args 'UPLOAD_TAR_PATH' '--upload' $@
if [ ! -z $UPLOAD_TAR_PATH ]; then
  if [ ! -f $UPLOAD_TAR_PATH ]; then
    echo "ERROR: File not found: $UPLOAD_TAR_PATH "
    print_help
    exit 1
  fi 
  echo "Uploading $UPLOAD_TAR_PATH to $relocated_repo_url"
  set -x
  imgpkg copy \
    --tar ${UPLOAD_TAR_PATH} \
    --to-repo $relocated_repo_url \
    $REGISTRY_CA_PATH_ARG
  exit 0 
fi

echo "Downloading and Uploading to $IMGPKG_REGISTRY_HOSTNAME directly."
set -x
imgpkg copy -b $public_repo_url \
  --to-repo $relocated_repo_url \
  --include-non-distributable-layers $REGISTRY_CA_PATH_ARG