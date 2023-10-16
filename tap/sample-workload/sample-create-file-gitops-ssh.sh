#!/bin/bash
DEVELOPER_NAMESPACE=${1:-my-space}

tanzu apps workload delete ${WORKLOAD_NAME} --yes  -n ${DEVELOPER_NAMESPACE}
tanzu apps workload create -f $SCRIPTDIR/workload-tanzu-java-web-app-gitops-ssh.yaml --yes   -n ${DEVELOPER_NAMESPACE}