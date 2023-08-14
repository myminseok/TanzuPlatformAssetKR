#!/bin/bash
SCRIPTDIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
source $SCRIPTDIR/../install-tap/common-scripts/common.sh
load_env_file $SCRIPTDIR/tap-env
DEVELOPER_NAMESPACE=${1:-$DEVELOPER_NAMESPACE}



tanzu apps workload delete tanzu-java-web-app --yes  -n ${DEVELOPER_NAMESPACE}
tanzu apps workload create -f $SCRIPTDIR/deliverable-tanzu-java-web-app-gitops-ssh.yaml --yes   -n ${DEVELOPER_NAMESPACE}