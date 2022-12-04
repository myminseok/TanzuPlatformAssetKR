#!/bin/bash
SCRIPTDIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
source $SCRIPTDIR/../sample-env

kubectl get ConfigMap/${WORKLOAD_NAME}-with-api-descriptors -n d${DEVELOPER_NAMESPACE} \
-o jsonpath='{.data.apiDescriptor\.yml}' > /tmp/apiDescriptor.yml> /tmp/${WORKLOAD_NAME}-apiDescriptor.yml