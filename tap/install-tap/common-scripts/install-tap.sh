#!/bin/bash
COMMON_SCRIPTDIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
source $COMMON_SCRIPTDIR/common.sh
load_env_file $COMMON_SCRIPTDIR/../tap-env

set -e

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

if is_yml_arg_not_exist "$@"; then
  TAP_ENV_DIR=${TAP_ENV_DIR:-$SCRIPTDIR}
  echo "Loading tap-values file from TAP_ENV_DIR:$TAP_ENV_DIR"
  YML=$TAP_ENV_DIR/tap-values-${PROFILE}-1st-TEMPLATE.yml
  echo "Using default yml tempalate: $YML"
else
  echo "Using Given yml file: $YML"
fi


## processing custom CA.
## filename should be 'tap_registry_ca.crt' that matches with  tap-values-custom-ca-overlay-template.yaml contents.
REGISTRY_CA_FILE_PATH="/tmp/tap_registry_ca.crt" 
## filename should be *TEMPLATE.yml for function 'replace_key_if_template_yml' later.
## /tmp/tap-values-OVERLAYED-{FILENAME}
OVERLAYED_YML="/tmp/$(generate_new_filename $YML 'OVERLAYED')"
overlay_custom_ca_to_yml $YML $REGISTRY_CA_FILE_PATH $OVERLAYED_YML

FINAL_YML="/tmp/$(generate_new_filename $OVERLAYED_YML 'FINAL')"
replace_key_if_template_yml $OVERLAYED_YML $FINAL_YML 

echo "Final YML: $FINAL_YML"
echo "================"
cat $FINAL_YML
echo "----------------"

if [ "$YES" != "y" ]; then
 confirm_target_k8s
fi

tanzu package install tap -p tap.tanzu.vmware.com -v $TAP_VERSION -n tap-install -f $FINAL_YML

