#!/bin/bash
SCRIPTDIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
source $SCRIPTDIR/../common-scripts/common.sh
load_env_file $SCRIPTDIR/../tap-env

WORKLOAD_NAME="tanzu-java-web-app"

## create configmap
CONFIG_MAP_NAME="workload-ca-secret"
REGISTRY_CA_FILE="workload-ca.crt"
REGISTRY_CA_FILE_PATH="$SCRIPTDIR/$REGISTRY_CA_FILE"

set +e
kubectl delete secret ${CONFIG_MAP_NAME}  -n $DEVELOPER_NAMESPACE
set -e
kubectl create secret generic ${CONFIG_MAP_NAME}  -n $DEVELOPER_NAMESPACE --from-file $REGISTRY_CA_FILE_PATH 

## verify
set +e
DATA=$(kubectl get secret ${CONFIG_MAP_NAME} -n $DEVELOPER_NAMESPACE -o jsonpath='{.data.workload-ca\.crt}')
set -e
if [ "x$DATA" == "x" ]; then
  echo ""
  echo "!! ERROR: ${CONFIG_MAP_NAME} is invalid. "
  echo "!! ERROR: kubectl get cm ${CONFIG_MAP_NAME}  -n $DEVELOPER_NAMESPACE  -o yaml"
  echo ""
  exit 1
fi


tanzu apps workload delete ${WORKLOAD_NAME} --yes  -n ${DEVELOPER_NAMESPACE}
tanzu apps workload create -f $SCRIPTDIR/workload-tanzu-java-web-app-ca.yaml --yes   -n ${DEVELOPER_NAMESPACE}