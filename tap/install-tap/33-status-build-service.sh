#!/bin/bash
SCRIPTDIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
source $SCRIPTDIR/common-scripts/common.sh
load_env_file $SCRIPTDIR/tap-env

print_current_k8s

kubectl get app -n tap-install buildservice
kubectl get app -n tap-install full-tbs-deps

kubectl get clusterbuilder

