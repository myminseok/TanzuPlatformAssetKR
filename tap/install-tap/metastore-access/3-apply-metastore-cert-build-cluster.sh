#!/bin/bash
SCRIPTDIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
echo "This script should run on BUILD cluster"

source $SCRIPTDIR/../common-scripts/common.sh
load_env_file $SCRIPTDIR/../tap-env


function verify_file_exist {
  if [ ! -f "$1" ]; then
    echo "!! ERROR: $1 not found"
    echo "  run 2-fetch-metastore-cert-view-cluster.sh first on VIEW cluster"
    echo ""
    exit 1
  fi
}

set +e
kubectl create ns metadata-store-secrets
set -e
STORE_FILE_PATH="/tmp/store_ca.yaml"

verify_file_exist $STORE_FILE_PATH

set +e
kubectl delete -f $STORE_FILE_PATH
set -e
kubectl apply -f $STORE_FILE_PATH

TOKEN_FILE_PATH="/tmp/secret-metadata-store-read-write-client.txt"

verify_file_exist $TOKEN_FILE_PATH

AUTH_TOKEN=$(cat $TOKEN_FILE_PATH)

## verify
if [[ "x$AUTH_TOKEN" == "x" ]]; then
  echo ""
  echo "!! ERROR: $TOKEN_FILE_PATH is invalid. "
  echo "  run 2-fetch-metastore-cert-view-cluster.sh first on VIEW cluster"
  echo ""
  exit 1
fi

set +e
kubectl delete secret  store-auth-token -n metadata-store-secrets
set -e
kubectl create secret generic store-auth-token \
  --from-literal=auth_token=$AUTH_TOKEN -n metadata-store-secrets
