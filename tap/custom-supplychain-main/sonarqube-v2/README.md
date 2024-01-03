
## sonarqube source scan testing


refer to https://github.com/x95castle1/custom-cartographer-supply-chain-examples/tree/main/code-analysis repo to setup environment.

1. will duplicate existing `source-test-scan-to-url` clustersupplychain and modify. `apps.tanzu.vmware.com/use-sonarqube: "true"` label in workload.yaml will help match the right supplychain.
2. you needs to set permission to serviceaccount to list `Task` resources=> rbac.yml
3. you have to prepare sonarqube server. (https://docs.sonarsource.com/sonarqube/latest/setup-and-upgrade/deploy-on-kubernetes/deploy-sonarqube-on-kubernetes/)
4. limitation as of TAP 1.6) sonar source scan result will be saved to sonarqube server. there is no resport in TAP-GUI.
5. limitation as of TAP 1.6) TAP-gui doesn't visualize the parallel tasks.
6. limitation) this custom supplychain includes environment specific information on each installation. it means you have to modify manually or use overlay mechanism.

```
k get clustersupplychains source-test-scan-to-url -o yaml > source-test-scan-to-url.yml
```
and update `source-test-scan-to-url-sonarqube.yml` for parameters according to you environment.
* WARNING: please note that modifying OOTB supply-chain such as `source-test-scan-to-url` will be revered back on future TAP upgrade.
```
export DEVELOPER_NAMESPACE=my-space

k apply -f task.yml -n $DEVELOPER_NAMESPACE
k apply -f cluster-run-template.yml -n $DEVELOPER_NAMESPACE
k apply -f cluster-source-template.yml -n $DEVELOPER_NAMESPACE
k apply -f source-test-scan-to-url-sonarqube.yml 
k apply -f rbac.yml -n $DEVELOPER_NAMESPACE
```

```
tanzu apps workload apply -f ./workload-tanzu-java-web-app.yaml-sample --yes   -n ${DEVELOPER_NAMESPACE}
```

supply chain.
```
Supply Chain
   name:   source-test-scan-to-url-sonarqube

   NAME               READY   HEALTHY   UPDATED   RESOURCE
   source-provider    True    True      32m       imagerepositories.source.apps.tanzu.vmware.com/tanzu-java-web-app
   source-tester      True    True      31m       runnables.carto.run/tanzu-java-web-app
   sonarqube-scan     True    True      16m       runnables.carto.run/tanzu-java-web-app-code-analysis
   image-provider     True    True      7m        images.kpack.io/tanzu-java-web-app
   image-scanner      True    True      6m6s      imagescans.scanning.apps.tanzu.vmware.com/tanzu-java-web-app
   config-provider    True    True      5m58s     podintents.conventions.carto.run/tanzu-java-web-app
   app-config         True    True      5m58s     configmaps/tanzu-java-web-app
   service-bindings   True    True      5m58s     configmaps/tanzu-java-web-app-with-claims
   api-descriptors    True    True      5m58s     configmaps/tanzu-java-web-app-with-api-descriptors
   config-writer      True    True      87s       runnables.carto.run/tanzu-java-web-app-config-writer

```