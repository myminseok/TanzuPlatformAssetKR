#!/bin/bash
SCRIPTDIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
source $SCRIPTDIR/../common-scripts/common.sh
load_env_file $SCRIPTDIR/../tap-env

read -p "EXPERIMENTAL: Are you sure the target cluster '$CONTEXT'? (Y/y) " -n 1 -r
if [[ ! $REPLY =~ ^[Yy]$ ]]
then
    echo "Quitting"
    exit 1
fi

set +e
kubectl create ns $DEVELOPER_NAMESPACE
set -e

if [ -z $WORLOAD_CA_CERTIFICATE ]; then
  echo "WARNING: Skipping to overlay Scanning CA. ENV `WORLOAD_CA_CERTIFICATE` not found"
  echo ""
  exit 0
fi

## create configmap
CONFIG_MAP_NAME="workload-ca-overlay-cm"
REGISTRY_CA_FILE="workload-ca.crt"
REGISTRY_CA_FILE_PATH="/tmp/$REGISTRY_CA_FILE"


echo $WORLOAD_CA_CERTIFICATE | base64 -d > $REGISTRY_CA_FILE_PATH

set +e
kubectl delete cm ${CONFIG_MAP_NAME}  -n $DEVELOPER_NAMESPACE
set -e
kubectl create cm ${CONFIG_MAP_NAME}  -n $DEVELOPER_NAMESPACE --from-file $REGISTRY_CA_FILE_PATH 

## verify
set +e
DATA=$(kubectl get cm ${CONFIG_MAP_NAME} -n $DEVELOPER_NAMESPACE -o jsonpath='{.data.workload-ca\.crt}')
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
cp $SCRIPTDIR/ootb-templates-overlay-workload-custom-cert.yml.template /tmp/ootb-templates-overlay-workload-custom-cert.yml
sed -i -r "s/CONFIG_MAP_NAME/${CONFIG_MAP_NAME}/g" /tmp/ootb-templates-overlay-workload-custom-cert.yml
sed -i -r "s/CONFIG_MAP_SUBPATH/${REGISTRY_CA_FILE}/g" /tmp/ootb-templates-overlay-workload-custom-cert.yml
kubectl apply -f /tmp/ootb-templates-overlay-workload-custom-cert.yml


kubectl create secret generic knative-serving-overlay -n tap-install \
  -o yaml \
  --dry-run=client \
  --from-file=$SCRIPTDIR/knative-serving-config-features-overlay.yml \
  | kubectl apply -f-
