#!/bin/bash
SCRIPTDIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
source $SCRIPTDIR/../../install-tap/common-scripts/common.sh
load_env_file $SCRIPTDIR/tap-env
DEVELOPER_NAMESPACE=${1:-$DEVELOPER_NAMESPACE}

WORKLOAD_NAME="tanzu-java-web-app"
tanzu apps workload create ${WORKLOAD_NAME} \
--git-repo https://github.com/vmware-tanzu/application-accelerator-samples \
--sub-path ${WORKLOAD_NAME}  \
--git-branch main \
--type web \
--label app.kubernetes.io/part-of=${WORKLOAD_NAME}  \
--label apps.tanzu.vmware.com/has-tests=true \
--yes  -n ${DEVELOPER_NAMESPACE}
