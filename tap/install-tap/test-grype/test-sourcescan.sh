#!/bin/bash
SCRIPTDIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
source $SCRIPTDIR/../common-scripts/common.sh
load_env_file $SCRIPTDIR/../tap-env


YML_PATH=$SCRIPTDIR/public-blob-source-example.yaml
function cleanup {
  set +e
  kubectl delete -f $YML_PATH -n $DEVELOPER_NAMESPACE
  set -e
}


cleanup

kubectl apply -f $YML_PATH -n $DEVELOPER_NAMESPACE

## successful if taskrun exists.( scan job itself will be failed.)
set -e
if [ $(kubectl get taskrun -n $DEVELOPER_NAMESPACE | grep "scan-public-blob-source-example" | wc -l ) -eq 0 ]; then
  kubectl get taskrun -n $DEVELOPER_NAMESPACE
  set +e
  kubectl delete -f $YML_PATH -n $DEVELOPER_NAMESPACE
  set -e
  echo "ERROR creating 'taskrun' for $YML_PATH failed from scanjob"
  exit 1
else
  kubectl get taskrun -n $DEVELOPER_NAMESPACE
  echo "SUCCESS creating 'taskrun' for $YML_PATH from scanjob"
fi

cleanup