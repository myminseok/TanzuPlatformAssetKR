#!/bin/bash
SCRIPTDIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
source $SCRIPTDIR/sample-env

DEVELOPER_NAMESPACE=${1:-$DEVELOPER_NAMESPACE}

tanzu apps workload delete ${WORKLOAD_NAME} --yes  -n ${DEVELOPER_NAMESPACE}