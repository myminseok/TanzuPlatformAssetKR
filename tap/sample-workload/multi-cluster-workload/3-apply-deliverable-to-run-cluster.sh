#!/bin/bash
SCRIPTDIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
source $SCRIPTDIR/../sample-env

set +e
kubectl create ns $DEVELOPER_NAMESPACE 
set -e

kubectl -n ${DEVELOPER_NAMESPACE} apply -f /tmp/${WORKLOAD_NAME}-deliverable.yml
echo ""
echo "gitops ssh secret(such as git-ssh) should be created manually."