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

check_executable "ytt"

## select default yml file if no yml given with -f option
if ! is_yml_arg_exist "$@"; then
  TAP_ENV_DIR=${TAP_ENV_DIR:-$SCRIPTDIR}
 echo "[YML] Using tap-values template file from TAP_ENV_DIR '$TAP_ENV_DIR'"
  YML_1st=$TAP_ENV_DIR/tap-values-${PROFILE}-1st-TEMPLATE.yml
  YML_2nd=$TAP_ENV_DIR/tap-values-${PROFILE}-2nd-overlay-TEMPLATE.yml
  YTT_YML="/tmp/tap-values-${PROFILE}-update-TEMPLATE.yml"
  set -ex
  ytt --ignore-unknown-comments -f $YML_1st -f $YML_2nd  > $YTT_YML
  set +x
  YML=$YTT_YML
else
  echo "[YML] Using Given YML file: $YML"
fi

exit_if_not_valid_yml "$YML"

## processing custom CA.
## filename should be 'tap_registry_ca.crt' that matches with  tap-values-custom-ca-overlay-template.yaml contents.
REGISTRY_CA_FILE_PATH="/tmp/tap_registry_ca.crt" 
## filename should be *TEMPLATE.yml for function 'replace_key_if_template_yml' later.
## /tmp/tap-values-OVERLAYED-{FILENAME}
OVERLAYED_YML="/tmp/$(generate_new_filename $YML 'OVERLAYED')"
overlay_custom_ca_if_template_yml $YML $REGISTRY_CA_FILE_PATH $OVERLAYED_YML

FINAL_YML="/tmp/$(generate_new_filename $OVERLAYED_YML 'FINAL')"
replace_key_if_template_yml $OVERLAYED_YML $FINAL_YML 

echo "[YML] Final '$FINAL_YML'"
echo "================================"
cat $FINAL_YML
echo "--------------------------------"
echo "To Update YML, edit the template file from TAP_ENV_DIR:$TAP_ENV_DIR "
echo "  - $TAP_ENV_DIR/tap-values-${PROFILE}-1st-TEMPLATE.yml"
echo "  - $TAP_ENV_DIR/tap-values-${PROFILE}-2nd-overlay-TEMPLATE.yml"
echo ""
echo "or use custom yml:  23-update-tap.sh -f /path/to/YML"
echo ""
print_current_k8s

if [ "$YES" != "y" ]; then
 confirm_target_k8s
fi
create_scanning-ca-overlay_if_defined
tanzu package installed update tap -p tap.tanzu.vmware.com -v $TAP_VERSION -n tap-install --values-file $FINAL_YML 