#!/bin/bash
DEVELOPER_NAMESPACE=${1:-my-space}

tanzu apps workload delete tanzu-java-web-app --yes -n ${DEVELOPER_NAMESPACE}
tanzu apps workload create -f ./workload-tanzu-java-web-app-gitops-ssh.yaml --yes   -n ${DEVELOPER_NAMESPACE}