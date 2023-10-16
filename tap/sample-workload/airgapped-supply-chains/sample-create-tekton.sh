#!/bin/bash
DEVELOPER_NAMESPACE=${1:-my-space}

#kubectl apply -f ./maven-settings-secret.yml -n ${DEVELOPER_NAMESPACE}
#kubectl apply -f ./maven-custom-certs.yml -n ${DEVELOPER_NAMESPACE}
#kubectl apply -f ./testing-pipeline-airgapped.yml -n ${DEVELOPER_NAMESPACE}

## this command doesn't have necessary params for register-api, so it will fail to register api to tap-gui.

tanzu apps workload delete tanzu-java-web-app --yes -n ${DEVELOPER_NAMESPACE}
tanzu apps workload apply -f ../workload-tanzu-java-web-app.yaml --yes   -n ${DEVELOPER_NAMESPACE} \
--git-repo https://github.com/myminseok/tanzu-java-web-app \
--git-branch main \
--type web \
--label app.kubernetes.io/part-of=tanzu-java-web-app \
--label apps.tanzu.vmware.com/has-tests=true 

