#!/bin/bash
SCRIPTDIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
source $SCRIPTDIR/../common-scripts/common.sh
load_env_file $SCRIPTDIR/../tap-env

CURRENT_CONTEXT=$(kubectl config current-context)
read -p "EXPERIMENTAL: Are you sure the target cluster '$CURRENT_CONTEXT'? (Y/y) " -n 1 -r
if [[ ! $REPLY =~ ^[Yy]$ ]]
then
    echo "Quitting"
    exit 1
fi

kubectl apply -f ootb-templates-overlay.yml -n tap-install

kubectl create secret generic knative-serving-overlay -n tap-install \
  -o yaml \
  --dry-run=client \
  --from-file=$SCRIPTDIR/knative-serving-config-features-overlay.yml \
  | kubectl apply -f-

set +e
kubectl create ns ${DEVELOPER_NAMESPACE}
set -e

kubectl apply -f $SCRIPTDIR/tanzu-java-web-app-pvc.yml 

