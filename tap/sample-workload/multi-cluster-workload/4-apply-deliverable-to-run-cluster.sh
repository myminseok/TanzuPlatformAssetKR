#!/bin/bash
SCRIPTDIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
source $SCRIPTDIR/../../install-tap/common-scripts/common.sh
load_env_file $SCRIPTDIR/tap-env
DEVELOPER_NAMESPACE=${1:-$DEVELOPER_NAMESPACE}

WORKLOAD_NAME="tanzu-java-web-app"

kubectl -n ${DEVELOPER_NAMESPACE} apply -f /tmp/${WORKLOAD_NAME}-deliverable.yml

kubectl  -n ${DEVELOPER_NAMESPACE} get deliverable 

echo ""
echo "gitops ssh secret(such as git-ssh) should be created manually."