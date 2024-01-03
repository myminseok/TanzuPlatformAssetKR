#!/bin/bash
DEVELOPER_NAMESPACE=${1:-default}

tanzu apps workload delete tanzu-java-web-app --yes  -n ${DEVELOPER_NAMESPACE}
tanzu apps workload create -f ./deliverable-tanzu-java-web-app-gitops-ssh.yaml --yes   -n ${DEVELOPER_NAMESPACE}