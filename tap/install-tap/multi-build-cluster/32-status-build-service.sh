#!/bin/bash
export SCRIPTDIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
source $SCRIPTDIR/../common-scripts/common.sh
load_env_file $SCRIPTDIR/../tap-env

print_current_k8s

kubectl get app -n tap-install buildservice
kubectl get app -n tap-install full-tbs-deps

if [ $(kubectl get clusterbuilder | grep False | wc -l) -eq 0 ] && [ $(kubectl get clusterbuilder | grep True | wc -l) -gt 0 ]; then
  kubectl get clusterbuilder
  echo "SUCCESS clusterbuilder is ready."
else
  kubectl get clusterbuilder
  echo "ERROR clusterbuilder is not ready. some stack is 'False' status. reinstall buildservice or reinstall tbs full dependencies"  
  exit 1
fi