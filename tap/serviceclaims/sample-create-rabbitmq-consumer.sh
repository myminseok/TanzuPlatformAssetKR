tanzu apps workload delete spring-sensors-consumer-web -y
tanzu apps workload create spring-sensors-consumer-web \
  --git-repo https://github.com/tanzu-end-to-end/spring-sensors \
  --git-branch rabbit \
  --type web \
  --label apps.tanzu.vmware.com/workload-type=web \
  --label app.kubernetes.io/part-of=spring-sensors \
  --label apps.tanzu.vmware.com/has-tests=true \
  --annotation autoscaling.knative.dev/minScale=1 \
  --service-ref="rmq=services.apps.tanzu.vmware.com/v1alpha1:ResourceClaim:rmq-1"
