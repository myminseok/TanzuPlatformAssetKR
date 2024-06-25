
# customizing server-workload type
this sample elaborates from [official guide](https://docs.vmware.com/en/VMware-Tanzu-Reference-Architecture/services/tanzu-solutions-workbooks/solution-workbooks-tap-workloads-avi-l4-l7.html
) and added some opinions

install yq on your PC.


1. Save the existing server-template in a local file. [server-template.yml](./default-server-template-files/server-template.yml)
```
kubectl get ClusterConfigTemplate server-template -o yaml > server-template.yml
```
2. Extract the .spec.ytt field from this file and create another file [server-template-spec-ytt.yml](./default-server-template-files/server-template-spec-ytt.yml)
```
kubectl get ClusterConfigTemplate server-template -o yaml -ojsonpath='{.spec.ytt}' > server-template-spec-ytt.yml
```
or
```
yq eval '.spec.ytt' ./server-template.yml > server-template-spec-ytt.yml
```

3. customize server-template-spec-ytt.yml to custom-server-template-spec-ytt.yml
```
cp server-template-spec-ytt.yml custom-server-template-spec-ytt.yml
```
and app/update/remove deployment/service configs. for example, in the following snippets, added 'replicas' param under 'spec', which will take params 'replicas' from workload.yml 

```
...
#@ def delivery():
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: #@ data.values.workload.metadata.name
  annotations:
    kapp.k14s.io/update-strategy: "fallback-on-replace"
    ootb.apps.tanzu.vmware.com/servicebinding-workload: "true"
    kapp.k14s.io/change-rule: "upsert after upserting servicebinding.io/ServiceBindings"
  labels: #@ merge_labels({ "app.kubernetes.io/component": "run", "carto.run/workload-name": data.values.workload.metadata.name })
spec:
  selector:
    matchLabels: #@ data.values.config.metadata.labels
  template: #@ data.values.config
  #! TODO added
  #@ if "replicas" in data.values.params:
  replicas: #@ data.values.params.replicas 
  #@ end
...

apiVersion: v1
kind: ConfigMap
metadata:
#! TODO modified
  name: #@ data.values.workload.metadata.name + "-custom-server"
  labels: #@ merge_labels({ "app.kubernetes.io/component": "config" })
data:
  delivery.yml: #@ yaml.encode(delivery())

```
> added 'replicas' param under 'spec', which will take params 'replicas' from workload.yml 


4. merge custom-server-template-spec-ytt.yml into [custom-server-template.yml](./custom-server-template-files/custom-server-template.yml)
```
cp server-template.yml custom-server-template.yml
```
under ./default-server-template-files/
```
SPEC_YTT=$(cat custom-server-template-spec-ytt.yml) yq eval -i '.spec.ytt |= strenv(SPEC_YTT)' custom-server-template.yml
```
5. Change the name of ClusterConfigTemplate to custom-server-template
```
yq eval -i '.metadata.name = "custom-server-template"' [custom-server-template.yml](./custom-server-template-files/custom-server-template.yml)
```
6. Create the new ClusterConfigTemplate by running the following command:
```
kubectl delete -f custom-server-template.yml
kubectl apply -f custom-server-template.yml
```

```
k get clusterconfigtemplate

NAME                     AGE
api-descriptors          6d2h
carvel-package           6d2h
config-template          6d2h
convention-template      6d2h
custom-server-template   10s
server-template          6d2h
service-bindings         6d2h
worker-template          6d2h
```

7. Add the new workload type to the tap-values.yml file.
```
ootb_supply_chain_testing_scanning:
...
  supported_workloads:
  - type: web
    cluster_config_template_name: config-template
  - type: server
    cluster_config_template_name: server-template
  - type: worker
    cluster_config_template_name: worker-template
  - type: custom-server
    cluster_config_template_name: custom-server-template
```
8. Update your Tanzu Application Platform installation 
```
tanzu package installed update tap -p tap.tanzu.vmware.com --values-file "/path/to/your/config/tap-values.yml"  -n tap-install
```

9. verify if the new workload type is appplied.

```
k get clustersupplychains
NAME                         READY   REASON   AGE
scanning-image-scan-to-url   True    Ready    62m
source-test-scan-to-url      True    Ready    62m
```

"*-package" if carvel package applied
```
k get clustersupplychains
NAME                           READY   REASON   AGE
source-test-to-url             True    Ready    3d22h
source-test-to-url-package     True    Ready    3d22h
testing-image-to-url           True    Ready    3d22h
testing-image-to-url-package   True    Ready    3d22h
```

fetch supply chain.
```
k get clustersupplychains source-test-to-url -o yaml > ./custom-server-template-files/source-test-to-url.yml

k get clustersupplychains source-test-to-url-package  -o yaml > ./custom-server-template-files/source-test-to-url-package.yml
```
(./custom-server-template-files/source-test-to-url.yml)[./custom-server-template-files/source-test-to-url.yml]
```
  selectorMatchExpressions:
  - key: apps.tanzu.vmware.com/workload-type
    operator: In
    values:
    - web
    - server
    - worker
    - custom-server
status:
```

10. test the new workload type by deploying sample workload.
```
tanzu apps workload delete tanzu-java-web-app --yes  -n my-space
```
```
tanzu apps workload apply -f ./custom-server-template-files/workload-tanzu-java-web-app.yml --yes  -n my-space
```

```
tanzu apps workload get tanzu-java-web-app --namespace my-space

Overview
   name:        tanzu-java-web-app
   type:        custom-server
   namespace:   my-space

Source
   type:       git
   url:        https://github.com/myminseok/tanzu-java-web-app
   branch:     main
   revision:   main@sha1:763ba0d6625284113361e7b77216c2c51a2727c2

Supply Chain
   name:   source-test-to-url

   NAME               READY   HEALTHY   UPDATED   RESOURCE
   source-provider    True    True      17m       gitrepositories.source.toolkit.fluxcd.io/tanzu-java-web-app
   source-tester      True    True      16m       runnables.carto.run/tanzu-java-web-app
   image-provider     True    True      15m       images.kpack.io/tanzu-java-web-app
   config-provider    True    True      15m       podintents.conventions.carto.run/tanzu-java-web-app
   app-config         True    True      15m       configmaps/tanzu-java-web-app-custom-server
   service-bindings   True    True      15m       configmaps/tanzu-java-web-app-with-claims
   api-descriptors    True    True      15m       configmaps/tanzu-java-web-app-with-api-descriptors
   config-writer      True    True      15m       taskruns.tekton.dev/tanzu-java-web-app-config-writer-d7fjp

Delivery
   name:   delivery-basic

   NAME              READY     HEALTHY   UPDATED   RESOURCE
   source-provider   Unknown   Unknown   2s        gitrepositories.source.toolkit.fluxcd.io/tanzu-java-web-app-delivery
   deployer          False     Unknown   2s        not found
```
> delivery-basic is only for TAP full profile.


use following command to remove some parameters from existing workload.
```
tanzu apps workload apply -f ./custom-server-template-files/workload-tanzu-java-web-app.yml --yes  -n my-space --update-strategy replace

...
 13, 13   |  - name: testing_pipeline_matching_labels
 14, 14   |    value:
 15, 15   |      apps.tanzu.vmware.com/language: java
 16, 16   |      apps.tanzu.vmware.com/pipeline: test
 17     - |  - name: replicas
 18     - |    value: 2
 19, 17   |  source:
 20, 18   |    git:
 21, 19   |      ref:
 22, 20   |        branch: main
...
 Updated workload "tanzu-java-web-app"
```



## Extract deployment configs.

#### delivery.yml from configmap on build cluster
```
k get configmap -n my-space

tanzu-java-web-app-custom-server          1      16m
tanzu-java-web-app-with-api-descriptors   1      16m
tanzu-java-web-app-with-claims            1      16m
tanzu-java-web-app.app                    1      18m
tanzu-java-web-app.app-change-bxj4z       1      14m
tanzu-java-web-app.app-change-w7czw       1      18m
tanzu-java-web-app.app-change-z7wnt       1      14m
```

Extract the delivery.yml field from this file and create another file
```
k get configmap -n my-space tanzu-java-web-app-custom-server  -o yaml -ojsonpath='{.data.delivery\.yml}' > configmap-tanzu-java-web-app-custom-server-delivery.yml
```

or
```
k get configmap -n my-space tanzu-java-web-app-custom-server  -o yaml > configmap-tanzu-java-web-app-custom-server.yml
```

```
yq eval '.data."delivery.yml"' configmap-tanzu-java-web-app-custom-server.yml > configmap-tanzu-java-web-app-custom-server-delivery.yml
```
now, delivery.yml can be used to deploy workload on any k8s cluster.

#### delivery.yml from gitops repo
if the supply chain is set with gitops on build cluster, by referring to [guide](https://docs.vmware.com/en/VMware-Tanzu-Application-Platform/1.8/tap/scc-gitops-vs-regops.html), supply chain will commit "delivery.yml" for the workload on the git repo.
and the [delivery.yml](./custom-server-template-files/tap-gitops-repo/config/my-space/tanzu-java-web-app/delivery.yml) can be used to deploy workload on any k8s cluster.







