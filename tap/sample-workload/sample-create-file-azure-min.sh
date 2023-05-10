#!/bin/bash
export DEVELOPER_NAMESPACE=min
export WORKLOAD_NAME=tanzu-java-web-app
export KUBECONFIG=/Users/kminseok/_dev/tanzu-main/tap-home/TanzuPlatformAssetKR/tap/sample-workload/explore_tap_concierge_kubeconfig
tanzu apps workload delete ${WORKLOAD_NAME} --yes  -n ${DEVELOPER_NAMESPACE}
tanzu apps workload create -f ./workload-tanzu-java-web-app-azure-min.yml --yes   -n ${DEVELOPER_NAMESPACE}
