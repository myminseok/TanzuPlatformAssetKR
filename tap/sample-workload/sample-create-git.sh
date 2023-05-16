#!/bin/bash
SCRIPTDIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
source $SCRIPTDIR/../install-tap/common-scripts/common.sh
load_env_file $SCRIPTDIR/tap-env
DEVELOPER_NAMESPACE=${1:-$DEVELOPER_NAMESPACE}


## this command doesn't have necessary params for register-api, so it will fail to register api to tap-gui.
tanzu apps workload delete tanzu-java-web-app --yes -n ${DEVELOPER_NAMESPACE}
tanzu apps workload create tanzu-java-web-app \
--git-repo https://github.com/myminseok/tanzu-java-web-app \
--git-branch main \
--type web \
--label app.kubernetes.io/part-of=tanzu-java-web-app \
--label apps.tanzu.vmware.com/has-tests=true \
--label apis.apps.tanzu.vmware.com/register-api="true" \
--yes -n ${DEVELOPER_NAMESPACE}
##watch kubectl get workload,gitrepository,pipelinerun,images.kpack,podintent,app,services.serving -n ${DEVELOPER_NAMESPACE}
