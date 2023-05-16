#!/bin/bash
SCRIPTDIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
source $SCRIPTDIR/../install-tap/common-scripts/common.sh
load_env_file $SCRIPTDIR/tap-env
DEVELOPER_NAMESPACE=${1:-$DEVELOPER_NAMESPACE}


tanzu apps workload get tanzu-java-web-app -n ${DEVELOPER_NAMESPACE}
#kubectl get gitrepository.source.toolkit.fluxcd.io/tanzu-java-web-app -o yaml --show-managed-fields=false
#kubectl get image.kpack.io/tanzu-java-web-app -o yaml
#kubectl get podintent.conventions.apps.tanzu.vmware.com/tanzu-java-web-app -o yaml

kubectl get clustersupplychains,workload,gitrepository,scantemplate,pipelinerun,images.kpack,podintent,app,services.serving -n ${DEVELOPER_NAMESPACE}

#k logs tanzu-java-web-app-8jvsk-test-pod -c step-test -f
