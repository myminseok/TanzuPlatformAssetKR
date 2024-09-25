#!/bin/bash
SCRIPTDIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
source $SCRIPTDIR/common-scripts/common.sh
load_env_file $SCRIPTDIR/tap-env

print_current_k8s

set +e
$SCRIPTDIR/99-delete-tbs-full-deps.sh
set -e

tanzu package installed delete tap -n tap-install $@
set +e
kubectl delete clusterrole/tap-install-cluster-admin-role
kubectl delete clusterrolebinding/tap-install-cluster-admin-role-binding
set -e

