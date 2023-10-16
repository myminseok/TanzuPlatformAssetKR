#!/bin/bash
DEVELOPER_NAMESPACE=${1:-my-space}

kubectl apply -f ./maven-settings-secret.yml -n ${DEVELOPER_NAMESPACE}
kubectl apply -f ./maven-custom-certs.yml -n ${DEVELOPER_NAMESPACE}
kubectl apply -f ./testing-pipeline-airgapped.yml -n ${DEVELOPER_NAMESPACE}

## this command doesn't have necessary params for register-api, so it will fail to register api to tap-gui.
tanzu apps workload delete tanzu-java-web-app --yes -n ${DEVELOPER_NAMESPACE}
tanzu apps workload create tanzu-java-web-app \
--git-repo https://github.com/myminseok/tanzu-java-web-app \
--git-branch main \
--type web \
--label app.kubernetes.io/part-of=tanzu-java-web-app \
--label apps.tanzu.vmware.com/has-tests=true \
--param-yaml buildServiceBindings='[{"name": "maven-settings", "kind": "Secret"}, {"apiVersion": "v1", "kind": "Secret", "name": "my-ca-certs"}]' \
--service-ref my-ca-certs=v1:Secret:my-ca-certs \
--yes -n ${DEVELOPER_NAMESPACE}
