#!/bin/bash
SCRIPTDIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
source $SCRIPTDIR/common-scripts/common.sh
load_env_file $SCRIPTDIR/tap-env

print_current_k8s

set +e
kubectl delete secret/scanning-ca-overlay -n tap-install
kubectl delete configmap/scanning-harbor-ca-overlay-cm -n tap-install
set -e

tanzu package installed delete full-deps -n tap-install -y

set +e
kubectl delete  clusterrolebinding/full-deps-tap-install-cluster-rolebinding
kubectl delete  clusterrole/full-deps-tap-install-cluster-role
set -e


## kubectl delete ns tbs-full-deps