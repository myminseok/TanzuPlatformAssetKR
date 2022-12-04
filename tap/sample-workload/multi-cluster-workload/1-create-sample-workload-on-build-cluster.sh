#!/bin/bash
SCRIPTDIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
source $SCRIPTDIR/../sample-env

tanzu apps workload create ${WORKLOAD_NAME} \
--git-repo https://github.com/vmware-tanzu/application-accelerator-samples \
--sub-path ${WORKLOAD_NAME}  \
--git-branch main \
--type web \
--label app.kubernetes.io/part-of=${WORKLOAD_NAME}  \
--yes  -n ${DEVELOPER_NAMESPACE}
