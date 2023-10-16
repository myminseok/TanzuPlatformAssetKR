#!/bin/bash
DEVELOPER_NAMESPACE=${1:-my-space}
tanzu apps workload delete ${WORKLOAD_NAME} --yes  -n ${DEVELOPER_NAMESPACE}