#!/bin/bash
COMMON_SCRIPTDIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
source $COMMON_SCRIPTDIR/common.sh
load_env_file $COMMON_SCRIPTDIR/../tap-env

parse_args "$@"

if [ -z "$SCRIPTDIR" ]; then
   echo "Please export SCRIPTDIR from the calling script."
   echo "  export SCRIPTDIR=..."
   exit 1
fi

if [ -z "$PROFILE" ]; then
   echo "PROFILE is required"
   print_help
   exit 1
fi

## select default yml file if no yml given with -f option
if ! is_yml_arg_exist "$@"; then
  TAP_ENV_DIR=${TAP_ENV_DIR:-$SCRIPTDIR}
  echo "[YML] Using tap-values template file from TAP_ENV_DIR '$TAP_ENV_DIR'"
  YML=$TAP_ENV_DIR/tap-values-${PROFILE}-1st-TEMPLATE.yml
else
  echo "[YML] Using Given YML file: $YML"
fi

exit_if_not_valid_yml "$YML"

OVERLAYED_CA_SHARED_YML="/tmp/$(generate_new_filename $YML 'OVERLAYED_CA_SHARED_YML')"
overlay_IMGPKG_REGISTRY_CA_CERTIFICATE $YML $OVERLAYED_CA_SHARED_YML

FINAL_YML="/tmp/$(generate_new_filename $YML 'FINAL')"
replace_key_if_template_yml $OVERLAYED_CA_SHARED_YML $FINAL_YML 


echo "[YML] Final '$FINAL_YML'"
echo "================================"
cat $FINAL_YML
if [ "full" == "$PROFILE" ] || [ "build" == "$PROFILE" ]; then
 echo "================================"
 echo ""
 echo "secret/scanning-ca-overlay resource will be created as profile is '$PROFILE'"
 echo "configmap/scanning-harbor-ca-overlay-cm created as profile is '$PROFILE'"
fi
echo "================================"
echo ""
echo "[YML] Final '$FINAL_YML'"
echo "To Update YML, edit the template file from TAP_ENV_DIR:$TAP_ENV_DIR "
echo "  - $TAP_ENV_DIR/tap-values-${PROFILE}-1st-TEMPLATE.yml"
echo ""
echo "or use custom yml:  21-install-tap.sh -f /path/to/YML"
echo ""

print_current_k8s


if [ "$YES" != "y" ]; then
 confirm_target_k8s
fi

set -x

if [ "full" == "$PROFILE" ] || [ "build" == "$PROFILE" ]; then
 create_resource_scanning_ca_overlay_BUILDSERVICE_REGISTRY_CA_CERTIFICATE
fi

tanzu package install tap -p tap.tanzu.vmware.com -v $TAP_VERSION -n tap-install --values-file $FINAL_YML

