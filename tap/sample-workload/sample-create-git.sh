
## this command doesn't have necessary params for register-api, so it will fail to register api to tap-gui.
tanzu apps workload delete tanzu-java-web-app --yes -n demo-app
tanzu apps workload create tanzu-java-web-app \
--git-repo https://github.com/myminseok/tanzu-java-web-app \
--git-branch main \
--type web \
--label app.kubernetes.io/part-of=tanzu-java-web-app \
--label apps.tanzu.vmware.com/has-tests=true \
--label apis.apps.tanzu.vmware.com/register-api="true" \
--yes -n demo-app
##watch kubectl get workload,gitrepository,pipelinerun,images.kpack,podintent,app,services.serving -n demo-app
