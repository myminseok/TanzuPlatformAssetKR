#!/bin/bash
DEVELOPER_NAMESPACE=${1:-my-space}

tanzu apps workload delete tanzu-java-web-app-cluster-local --yes -n ${DEVELOPER_NAMESPACE}
tanzu apps workload apply -f ./workload-tanzu-java-web-app-cluster-local.yaml --yes   -n ${DEVELOPER_NAMESPACE}


## kubectl get cm -n my-space tanzu-java-web-app-deliverable -o jsonpath='{.data.deliverable}' > ./tanzu-java-web-app-deliverable.yml