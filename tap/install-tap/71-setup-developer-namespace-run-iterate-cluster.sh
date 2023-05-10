#!/bin/bash
SCRIPTDIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
source $SCRIPTDIR/common-scripts/common.sh
load_env_file $SCRIPTDIR/tap-env




verify_tap_env_param "DEVELOPER_NAMESPACE", "$DEVELOPER_NAMESPACE"
verify_tap_env_param "BUILDSERVICE_REGISTRY_HOSTNAME", "$BUILDSERVICE_REGISTRY_HOSTNAME"
verify_tap_env_param "BUILDSERVICE_REGISTRY_USERNAME", "$BUILDSERVICE_REGISTRY_USERNAME"
verify_tap_env_param "BUILDSERVICE_REGISTRY_PASSWORD", "$BUILDSERVICE_REGISTRY_PASSWORD"

echo "==============================================================="
echo "[MANUAL] update following files before running this script"
echo "---------------------------------------------------------------"
echo "$TAP_ENV_DIR/git-ssh-secret-basic.yml"
echo ""
echo "---------------------------------------------------------------"
echo "This script should run on RUN cluster"
print_current_k8s
echo ""
echo "DEVELOPER_NAMESPACE: $DEVELOPER_NAMESPACE"



parse_args "$@"
if [ "$YES" != "y" ]; then
 confirm_target_k8s
fi

set +e
## https://docs.vmware.com/en/VMware-Tanzu-Application-Platform/1.5/tap/namespace-provisioner-customize-installation.html#con-label-selector
kubectl create ns $DEVELOPER_NAMESPACE 
kubectl label namespace "$DEVELOPER_NAMESPACE" apps.tanzu.vmware.com/tap-ns=$DEVELOPER_NAMESPACE
set -e

set -x

set +e
tanzu secret registry delete registry-credentials -n $DEVELOPER_NAMESPACE -y
set -e
tanzu secret registry add registry-credentials --server $BUILDSERVICE_REGISTRY_HOSTNAME  --username $BUILDSERVICE_REGISTRY_USERNAME --password $BUILDSERVICE_REGISTRY_PASSWORD --namespace $DEVELOPER_NAMESPACE
kubectl apply -f $SCRIPTDIR/setup-developer-namespace/rbac-developer-namespace.yml -n $DEVELOPER_NAMESPACE

set +e
kubectl delete -f $TAP_ENV_DIR/git-ssh-secret-basic.yml -n $DEVELOPER_NAMESPACE
set -e
kubectl apply -f $TAP_ENV_DIR/git-ssh-secret-basic.yml -n $DEVELOPER_NAMESPACE

