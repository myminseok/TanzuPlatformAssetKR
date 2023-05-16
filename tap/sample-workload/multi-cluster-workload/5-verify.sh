#!/bin/bash
SCRIPTDIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
source $SCRIPTDIR/../../install-tap/common-scripts/common.sh
load_env_file $SCRIPTDIR/tap-env
DEVELOPER_NAMESPACE=${1:-$DEVELOPER_NAMESPACE}

WORKLOAD_NAME="tanzu-java-web-app"

workload_url=${WORKLOAD_NAME}-${DEVELOPER_NAMESPACE}.${TAP_DOMAIN}

set -x
nslookup $workload_url
curl https://$workload_url -k 
