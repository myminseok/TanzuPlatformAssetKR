#!/bin/bash
SCRIPTDIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
source $SCRIPTDIR/sample-env

tanzu apps workload delete ${WORKLOAD_NAME} --yes  -n ${DEVELOPER_NAMESPACE}
tanzu apps workload create -f $SCRIPTDIR/workload-tanzu-java-web-app-gitops-ssh.yaml --yes   -n ${DEVELOPER_NAMESPACE}