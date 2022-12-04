#!/bin/bash
_SCRIPTDIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
source $_SCRIPTDIR/common.sh
load_env_file $_SCRIPTDIR/../tap-env

parse_args "$@"

if [ -z "$PROFILE" ]; then
   echo "PROFILE is required"
   print_help
   exit 1
fi
  
YML="$(generate_yml_if_template_yml $YML)"

echo "Final YML: $YML"

if [ "$YES" != "y" ]; then
 confirm_target_k8s
fi

tanzu package install tap -p tap.tanzu.vmware.com -v $TAP_VERSION -n tap-install -f $YML

