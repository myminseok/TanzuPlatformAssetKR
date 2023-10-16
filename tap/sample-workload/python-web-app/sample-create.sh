#!/bin/bash
DEVELOPER_NAMESPACE=${1:-my-space}

tanzu apps workload delete python-web-app --yes -n ${DEVELOPER_NAMESPACE}
tanzu apps workload apply -f ./workload.yaml -n ${DEVELOPER_NAMESPACE}  --yes