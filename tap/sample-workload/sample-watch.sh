#!/bin/bash
SCRIPTDIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
source $SCRIPTDIR/sample-env
watch tanzu apps workload get tanzu-java-web-app -n ${DEVELOPER_NAMESPACE}
