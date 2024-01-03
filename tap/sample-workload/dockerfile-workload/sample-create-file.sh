#!/bin/bash
DEVELOPER_NAMESPACE=${1:-my-space}

tanzu apps workload delete matrix-dockerfile --yes -n ${DEVELOPER_NAMESPACE}
tanzu apps workload apply -f ./workload-dockerfile.yaml --yes   -n ${DEVELOPER_NAMESPACE}
