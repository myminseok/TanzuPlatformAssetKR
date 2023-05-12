#!/bin/bash
export SCRIPTDIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
source $SCRIPTDIR/../common-scripts/common.sh
load_env_file $SCRIPTDIR/../tap-env

verify_tap_env_param "BUILDSERVICE_REGISTRY_HOSTNAME", "$BUILDSERVICE_REGISTRY_HOSTNAME"
verify_tap_env_param "BUILDSERVICE_REGISTRY_USERNAME", "$BUILDSERVICE_REGISTRY_USERNAME"
verify_tap_env_param "BUILDSERVICE_REGISTRY_PASSWORD", "$BUILDSERVICE_REGISTRY_PASSWORD"

print_current_k8s

parse_args "$@"
if [ "$YES" != "y" ]; then
 confirm_target_k8s
fi

set +e
kubectl create ns tap-install
set -e
set -x

if [ "$1" == "-d" ]; then
  tanzu package repository delete  kp-default-repo-secret --namespace tap-install -y 
  tanzu secret registry delete kp-default-repo-secret -n tap-install -y 
fi

tanzu secret registry add kp-default-repo-secret \
    --server   $BUILDSERVICE_REGISTRY_HOSTNAME \
    --username $BUILDSERVICE_REGISTRY_USERNAME \
    --password $BUILDSERVICE_REGISTRY_PASSWORD \
    --namespace tap-install \
    --export-to-all-namespaces \
    --yes


