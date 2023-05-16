#!/bin/bash
SCRIPTDIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
source $SCRIPTDIR/../../install-tap/common-scripts/common.sh
load_env_file $SCRIPTDIR/tap-env
DEVELOPER_NAMESPACE=${1:-$DEVELOPER_NAMESPACE}

WORKLOAD_NAME="tanzu-java-web-app"
kubectl get ConfigMap/${WORKLOAD_NAME}-with-api-descriptors -n ${DEVELOPER_NAMESPACE} \
-o jsonpath='{.data.apiDescriptor\.yml}' > /tmp/apiDescriptor.yml> /tmp/${WORKLOAD_NAME}-apiDescriptor.yml

echo "================================"
echo "Fetched  /tmp/${WORKLOAD_NAME}-apiDescriptor.yml"