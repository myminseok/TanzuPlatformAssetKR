#!/bin/bash
SCRIPTDIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
source $SCRIPTDIR/common-scripts/common.sh
load_env_file $SCRIPTDIR/tap-env

APP_LIST=$(kubectl get app -n tap-install  | grep -v "NAME" | awk '{print $1}')
#APP_LIST=$(kubectl get app -n tap-install | egrep "stack|buildpack|builder|amr-observer"  | awk '{print $1}')
echo $APP_LIST



confirm_target_k8s "Are you sure to DELETE?: "

for app in $APP_LIST;
do
  echo $app
  set +x
  kubectl patch app/$app -n tap-install -p '{"metadata":{"finalizers":null}}' --type=merge
#:  kubectl patch app/$app -n tap-install -p '[{"path":"/metadata/finalizers","op": "remove"}]'  --type=json
done
