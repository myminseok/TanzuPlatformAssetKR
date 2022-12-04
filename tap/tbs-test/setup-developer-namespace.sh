#!/bin/bash

source ./tap-env

tanzu secret registry delete registry-credentials -y -n tbs-test

tanzu secret registry add registry-credentials --server $INSTALL_REGISTRY_HOSTNAME  --username $INSTALL_REGISTRY_USERNAME --password $INSTALL_REGISTRY_PASSWORD --namespace tbs-test

kubectl apply -f setup-developer-namespace.yml -n tbs-test
