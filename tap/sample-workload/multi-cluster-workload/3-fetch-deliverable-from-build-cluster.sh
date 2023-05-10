#!/bin/bash
SCRIPTDIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
source $SCRIPTDIR/../sample-env
set -x
kubectl get configmap ${WORKLOAD_NAME}-deliverable --namespace ${DEVELOPER_NAMESPACE} -o go-template='{{.data.deliverable}}' > /tmp/${WORKLOAD_NAME}-deliverable.yml
cat /tmp/${WORKLOAD_NAME}-deliverable.yml
echo "================================"
echo "fetched /tmp/${WORKLOAD_NAME}-deliverable.yml"