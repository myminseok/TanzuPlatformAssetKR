#!/bin/bash
SCRIPTDIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
source $SCRIPTDIR/../common-scripts/common.sh
load_env_file $SCRIPTDIR/../tap-env

DEVELOPER_NAMESPACE=${1:-$DEVELOPER_NAMESPACE}
echo "This script should run on BUILD cluster for namespace: $DEVELOPER_NAMESPACE"

cp $SCRIPTDIR/grype-metastore-overlay-add-developer-namespace.yml.template /tmp/grype-metastore-overlay-add-developer-namespace.yml
sed -i -r "s/DEVELOPER_NAMESPACE/${DEVELOPER_NAMESPACE}/g" /tmp/grype-metastore-overlay-add-developer-namespace.yml


function apply {

    SECRET_NAME=$1

    kubectl get  secretexport ${SECRET_NAME} -n metadata-store-secrets -o yaml >/tmp/${SECRET_NAME}__metadata-store-secrets.yml 
    ytt -f /tmp/${SECRET_NAME}__metadata-store-secrets.yml  -f /tmp/grype-metastore-overlay-add-developer-namespace.yml | kubectl apply -f -
    if [ $(kubectl get secretexport ${SECRET_NAME} -n metadata-store-secrets -o yaml | grep $DEVELOPER_NAMESPACE | wc -l) -gt 0 ]; then
        echo "================================="
        echo "kubectl get secretexport ${SECRET_NAME} -n metadata-store-secrets -o yaml"
        echo "SUCCESS adding namespace ${DEVELOPER_NAMESPACE} to secretexport ${SECRET_NAME}"
        
    else 
        kubectl get secretexport ${SECRET_NAME} -n metadata-store-secrets -o yaml
        echo "================================="
        echo "kubectl get secretexport ${SECRET_NAME} -n metadata-store-secrets -o yaml"
        echo "ERROR Failed to add namespace ${DEVELOPER_NAMESPACE} to secretexport ${SECRET_NAME}"
        exit 1
    fi 

}

apply "store-ca-cert"

apply "store-auth-token"
