#!/bin/bash
SCRIPTDIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
source $SCRIPTDIR/../common-scripts/common.sh
load_env_file $SCRIPTDIR/../tap-env

DEVELOPER_NAMESPACE=${1:-$DEVELOPER_NAMESPACE}
echo "This script will test namespace: $DEVELOPER_NAMESPACE"

YML_PATH=$SCRIPTDIR/public-blob-source-example.yaml
function cleanup {
  set +e
  kubectl delete -f $YML_PATH -n $DEVELOPER_NAMESPACE
  set -e
}


cleanup
set -x
kubectl apply -f $YML_PATH -n $DEVELOPER_NAMESPACE
set +x

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
  echo "wait for creating resources... for 3 second"
  sleep 3
  kubectl get sourcescan -n $DEVELOPER_NAMESPACE public-blob-source-example  -ojsonpath='{.status.phase}'
  set +x
  if [ "$(kubectl get sourcescan -n $DEVELOPER_NAMESPACE public-blob-source-example -ojsonpath='{.status.phase}')" == "Scanning" ]; then
    kubectl get sourcescan -n $DEVELOPER_NAMESPACE
    echo "SUCCESS created 'sourcescan' for $YML_PATH"
  else 
    kubectl get sourcescan -n $DEVELOPER_NAMESPACE public-blob-source-example  -ojsonpath='{.status}'
    echo "ERROR created 'sourcescan' for $YML_PATH but failed running"  
  fi 
fi

cleanup


### 
## k get sourcescan public-blob-source-example -ojsonpath='{.status.phase}' -n my-space
# k get sourcescan public-blob-source-example -ojsonpath='{.status}' -n my-space | jq .
# {
#   "conditions": [
#     {
#       "lastTransitionTime": "2023-05-16T04:53:04Z",
#       "message": "The scan job is running",
#       "observedGeneration": 1,
#       "reason": "JobStarted",
#       "status": "True",
#       "type": "Scanning"
#     }
#   ],
#   "observedGeneration": 1,
#   "observedTemplateGeneration": 1,
#   "observedTemplateUID": "b46ef6e7-5e4d-4e9b-9aee-ebb1c3e645c2",
#   "phase": "Scanning"
# }


# status:
#   conditions:
#   - error: expected 1 pod, found 0
#     lastTransitionTime: "2023-05-16T04:48:46Z"
#     message: Scan job pod could not be retrieved. expected 1 pod, found 0
#     observedGeneration: 1
#     reason: Error
#     status: "False"
#     type: Succeeded
#   observedGeneration: 1
#   observedTemplateGeneration: 1
#   observedTemplateUID: 404513e0-88e9-4176-9faf-60bfa96b4e03
#   phase: Error

