#!/bin/bash
SCRIPTDIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
source $SCRIPTDIR/../../install-tap/common-scripts/common.sh
load_env_file $SCRIPTDIR/tap-env
DEVELOPER_NAMESPACE=${1:-$DEVELOPER_NAMESPACE}

WORKLOAD_NAME="tanzu-java-web-app"

set -x
kubectl get configmap ${WORKLOAD_NAME}-deliverable --namespace ${DEVELOPER_NAMESPACE} -o go-template='{{.data.deliverable}}' > /tmp/${WORKLOAD_NAME}-deliverable.yml
cat /tmp/${WORKLOAD_NAME}-deliverable.yml
echo "================================"
echo "fetched /tmp/${WORKLOAD_NAME}-deliverable.yml"