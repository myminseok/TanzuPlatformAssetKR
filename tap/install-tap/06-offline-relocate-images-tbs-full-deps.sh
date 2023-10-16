## https://docs.vmware.com/en/VMware-Tanzu-Application-Platform/1.3/tap/GUID-tbs-offline-install-deps.html
## 9.6GB
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

verify_tap_env_param "IMGPKG_REGISTRY_HOSTNAME", "$IMGPKG_REGISTRY_HOSTNAME"
verify_tap_env_param "IMGPKG_REGISTRY_USERNAME", "$IMGPKG_REGISTRY_USERNAME"
verify_tap_env_param "IMGPKG_REGISTRY_PASSWORD", "$IMGPKG_REGISTRY_PASSWORD"
verify_tap_env_param "IMGPKG_REPO", "$IMGPKG_REPO"
verify_tap_env_param "TAP_VERSION", "$TAP_VERSION"
verify_tap_env_param "TBS_FULL_DEPS_VERSION", "$TBS_FULL_DEPS_VERSION"

echo "==============================================================="
echo "[MANUAL] PREREQUSITE "
echo "---------------------------------------------------------------"
echo "PREREQUSITE: docker login registry.tanzu.vmware.com"
echo "PREREQUSITE: docker login $IMGPKG_REGISTRY_HOSTNAME"
echo "PREREQUSITE: create repo  $IMGPKG_REGISTRY_HOSTNAME/$IMGPKG_REGISTRY_USERNAME/$IMGPKG_REPO as PUBLIC"

check_executable "imgpkg"

if [ -z $TBS_FULL_DEPS_VERSION ]; then
  TBS_FULL_DEPS_VERSION=$(tanzu package available list buildservice.tanzu.vmware.com --namespace tap-install -o json | jq -r '.[] | select(.name=="buildservice.tanzu.vmware.com") | .version')
  if [ "x$TBS_FULL_DEPS_VERSION" == "x" ]; then
    echo "ERROR no buildservice.tanzu.vmware.com found"
    exit 1
  fi
fi
echo "Relocating full-tbs-deps-package-repo for buildservice.tanzu.vmware.com version:$TBS_FULL_DEPS_VERSION"


REGISTRY_CA_PATH_ARG=""
if [ ! -z $IMGPKG_REGISTRY_CA_CERTIFICATE ]; then
  REGISTRY_CA_PATH="/tmp/imgpkg_registry_ca.crt"
  echo "Env IMGPKG_REGISTRY_CA_CERTIFICATE detected. Creating CA file to $REGISTRY_CA_PATH"
  echo "$IMGPKG_REGISTRY_CA_CERTIFICATE" | base64 -d > $REGISTRY_CA_PATH
  REGISTRY_CA_PATH_ARG="--registry-ca-cert-path $REGISTRY_CA_PATH"
fi

## for 1.5.x
#public_repo_url="registry.tanzu.vmware.com/tanzu-application-platform/full-tbs-deps-package-repo:${TBS_FULL_DEPS_VERSION}"
## for 1.6.x
public_repo_url="registry.tanzu.vmware.com/tanzu-application-platform/full-deps-package-repo:${TAP_VERSION}"
relocated_repo_url="${IMGPKG_REGISTRY_HOSTNAME}/$IMGPKG_REGISTRY_OWNER/${IMGPKG_REPO}/full-deps-package-repo"
if [ "x$IMGPKG_REGISTRY_OWNER" == "x" ]; then
  relocated_repo_url="${IMGPKG_REGISTRY_HOSTNAME}/${IMGPKG_REPO}/full-deps-package-repo"
fi

get_value_from_args 'DOWNLOAD_TAR_PATH' '--download' $@
if [ ! -z $DOWNLOAD_TAR_PATH ]; then
  echo "Downloading $public_repo_url to $DOWNLOAD_TAR_PATH "
  set -x
  DOWNLOAD_DIR=$(dirname "${DOWNLOAD_TAR_PATH}")
  mkdir -p $DOWNLOAD_DIR
  imgpkg copy -b $public_repo_url --to-tar ${DOWNLOAD_TAR_PATH} \
    --include-non-distributable-layers $REGISTRY_CA_PATH_ARG
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
  imgpkg copy --tar ${UPLOAD_TAR_PATH} --to-repo $relocated_repo_url  $REGISTRY_CA_PATH_ARG
  exit 0 
fi

echo "Downloading and Uploading to $IMGPKG_REGISTRY_HOSTNAME directly."
set -x
imgpkg copy -b $public_repo_url --to-repo $relocated_repo_url $REGISTRY_CA_PATH_ARG


