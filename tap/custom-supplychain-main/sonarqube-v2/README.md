# Sonarqube source scan testing
-  NOTE: This sample is tested on TAP 1.6, TAP 1.7
- and follows from https://github.com/x95castle1/custom-cartographer-supply-chain-examples/tree/main/code-analysis repo to setup environment.

## Contents
- [Prerequisites](#prerequisites)
- [Setup summary](#setup-summary)
- [Prepare Supplychain resources](#prepare-supplychain-resources)
- [Deploy workloads to Developer namespace](#deploy-workloads-to-developer-namespace)

## Prerequisites
- prepare sonarqube server for testing. note that sonar source scan result will be saved to sonarqube server. there is no report on TAP-GUI.

## Setup summary
1. will create scanning resources such as ClusterSourceTemplate, ClusterRunTemplate, Tekton Task
2. you needs to set permission to serviceaccount to list `Task` resources=> rbac.yml
3. will duplicate existing `source-test-scan-to-url` clustersupplychain. this all supplychain includes environment specific information on each installation
4. you have to prepare sonarqube server. and sonarqube credentials secret  (https://docs.sonarsource.com/sonarqube/latest/setup-and-upgrade/deploy-on-kubernetes/deploy-sonarqube-on-kubernetes/)

## Detailed steps 

### Prepare Supplychain resources

#### `sonarqube-credentials.yaml`
for sonarqube access credentials. edit sonarqube-credentials.yaml. this will be injected to `task.yml`. 
fetch sonaqube server CA from view cluster.
```
kubectl get secrets -n sonarqube sonar-default-tls -o jsonpath='{.data.ca\.crt}' | base64 -d
```
and edit  `sonarqube-credentials.yaml`
```
apiVersion: v1
kind: Secret
metadata:
  name: sonarqube-credentials
type: Opaque
stringData:
  sonar_login: admin
  sonar_password: 'VMware1!'
  ## http with 80 only. https is planned.
  sonar_host_url: 'https://sonar-server.h2o-2-22280.h2o.vmware.com'
  sonar_token: ''
  ## sonar_ca_crt:  optional if sonar_host_url is on SSL
  ## fetch sonaqube server CA from view cluster: kubectl get secrets -n sonarqube sonar-default-tls -o jsonpath='{.data.ca\.crt}' | base64 -d
  sonar_ca_crt: |  
    -----BEGIN CERTIFICATE-----
```

#### `source-test-scan-to-url-sonarqube.yml`
create a new `source-test-scan-to-url-custom` clustersupplychain by duplicate existing `source-test-scan-to-url` clustersupplychain 
```
k get clustersupplychains source-test-scan-to-url -o yaml > source-test-scan-to-url.yml
cp source-test-scan-to-url.yml source-test-scan-to-url-sonarqube.yml
```

and update `source-test-scan-to-url-sonarqube.yml` for parameters according to you environment. 
```
apiVersion: carto.run/v1alpha1
kind: ClusterSupplyChain
metadata:
  name: source-test-scan-to-url-custom
spec:
...
  - name: sonarqube-sourcescanner
    sources:
    - name: source
      resource: source-tester
    templateRef:
      kind: ClusterSourceTemplate
      name: sonarqube-template
  - name: grype-sourcescanner
    sources:
    - name: source
      resource: source-tester
      ...  
  selector:
    apps.tanzu.vmware.com/has-tests: "true"
    apps.tanzu.vmware.com/use-sonarqube: "true"  # added this as a selector
     ...
```
> rename to unique supplychain name: `source-test-scan-to-url-custom`
> add `sonarqube-sourcescanner` step
> add `apps.tanzu.vmware.com/use-sonarqube: "true"` selector.


#### `rbac.yml`
you needs to set permission to serviceaccount to list `Task` resources with `rbac.yml`

kubectl apply -f rbac.yml

#### `task.yml`
- refer to https://hub.tekton.dev/tekton/task/sonarqube-scanner
- how to inject SSL cert to sonarqube scanner TaskRun? `sonar-properties-create` step in `task.yml` wil fetch the sonarqube server SSL CA from `sonarqube-credentials`. and `sonar-scan` step will import the ca cert into truststore of `sonar-scanner-cl` container.

```
apiVersion: tekton.dev/v1beta1
kind: Task
metadata:
  name: sonarqube-scanner
  labels:
    app.kubernetes.io/version: "0.2"
    apps.tanzu.vmware.com/use-sonarqube: "true"
    ...
spec:
  steps:
    ...
    - name: sonar-scan
      image: docker.io/sonarsource/sonar-scanner-cli:4.6@sha256:7a976330a8bad1beca6584c1c118e946e7a25fdc5b664d5c0a869a6577d81b4f
      workingDir: $(workspaces.tmp-workspace.path)
      # command:
      #   - sonar-scanner
      script: |
        #!/bin/bash
        set -ex
        ## (!) requires to download source code 
        wget -qO- $(params.source-url) | tar xvz

        echo "# importing sonarqube server CA to truststore ---------------------------"
        cat $(workspaces.tmp-workspace.path)/sonar_ca.crt
        echo "JAVA_HOME:$JAVA_HOME" ## JAVA_HOME:/usr/lib/jvm/java-11-openjdk
        keytool -importcert -trustcacerts -cacerts -file $(workspaces.tmp-workspace.path)/sonar_ca.crt -alias myCert -storepass changeit  -noprompt 
        sonar-scanner

```
> make sure metadata.labels.`apps.tanzu.vmware.com/use-sonarqube: true` to match with `workload.yml` to stamp out objects. this task.yml can take multiple language workload as long as matching labels.

####  `cluster-run-template.yml`
this will invoke task defined above
```
apiVersion: carto.run/v1alpha1
kind: ClusterRunTemplate
metadata:
  name: tekton-sonarqube-taskrun
  labels:
   ...
```

####  `cluster-source-template.yml`
this will invoke ClusterRunTemplate  defined above
```
apiVersion: carto.run/v1alpha1
kind: ClusterSourceTemplate
metadata:
  annotations:
  name: sonarqube-template
spec:
   ...
```


#### Apply all resources to TAP.

```
kubectl apply -f cluster-run-template.yml 
kubectl apply -f cluster-source-template.yml 
kubectl apply -f source-test-scan-to-url-sonarqube.yml 

export DEVELOPER_NAMESPACE=my-space
kubectl apply -f sonarqube-credentials.yaml  -n $DEVELOPER_NAMESPACE
kubectl apply -f task.yml -n $DEVELOPER_NAMESPACE
kubectl apply -f rbac.yml -n $DEVELOPER_NAMESPACE
```




### Deploy workloads to Developer namespace
the custom supply-chain can support polygot language workload. suchas spring boot, nodejs.

springboot sample `workload-tanzu-java-web-app.yaml`
```
apiVersion: carto.run/v1alpha1
kind: Workload
metadata:
  name: tanzu-java-web-app
  labels:
    apps.tanzu.vmware.com/workload-type: web
    app.kubernetes.io/part-of: tanzu-java-web-app
    apps.tanzu.vmware.com/has-tests: true
    apps.tanzu.vmware.com/use-sonarqube: "true"   # added this as a scanner task selector

spec:
  source:
    git:
      url: https://github.com/myminseok/tanzu-java-web-app
      ref:
        branch: main
  params:
  - name: testing_pipeline_matching_labels   
    value:
      apps.tanzu.vmware.com/pipeline: test       # only for testing pipeline
      apps.tanzu.vmware.com/language: java       # only for testing pipeline
```
> * make sure to add metadata.labels.`apps.tanzu.vmware.com/use-sonarqube: true` to match with `task.yml`. task.yml can take multiple language workload.
> * make sure to add  spec.params.`testing_pipeline_matching_labels` to match with testing pipeline for specific language.( no relation to sonarqube)


```
export DEVELOPER_NAMESPACE=my-space

tanzu apps workload delete tanzu-java-web-app -n ${DEVELOPER_NAMESPACE} 
tanzu apps workload apply -f ./workload-tanzu-java-web-app.yaml --yes   -n ${DEVELOPER_NAMESPACE}
```

check supply chain.
```
Overview
   name:        tanzu-java-web-app
   type:        web
   namespace:   my-space

Source
   type:       git
   url:        https://github.com/myminseok/tanzu-java-web-app
   branch:     main
   revision:   main@sha1:0523f9bbe4995541cc832ef7bfaec654a34a35c2

Supply Chain
   name:   source-test-scan-to-url-custom

   NAME                      READY   HEALTHY   UPDATED   RESOURCE
   source-provider           True    True      142m      gitrepositories.source.toolkit.fluxcd.io/tanzu-java-web-app
   source-tester             True    True      3m25s     runnables.carto.run/tanzu-java-web-app
   sonarqube-sourcescanner   True    True      3m25s     runnables.carto.run/tanzu-java-web-app-sonar-code-analysis
   image-provider            True    True      3m25s     images.kpack.io/tanzu-java-web-app
   imagescanner              True    True      3m25s     imagevulnerabilityscans.app-scanning.apps.tanzu.vmware.com/tanzu-java-web-app-p
risma-scan-s7nqn
   config-provider           True    True      3m25s     podintents.conventions.carto.run/tanzu-java-web-app
   app-config                True    True      3m25s     configmaps/tanzu-java-web-app
   service-bindings          True    True      3m25s     configmaps/tanzu-java-web-app-with-claims
   api-descriptors           True    True      3m25s     configmaps/tanzu-java-web-app-with-api-descriptors
   config-writer             True    True      3m25s     runnables.carto.run/tanzu-java-web-app-config-writer
   deliverable               True    True      142m      configmaps/tanzu-java-web-app-deliverable

```

for node-express workload `workload-node-express.yaml`
```
Overview
   name:        node-express
   type:        web
   namespace:   my-space

Source
   type:       git
   url:        https://github.com/myminseok/tanzu-workload-samples
   branch:     main
   sub-path:   node-express
   revision:   main@sha1:af461516b58042f03b92d4be63230a713caa82ff

Supply Chain
   name:   source-test-scan-to-url-custom

   NAME                      READY   HEALTHY   UPDATED   RESOURCE
   source-provider           True    True      133m      gitrepositories.source.toolkit.fluxcd.io/node-express
   source-tester             True    True      133m      runnables.carto.run/node-express
   sonarqube-sourcescanner   True    True      7m57s     runnables.carto.run/node-express-sonar-code-analysis
   image-provider            True    True      7m57s     images.kpack.io/node-express
   imagescanner              True    True      7m56s     imagevulnerabilityscans.app-scanning.apps.tanzu.vmware.com/node-express-prisma-scan-frzc8
   config-provider           True    True      7m56s     podintents.conventions.carto.run/node-express
   app-config                True    True      7m56s     configmaps/node-express
   service-bindings          True    True      7m56s     configmaps/node-express-with-claims
   api-descriptors           True    True      7m56s     configmaps/node-express-with-api-descriptors
   config-writer             True    True      7m56s     runnables.carto.run/node-express-config-writer
   deliverable               True    True      133m      configmaps/node-express-deliverable


```

login to sonarqube server and check report at http://SONARQUBE_SERVER/dashboard?id=my-space-tanzu-java-web-app



## references
https://community.sonarsource.com/t/sonar-scanner-cannot-established-to-https-sonarqube-server/68090
