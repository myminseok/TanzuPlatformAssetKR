#!/bin/bash
DEVELOPER_NAMESPACE=${1:-my-space}

export KUBECONFIG=/Users/kminseok/_dev/tanzu-main/tap-home/TanzuPlatformAssetKR/tap/sample-workload/explore_tap_concierge_kubeconfig
tanzu apps workload delete tanzu-java-web-app --yes  -n ${DEVELOPER_NAMESPACE}
tanzu apps workload create -f ./workload-tanzu-java-web-app.yml --yes   -n ${DEVELOPER_NAMESPACE}
