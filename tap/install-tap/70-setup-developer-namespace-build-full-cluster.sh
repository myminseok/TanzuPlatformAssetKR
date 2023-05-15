#!/bin/bash
SCRIPTDIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
source $SCRIPTDIR/common-scripts/common.sh
load_env_file $SCRIPTDIR/tap-env

DEVELOPER_NAMESPACE=${1:-$DEVELOPER_NAMESPACE}

verify_tap_env_param "DEVELOPER_NAMESPACE", "$DEVELOPER_NAMESPACE"
verify_tap_env_param "BUILDSERVICE_REGISTRY_HOSTNAME", "$BUILDSERVICE_REGISTRY_HOSTNAME"
verify_tap_env_param "BUILDSERVICE_REGISTRY_USERNAME", "$BUILDSERVICE_REGISTRY_USERNAME"
verify_tap_env_param "BUILDSERVICE_REGISTRY_PASSWORD", "$BUILDSERVICE_REGISTRY_PASSWORD"

echo "==============================================================="
echo "[MANUAL] update following files before running this script"
echo "---------------------------------------------------------------"
echo "$TAP_ENV_DIR/scan-policy.yml"
echo "$TAP_ENV_DIR/testing-pipeline.yml"
echo "$TAP_ENV_DIR/gitops-ssh-secret-basic.yml"
echo ""
echo "---------------------------------------------------------------"
echo "This script should run on BUILD/FULL cluster"
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
set -e


set +e
## https://docs.vmware.com/en/VMware-Tanzu-Application-Platform/1.5/tap/namespace-provisioner-customize-installation.html#con-label-selector
kubectl label namespace "$DEVELOPER_NAMESPACE" apps.tanzu.vmware.com/tap-ns=$DEVELOPER_NAMESPACE
set -e

sh $SCRIPTDIR/setup-developer-namespace/gitops-ssh.sh $DEVELOPER_NAMESPACE

kubectl apply -f "$TAP_ENV_DIR/scan-policy.yml" -n $DEVELOPER_NAMESPACE
kubectl apply -f "$TAP_ENV_DIR/testing-pipeline.yml"  -n $DEVELOPER_NAMESPACE


## OPTIONAL
if [ ! -z "$BUILDSERVICE_REGISTRY_CA_CERTIFICATE" ]; then
  echo "creating scanning-ca-overlay. (BUILDSERVICE_REGISTRY_CA_CERTIFICATE env found from $TAP_ENV)"
  run_script "$SCRIPTDIR/scanning-overlay/scanning-ca-overlay.sh" $DEVELOPER_NAMESPACE
fi


# ## OPTIONAL
# set +e
# tanzu secret registry delete registry-credentials -n $DEVELOPER_NAMESPACE -y
# set -e
# tanzu secret registry add registry-credentials --server $BUILDSERVICE_REGISTRY_HOSTNAME  --username $BUILDSERVICE_REGISTRY_USERNAME --password $BUILDSERVICE_REGISTRY_PASSWORD --namespace $DEVELOPER_NAMESPACE



## TODO: only for pvc testing...
# kubectl apply -f $SCRIPTDIR/setup-developer-namespace/rbac-developer-namespace-podintent.yml -n $DEVELOPER_NAMESPACE