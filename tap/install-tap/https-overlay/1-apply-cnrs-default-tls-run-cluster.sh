#!/bin/bash
export SCRIPTDIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
source $SCRIPTDIR/../common-scripts/common.sh
load_env_file $SCRIPTDIR/../tap-env

echo "This script should run on RUN cluster"

kubectl create secret generic cnrs-default-tls-overlay -n tap-install \
  -o yaml \
  --dry-run=client \
  --from-file=$SCRIPTDIR/cnrs-default-tls.yml \
  | kubectl apply -f-

# ## added in TAP 1.7??
# kubectl apply -f $SCRIPTDIR/delegation-cnrs-default-tls.yml

kubectl get secret  cnrs-default-tls-overlay -n tap-install

echo "---------------------------------------------------------------------------------------"
echo "[ATTENTION]:  CA for app workload domain on RUN cluster will be created AFTER TAP update completes with 'package_overlays'"
echo "---------------------------------------------------------------------------------------"
echo "    kubectl get secret -n tanzu-system-ingress cnrs-ca -o yaml -ojsonpath='{.data.ca\.crt}' | base64 -d"


