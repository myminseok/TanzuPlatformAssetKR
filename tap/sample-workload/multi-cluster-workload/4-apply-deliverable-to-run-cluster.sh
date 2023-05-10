#!/bin/bash
SCRIPTDIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
source $SCRIPTDIR/../sample-env


kubectl -n ${DEVELOPER_NAMESPACE} apply -f /tmp/${WORKLOAD_NAME}-deliverable.yml

kubectl  -n ${DEVELOPER_NAMESPACE} get deliverable 

echo ""
echo "gitops ssh secret(such as git-ssh) should be created manually."