
k get clustersupplychains source-test-scan-to-url -o yaml > source-test-scan-to-url.yml


```
Supply Chain
   name:   source-test-scan-to-url-custom

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