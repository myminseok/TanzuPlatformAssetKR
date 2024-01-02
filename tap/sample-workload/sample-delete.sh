#!/bin/bash
DEVELOPER_NAMESPACE=${2:-my-space}
tanzu apps workload delete $1 --yes  -n ${DEVELOPER_NAMESPACE}
