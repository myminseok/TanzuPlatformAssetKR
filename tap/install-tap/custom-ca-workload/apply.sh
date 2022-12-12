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

set +e
kubectl create ns $DEVELOPER_NAMESPACE
set -e


## apply to overlay
kubectl get cm -n $DEVELOPER_NAMESPACE
cp $SCRIPTDIR/ootb-templates-overlay-workload-custom-cert.yml.template /tmp/ootb-templates-overlay-workload-custom-cert.yml
sed -i -r "s/CONFIG_MAP_NAME/${CONFIG_MAP_NAME}/g" /tmp/ootb-templates-overlay-workload-custom-cert.yml
sed -i -r "s/CONFIG_MAP_SUBPATH/${REGISTRY_CA_FILE}/g" /tmp/ootb-templates-overlay-workload-custom-cert.yml
kubectl apply -f /tmp/ootb-templates-overlay-workload-custom-cert.yml
