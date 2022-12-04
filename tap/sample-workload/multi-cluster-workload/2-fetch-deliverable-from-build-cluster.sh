#!/bin/bash
SCRIPTDIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
source $SCRIPTDIR/../sample-env
set -x
kubectl get deliverable tanzu-java-web-app -n ${DEVELOPER_NAMESPACE} -o yaml > /tmp/${WORKLOAD_NAME}-deliverable-tmp.yml
ytt --ignore-unknown-comments -f /tmp/${WORKLOAD_NAME}-deliverable-tmp.yml -f $SCRIPTDIR/deliverable-overlay.yml > /tmp/${WORKLOAD_NAME}-deliverable.yml
echo "fetched /tmp/${WORKLOAD_NAME}-deliverable.yml"
kubectl get configmap -n ${DEVELOPER_NAMESPACE} ${WORKLOAD_NAME}  -o jsonpath='{.data.delivery\.yml}' > /tmp/${WORKLOAD_NAME}-delivery.yml