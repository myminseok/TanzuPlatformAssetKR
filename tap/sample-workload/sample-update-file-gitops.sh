#!/bin/bash
SCRIPTDIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
source $SCRIPTDIR/sample-env

tanzu apps workload apply -f $SCRIPTDIR/workload-tanzu-java-web-app-gitops.yaml --yes   -n ${DEVELOPER_NAMESPACE}