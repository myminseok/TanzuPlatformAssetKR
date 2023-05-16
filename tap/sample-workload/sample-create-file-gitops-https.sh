#!/bin/bash
SCRIPTDIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
source $SCRIPTDIR/../install-tap/common-scripts/common.sh
load_env_file $SCRIPTDIR/tap-env
DEVELOPER_NAMESPACE=${1:-$DEVELOPER_NAMESPACE}


tanzu apps workload delete ${WORKLOAD_NAME} --yes  -n ${DEVELOPER_NAMESPACE}
tanzu apps workload create -f $SCRIPTDIR/workload-tanzu-java-web-app-gitops-https.yaml --yes   -n ${DEVELOPER_NAMESPACE}