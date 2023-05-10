#!/bin/bash
SCRIPTDIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
source $SCRIPTDIR/common-scripts/common.sh
load_env_file $SCRIPTDIR/tap-env

echo "This script will test namespace: $DEVELOPER_NAMESPACE"

print_current_k8s

parse_args "$@"
# if [ "$YES" != "y" ]; then
#  confirm_target_k8s
# fi

if [ $(kubectl get clusterbuilder | grep False | wc -l) -eq 0 ] && [ $(kubectl get clusterbuilder | grep True | wc -l) -gt 0 ]; then
  kubectl get clusterbuilder
  echo "SUCCESS clusterbuilder is ready."
else
  kubectl get clusterbuilder
  echo "ERROR clusterbuilder is not ready. some stack is 'False' status. reinstall buildservice or reinstall tbs full dependencies"  
  exit 1
fi

kubectl get ScanTemplate -A 
kubectl get ScanPolicy -A
kubectl get Pipeline -A
kubectl get secrets git-ssh -n $DEVELOPER_NAMESPACE

set +e
kubectl delete -f $SCRIPTDIR/test-grype/public-blob-source-example.yaml -n $DEVELOPER_NAMESPACE
set -e

kubectl apply -f $SCRIPTDIR/test-grype/public-blob-source-example.yaml -n $DEVELOPER_NAMESPACE

## successful if taskrun exists.( scan job itself will be failed.)
set -e
if [ $(kubectl get taskrun -n $DEVELOPER_NAMESPACE | grep "scan-public-blob-source-example" | wc -l ) -eq 0 ]; then
  kubectl get taskrun -n $DEVELOPER_NAMESPACE
  set +e
  kubectl delete -f $SCRIPTDIR/test-grype/public-blob-source-example.yaml -n $DEVELOPER_NAMESPACE
  set -e
  echo "ERROR creating 'taskrun' for $SCRIPTDIR/test-grype/public-blob-source-example.yaml failed from scanjob"
  exit 1
else
  kubectl get taskrun -n $DEVELOPER_NAMESPACE
  echo "SUCCESS creating 'taskrun' for $SCRIPTDIR/test-grype/public-blob-source-example.yaml from scanjob"
fi

set +e
kubectl delete -f $SCRIPTDIR/test-grype/public-blob-source-example.yaml -n $DEVELOPER_NAMESPACE
set -e

#kubectl describe sourcescan public-blob-source-example -n $DEVELOPER_NAMESPACE
