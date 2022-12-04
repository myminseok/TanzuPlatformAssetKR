#!/bin/bash
SCRIPTDIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
source $SCRIPTDIR/../sample-env

workload_url=${WORKLOAD_NAME}-${DEVELOPER_NAMESPACE}.${TAP_DOMAIN}

set -x
nslookup $workload_url
curl https://$workload_url -k 
