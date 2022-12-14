#!/bin/bash
SCRIPTDIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
source $SCRIPTDIR/common-scripts/common.sh
load_env_file $SCRIPTDIR/tap-env

echo "This script should run on BUILD/FULL cluster"

verify_tap_env_param "DEVELOPER_NAMESPACE", "$DEVELOPER_NAMESPACE"
verify_tap_env_param "BUILDSERVICE_REGISTRY_HOSTNAME", "$BUILDSERVICE_REGISTRY_HOSTNAME"
verify_tap_env_param "BUILDSERVICE_REGISTRY_USERNAME", "$BUILDSERVICE_REGISTRY_USERNAME"
verify_tap_env_param "BUILDSERVICE_REGISTRY_PASSWORD", "$BUILDSERVICE_REGISTRY_PASSWORD"

echo "==============================================================="
echo "[MANUAL] edit followiing files before running this script"
echo "---------------------------------------------------------------"
echo "$TAP_ENV_DIR/scan-policy.yml"
echo "$TAP_ENV_DIR/testing-pipeline.yml"
echo "$TAP_ENV_DIR/git-ssh-secret-basic.yml"
echo ""

print_current_k8s

parse_args "$@"
if [ "$YES" != "y" ]; then
 confirm_target_k8s
fi

set +e
kubectl create ns $DEVELOPER_NAMESPACE 
set -e

set -x

set +e
tanzu secret registry delete registry-credentials -n $DEVELOPER_NAMESPACE -y
set -e
tanzu secret registry add registry-credentials --server $BUILDSERVICE_REGISTRY_HOSTNAME  --username $BUILDSERVICE_REGISTRY_USERNAME --password $BUILDSERVICE_REGISTRY_PASSWORD --namespace $DEVELOPER_NAMESPACE
kubectl apply -f $SCRIPTDIR/setup-developer-namespace/rbac-developer-namespace.yml -n $DEVELOPER_NAMESPACE


kubectl apply -f $TAP_ENV_DIR/scan-policy.yml  -n $DEVELOPER_NAMESPACE
kubectl apply -f $TAP_ENV_DIR/testing-pipeline.yml  -n $DEVELOPER_NAMESPACE
set +e
kubectl delete -f $TAP_ENV_DIR/git-ssh-secret-basic.yml -n $DEVELOPER_NAMESPACE
set -e
kubectl apply -f $TAP_ENV_DIR/git-ssh-secret-basic.yml -n $DEVELOPER_NAMESPACE

## TODO: only for pvc testing...
# kubectl apply -f $SCRIPTDIR/setup-developer-namespace/rbac-developer-namespace-podintent.yml -n $DEVELOPER_NAMESPACE

