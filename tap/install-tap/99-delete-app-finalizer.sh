### run this script on deleting tap component failed.
# kapp: Error: Getting app: configmaps "accelerator.app.apps.k14s.io" is forbidden:
#      User "system:serviceaccount:tap-install:tap-install-sa" cannot get resource "configmaps" in API group "" in the namespace "tap-install"


#!/bin/bash
SCRIPTDIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
source $SCRIPTDIR/common-scripts/common.sh
load_env_file $SCRIPTDIR/tap-env

app=$1
if [ ! -z $app ]; then
  set +x
  echo "kubectl patch app/$app -n tap-install -p '{"metadata":{"finalizers":null}}' --type=merge"
  kubectl patch app/$app -n tap-install -p '{"metadata":{"finalizers":null}}' --type=merge
  exit 0
fi


## APP_LIST=$(kubectl get app -n tap-install  | grep -v "NAME" | awk '{print $1}')
APP_LIST=$(kubectl get app -n tap-install | egrep "buildpack"  | awk '{print $1}')
echo "-----"
echo $APP_LIST


confirm_target_k8s "Are you sure to DELETE?: "

for app in $APP_LIST;
do
  echo $app
  set +x
  kubectl patch app/$app -n tap-install -p '{"metadata":{"finalizers":null}}' --type=merge
  # kubectl patch app/$app -n tap-install -p '[{"path":"/metadata/finalizers","op": "remove"}]'  --type=json
done