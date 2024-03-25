#!/bin/bash
SCRIPTDIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
source $SCRIPTDIR/../../install-tap/common-scripts/common.sh
load_env_file $SCRIPTDIR/tap-env

set -x

DEVELOPER_NAMESPACE=${1:-$DEVELOPER_NAMESPACE}

if [ -f $TAP_ENV_DIR/gitops-ssh-secret-ssh.yml ]; then
  echo ""
  echo "---------------------------------------------------------------------------------------"
  echo " applying $TAP_ENV_DIR/gitops-ssh-secret-ssh.yml "
  ## donot delete the service account, it will revert following changes by namespace-provisioner. use overlay
  kubectl apply -f $TAP_ENV_DIR/gitops-ssh-secret-ssh.yml -n $DEVELOPER_NAMESPACE 
  kubectl get secrets gitops-ssh -n $DEVELOPER_NAMESPACE
fi

if [ -f $TAP_ENV_DIR/gitops-ssh-secret-basic.yml ]; then
  echo ""
  echo "---------------------------------------------------------------------------------------"
  echo " applying $TAP_ENV_DIR/gitops-ssh-secret-basic.yml "
  ## donot delete the service account, it will revert following changes by namespace-provisioner. use overlay
  kubectl apply -f $TAP_ENV_DIR/gitops-ssh-secret-basic.yml -n $DEVELOPER_NAMESPACE
  kubectl get secrets gitops-basic -n $DEVELOPER_NAMESPACE
fi