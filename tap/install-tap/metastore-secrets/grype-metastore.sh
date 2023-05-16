#!/bin/bash
SCRIPTDIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
source $SCRIPTDIR/../common-scripts/common.sh
load_env_file $SCRIPTDIR/../tap-env

DEVELOPER_NAMESPACE=${1:-$DEVELOPER_NAMESPACE}
echo "This script should run on BUILD cluster for namespace: $DEVELOPER_NAMESPACE"

set +e
kubectl create ns $DEVELOPER_NAMESPACE
kubectl create ns metadata-store-secrets
set -e

cp $SCRIPTDIR/grype-metadatastore.yml.template /tmp/grype-metadatastore.yml
sed -i -r "s/DEVELOPER_NAMESPACE/${DEVELOPER_NAMESPACE}/g" /tmp/grype-metadatastore.yml

set +e
kubectl delete -f /tmp/grype-metadatastore.yml
set -e
kubectl apply -f /tmp/grype-metadatastore.yml
echo ""
## verify
kubectl get secretexports -A
#kubectl get secretexports -n metadata-store-secrets store-auth-token -o yaml
