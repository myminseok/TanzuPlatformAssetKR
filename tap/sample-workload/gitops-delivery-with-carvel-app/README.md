

### setup build cluster for Carvel Package Supply Chains
build cluster setup guide: https://docs.vmware.com/en/VMware-Tanzu-Application-Platform/1.8/tap/scc-carvel-package-supply-chain.html


app will be built on build cluster 
- sample workload.yml https://github.com/myminseok/TanzuPlatformAssetKR/blob/37f0d686d83adbbbf2066b800f4ab9cbe1856f84/tap/sample-workload/tanzu-java-web-app-workload/workload-tanzu-java-web-app-carvelpackage.yaml#L10


and  build cluster will create:
- configmap for app. it will have deployment, service, etc that will be stamped out from clusterconfigtemplate
```
k get clusterconfigtemplate  server-template -o yaml  > buildcluster-clusterconfigtemplate.yml    

k get clusterconfigtemplate  server-template  -o jsonpath='{.spec.ytt}' > buildcluster-clusterconfigtemplate-server-template.yml

k get configmap -n my-space tanzu-java-web-app-server  -o yaml> buildcluster-configmap-tanzu-java-web-app-server.yml
```
- carvel-package task on supplychain on buildcluster will push package artifacts yaml on gitops repo:
>>> samples gitops repo: https://github.com/myminseok/tap-gitops-repo/tree/main/scc-deliveryhomelab



### deploy the app using gitops delivery with a Carvel app (beta)
setup guide: https://docs.vmware.com/en/VMware-Tanzu-Application-Platform/1.8/tap/scc-delivery-with-carvel-app.html

- prepare run cluster and namespace including service account, role, rolebinding. see [README.md](./tap-gitops-repo/scc-deliveryhomelab/run-on-clusters-manually/README.md)
- define [packageinstall.yaml](./tap-gitops-repo/scc-deliveryhomelab/tanzu-java-web-app.my-space.tap/homelab-run-space/packageinstall.yaml) with [params.yaml](./tap-gitops-repo/scc-deliveryhomelab/tanzu-java-web-app.my-space.tap/homelab-run-space/params.yaml) for replicas and route url for app deployment.
- define [carvel-app-packages.yaml](./tap-gitops-repo/scc-deliveryhomelab/run-on-clusters-manually/carvel-app-packages-on-buildcluster.yml) that describe how to deploy packages from gitops repo  to a target space on run cluster.
- define [carvel-app-target-space.yaml](./tap-gitops-repo/scc-deliveryhomelab/run-on-clusters-manually/carvel-app-packages-on-buildcluster.yml) that describe how to deploy [packageinstall.yaml](./tap-gitops-repo/scc-deliveryhomelab/tanzu-java-web-app.my-space.tap/homelab-run-space/packageinstall.yaml) with [params.yaml] from gitops repo to a target space on run cluster. and deploy on any cluster where that has network connection to gitops repo and run cluster.

then the carvel app will deploy packages, packageinstall on target cluster which will stampout deployment and services for the app.
