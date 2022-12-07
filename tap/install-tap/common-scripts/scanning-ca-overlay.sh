#!/bin/bash
SCRIPTDIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
source $SCRIPTDIR/../common-scripts/common.sh
load_env_file $SCRIPTDIR/../tap-env

echo "This script should run on BUILD cluster"

set +e
kubectl create ns $DEVELOPER_NAMESPACE
set -e

if [ -z $BUILDSERVICE_REGISTRY_CA_CERTIFICATE ]; then
  echo "WARNING: Skipping to overlay Scanning CA. ENV `BUILDSERVICE_REGISTRY_CA_CERTIFICATE` not found"
  echo ""
  exit 0
fi

## create configmap
CONFIG_MAP_NAME="scanning-harbor-ca-overlay-cm"
REGISTRY_CA_FILE="harbor.crt"
REGISTRY_CA_FILE_PATH="/tmp/$REGISTRY_CA_FILE"


echo $BUILDSERVICE_REGISTRY_CA_CERTIFICATE | base64 -d > $REGISTRY_CA_FILE_PATH

set +e
kubectl delete cm ${CONFIG_MAP_NAME}  -n $DEVELOPER_NAMESPACE
set -e
kubectl create cm ${CONFIG_MAP_NAME}  -n $DEVELOPER_NAMESPACE --from-file $REGISTRY_CA_FILE_PATH 

## verify
set +e
DATA=$(kubectl get cm ${CONFIG_MAP_NAME} -n $DEVELOPER_NAMESPACE -o jsonpath='{.data.harbor\.crt}')
set -e
if [ "x$DATA" == "x" ]; then
  echo ""
  echo "!! ERROR: ${CONFIG_MAP_NAME} is invalid. "
  echo "!! ERROR: kubectl get cm ${CONFIG_MAP_NAME}  -n $DEVELOPER_NAMESPACE  -o yaml"
  echo ""
  exit 1
fi

## apply to overlay
kubectl get cm -n $DEVELOPER_NAMESPACE
cp $SCRIPTDIR/scanning-ca-overlay.yml.template /tmp/scanning-ca-overlay.yml
sed -i -r "s/CONFIG_MAP_NAME/${CONFIG_MAP_NAME}/g" /tmp/scanning-ca-overlay.yml
sed -i -r "s/CONFIG_MAP_SUBPATH/${REGISTRY_CA_FILE}/g" /tmp/scanning-ca-overlay.yml
kubectl apply -f /tmp/scanning-ca-overlay.yml