#!/bin/bash
DEVELOPER_NAMESPACE=${1:-my-space}
GIT_COMMIT_ID="ef85a459837af3870542afb892539b73313ad324"
## this command doesn't have necessary params for register-api, so it will fail to register api to tap-gui.
tanzu apps workload delete tanzu-java-web-app --yes -n ${DEVELOPER_NAMESPACE}
tanzu apps workload apply tanzu-java-web-app \
-f ./workload-tanzu-java-web-app-gitops-ssh.yaml \
--git-commit $GIT_COMMIT_ID --label workload-commit-id=$GIT_COMMIT_ID \
--yes -n ${DEVELOPER_NAMESPACE}
