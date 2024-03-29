#!/bin/bash
SCRIPTDIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
source $SCRIPTDIR/../install-tap/common-scripts/common.sh
load_env_file $SCRIPTDIR/tap-env
DEVELOPER_NAMESPACE=${1:-$DEVELOPER_NAMESPACE}


tanzu apps workload apply -f $SCRIPTDIR/workload-tanzu-java-web-app-gitops.yaml --yes   -n ${DEVELOPER_NAMESPACE}