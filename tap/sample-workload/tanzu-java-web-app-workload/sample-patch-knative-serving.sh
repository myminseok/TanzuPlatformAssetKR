#!/bin/bash
SCRIPTDIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
source $SCRIPTDIR/../install-tap/common-scripts/common.sh
load_env_file $SCRIPTDIR/tap-env
DEVELOPER_NAMESPACE=${1:-$DEVELOPER_NAMESPACE}


kubectl patch configmap config-domain -n knative-serving \
--type merge --patch '{"data":{"apps.tap.example.com":""}}'
