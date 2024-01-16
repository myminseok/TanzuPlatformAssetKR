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

if [ "$UPDATE" == "y" ]; then ## "--update"
  ## select default yml file if no yml given with -f option
  if  is_yml_arg_exist "$@" ; then
     echo "[YML] Using Given YML file: $YML"
  else
    TAP_ENV_DIR=${TAP_ENV_DIR:-$SCRIPTDIR}
    echo "[YML] Using tap-values template file from TAP_ENV_DIR '$TAP_ENV_DIR'"
    YML_1st=$TAP_ENV_DIR/tap-values-${PROFILE}-1st-TEMPLATE.yml
    YML_2nd=$TAP_ENV_DIR/tap-values-${PROFILE}-2nd-overlay-TEMPLATE.yml
    YTT_YML="/tmp/tap-values-${PROFILE}-update-TEMPLATE.yml"
    set -ex
    ytt --ignore-unknown-comments -f $YML_1st -f $YML_2nd  > $YTT_YML
    set +x
    YML=$YTT_YML
  fi
else 
  ## select default yml file if no yml given with -f option
  if is_yml_arg_exist "$@"; then
    echo "[YML] Using Given YML file: $YML"
  else
    TAP_ENV_DIR=${TAP_ENV_DIR:-$SCRIPTDIR}
    echo "[YML] Using tap-values template file from TAP_ENV_DIR '$TAP_ENV_DIR'"
    YML=$TAP_ENV_DIR/tap-values-${PROFILE}-1st-TEMPLATE.yml
  fi
fi



exit_if_not_valid_yml "$YML"

OVERLAYED_CA_SHARED_YML="/tmp/$(generate_new_filename $YML 'OVERLAYED_CA_SHARED')"
overlay_IMGPKG_REGISTRY_CA_CERTIFICATE $YML $OVERLAYED_CA_SHARED_YML
YML=$OVERLAYED_CA_SHARED_YML

### TODO: commenting out this on TAP 1.5, because overlaying to scantemplate broke scan job validation webhook. 
# if [ "full" == "$PROFILE" ] || [ "build" == "$PROFILE" ]; then
#   OVERLAYED_CA_BUILDSERVICE_YML="/tmp/$(generate_new_filename $YML 'OVERLAYED_CA_BUILDSERVICE')"
#   overlay_BUILDSERVICE_REGISTRY_CA_CERTIFICATE $YML $OVERLAYED_CA_BUILDSERVICE_YML
#   YML=$OVERLAYED_CA_BUILDSERVICE_YML
# fi

FINAL_YML="/tmp/$(generate_new_filename $YML 'FINAL')"
replace_key_if_template_yml $YML $FINAL_YML 

echo "[YML] Final '$FINAL_YML'"
echo "================================"
cat $FINAL_YML
echo "================================"
echo ""
echo "To Update YML, edit the template file from TAP_ENV_DIR:$TAP_ENV_DIR "
echo "  - $TAP_ENV_DIR/tap-values-${PROFILE}-1st-TEMPLATE.yml"
echo "  - $TAP_ENV_DIR/tap-values-${PROFILE}-2nd-overlay-TEMPLATE.yml"
echo ""
echo "or use custom yml:  23-update-tap.sh -f /path/to/YML"
echo ""
echo "================================"
echo ""
if [ "$UPDATE" == "y" ]; then
  echo "UPDATE tap with PROFILE: $PROFILE" 
else
  echo "INSTALL tap with PROFILE: $PROFILE" 
fi

echo "[YML] Final '$FINAL_YML'"



PROFILE_UPPPER=$( echo $PROFILE | awk '{print toupper($0)}' )
KEY="TARGET_CONTEXT_${PROFILE_UPPPER}"
eval "export "TARGET_CONTEXT_ENV='$'$KEY""


if [ "$TARGET_CONTEXT_ENV" == "" ]; then
  TARGET_CONTEXT=$(kubectl config current-context)
  TARGET_CONTEXT_ORIGIN="kubeconfig"
  
else
  TARGET_CONTEXT="$TARGET_CONTEXT_ENV"
  TARGET_CONTEXT_ORIGIN=$TAP_ENV
  
fi


echo ""
if [ "full" == "$PROFILE" ] || [ "build" == "$PROFILE" ]; then
 echo "following k8s resource will be created (profile is '$PROFILE')"
 echo "- secret/scanning-ca-overlay (on tap-install ns)"
 echo "- configmap/scanning-harbor-ca-overlay-cm (on DEV-NAMESPACE)"
fi

echo "================================"
echo ""
COMMAND="tanzu package          install --kubeconfig-context=$TARGET_CONTEXT tap -p tap.tanzu.vmware.com -v $TAP_VERSION -n tap-install --values-file $FINAL_YML"
if [ "$UPDATE" == "y" ]; then
  COMMAND="tanzu package installed update --kubeconfig-context=$TARGET_CONTEXT tap -p tap.tanzu.vmware.com -v $TAP_VERSION -n tap-install --values-file $FINAL_YML"
fi
echo "$COMMAND"
echo ""

echo "!!! TARGET_CONTEXT: $TARGET_CONTEXT. it comes from '$TARGET_CONTEXT_ORIGIN'"



if [ "$YES" != "y" ]; then
 confirm_target_context "$TARGET_CONTEXT" "Are you sure the target? "
 confirm_target_context "$TARGET_CONTEXT" "TARGET CLUSTER is "
fi

set -x
$COMMAND


