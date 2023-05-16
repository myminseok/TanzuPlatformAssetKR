#!/bin/bash
export SCRIPTDIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
export INSTALL_TAP_DIR=$SCRIPTDIR
source $INSTALL_TAP_DIR/common-scripts/common.sh
load_env_file $SCRIPTDIR/../tap-env

DEVELOPER_NAMESPACE=${1:-$DEVELOPER_NAMESPACE}

echo "This script will test namespace: $DEVELOPER_NAMESPACE"

print_current_k8s

parse_args "$@"

kubectl get clusterbuilder 
if [ $(kubectl get clusterbuilder | grep False | wc -l) -eq 0 ] && [ $(kubectl get clusterbuilder | grep True | wc -l) -gt 0 ]; then
  echo ""
  echo "SUCCESS clusterbuilder is ready."
  echo "================================="
else
  echo ""
  echo "ERROR clusterbuilder is not ready. some stack is 'False' status. reinstall buildservice or reinstall tbs full dependencies"  
  exit 1
fi

set +x
kubectl get secrets gitops-basic -n $DEVELOPER_NAMESPACE
kubectl get secrets gitops-ssh -n $DEVELOPER_NAMESPACE
echo ""

echo ""
echo "================================="
echo "SUCCESS namespace '$DEVELOPER_NAMESPACE' is ready "