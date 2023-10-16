#!/bin/bash
DEVELOPER_NAMESPACE=${1:-my-space}

#tanzu apps workload delete tanzu-java-web-app --yes -n ${DEVELOPER_NAMESPACE}
tanzu apps workload apply --file $SCRIPTDIR/workload-tanzu-java-web-app.yaml \
	-n ${DEVELOPER_NAMESPACE} \
	--debug --yes --local-path ./tanzu-java-web-app

