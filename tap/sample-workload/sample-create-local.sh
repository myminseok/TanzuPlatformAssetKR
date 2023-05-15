#!/bin/bash
SCRIPTDIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
source $SCRIPTDIR/sample-env

tanzu apps workload delete tanzu-java-web-app --yes -n ${DEVELOPER_NAMESPACE}
tanzu apps workload apply --file ./tanzu-java-web-app/config/workload.yaml \
	-n ${DEVELOPER_NAMESPACE} \
	--source-image harbor.h2o-2-2257.h2o.vmware.com/tap/tanzu-java-web-app-source-image \
	--debug --yes --local-path ./tanzu-java-web-app

