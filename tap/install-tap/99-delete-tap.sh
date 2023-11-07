#!/bin/bash
SCRIPTDIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
source $SCRIPTDIR/common-scripts/common.sh
load_env_file $SCRIPTDIR/tap-env

print_current_k8s

set +e
kubectl delete secret/scanning-ca-overlay -n tap-install
kubectl delete configmap/scanning-harbor-ca-overlay-cm -n tap-install
set -e

#kubectl edit PackageInstall cnrs -n tap-install
#kapp delete --app tap-ctrl -n tap-install
tanzu package installed delete tap -n tap-install $@
tanzu package installed delete full-tbs-deps -n tap-install -y


set +e
kubectl delete clusterrole/tap-install-cluster-admin-role
kubectl delete clusterrolebinding/tap-install-cluster-admin-role-binding
set -e