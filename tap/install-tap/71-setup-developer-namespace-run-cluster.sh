#!/bin/bash
SCRIPTDIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
source $SCRIPTDIR/common-scripts/common.sh
load_env_file $SCRIPTDIR/tap-env

if [ "$YES" != "y" ]; then
 confirm_target_k8s
fi

set +e
kubectl create ns $DEVELOPER_NAMESPACE 
set -e

set -x

tanzu secret registry delete registry-credentials -n $DEVELOPER_NAMESPACE -y
tanzu secret registry add registry-credentials --server $BUILDSERVICE_REGISTRY_HOSTNAME  --username $BUILDSERVICE_REGISTRY_USERNAME --password $BUILDSERVICE_REGISTRY_PASSWORD --namespace $DEVELOPER_NAMESPACE
kubectl apply -f $SCRIPTDIR/setup-developer-namespace/rbac-developer-namespace.yml -n $DEVELOPER_NAMESPACE

## TODO: only for pvc testing...
# kubectl apply -f $SCRIPTDIR/setup-developer-namespace/rbac-developer-namespace-podintent.yml -n $DEVELOPER_NAMESPACE

echo "==============================================================="
echo "Manual GITOPS configuration ..."
echo "---------------------------------------------------------------"
echo "cp $SCRIPTDIR/setup-developer-namespace/gitops-ssh-secret-basic.yml.template /any/path/gitops-ssh-secret-basic.yml"
echo "edit /any/path/gitops-ssh-secret-basic.yml"
echo "kubectl apply -f /any/path/gitops-ssh-secret-basic.yml -n $DEVELOPER_NAMESPACE"
echo "use the secret to workload.yml"
echo ""
