#!/bin/bash
SCRIPTDIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
source $SCRIPTDIR/common-scripts/common.sh
load_env_file $SCRIPTDIR/tap-env


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

kubectl get ScanTemplate -A
if [ $(kubectl get ScanTemplate  -n $DEVELOPER_NAMESPACE | wc -l ) -gt 0 ]; then
  echo ""
  echo "SUCCESS ScanTemplate is ready."
  echo "================================="
else
  echo ""
  echo "ERROR ScanTemplate is not ready. check grype. and setup developer namespace"  
  exit 1
fi



kubectl get ScanPolicy -A
if [ $(kubectl get ScanPolicy  -n $DEVELOPER_NAMESPACE | wc -l ) -gt 0 ]; then
  echo ""
  echo "SUCCESS ScanPolicy is ready."
  echo "================================="
else
  echo ""
  echo "ERROR ScanPolicy is not ready. "  
  exit 1
fi

kubectl get Pipeline -A
if [ $(kubectl get Pipeline  -n $DEVELOPER_NAMESPACE | wc -l ) -gt 0 ]; then
  echo ""
  echo "SUCCESS Pipeline is ready."
  echo "================================="
else
  echo ""
  echo "ERROR Pipeline is not ready"  
  exit 1
fi


set +x
kubectl get secrets gitops-basic -n $DEVELOPER_NAMESPACE
kubectl get secrets gitops-ssh -n $DEVELOPER_NAMESPACE
echo ""
echo "================================="
sh $SCRIPTDIR/test-grype/test-sourcescan.sh

echo ""
echo "================================="
kubectl get sourcescan -A
#kubectl describe sourcescan public-blob-source-example -n $DEVELOPER_NAMESPACE
