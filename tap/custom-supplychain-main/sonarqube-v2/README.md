## Sonarqube source scan testing
refer to https://github.com/x95castle1/custom-cartographer-supply-chain-examples/tree/main/code-analysis repo to setup environment.

### Steps summary
1. will duplicate existing `source-test-scan-to-url` clustersupplychain 
2. you needs to set permission to serviceaccount to list `Task` resources=> rbac.yml
3. you have to prepare sonarqube server. (https://docs.sonarsource.com/sonarqube/latest/setup-and-upgrade/deploy-on-kubernetes/deploy-sonarqube-on-kubernetes/)
4. limitation as of TAP 1.6) sonar source scan result will be saved to sonarqube server. there is no resport in TAP-GUI.
5. limitation as of TAP 1.6) TAP-gui doesn't visualize the parallel tasks.
6. limitation) this custom supplychain includes environment specific information on each installation. it means you have to modify manually or use overlay mechanism.


## Detailed steps 

### Prepare yamls


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


#### rbac.yml
you needs to set permission to serviceaccount to list `Task` resources with `rbac.yml`

kubectl apply -f rbac.yml

#### task.yml
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
```
> make sure metadata.labels.`apps.tanzu.vmware.com/use-sonarqube: true` to match with `workload.yml` to stamp out objects. this task.yml can take multiple language workload as long as matching labels.

####  cluster-run-template.yml
this will invoke task defined above
```
apiVersion: carto.run/v1alpha1
kind: ClusterRunTemplate
metadata:
  name: tekton-sonarqube-taskrun
  labels:
   ...
```

####  cluster-source-template.yml
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

#### `workload-tanzu-java-web-app.yaml`

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
  annotations:
    autoscaling.knative.dev/minScale: "1"
spec:
 # serviceAccountName: #@ data.values.service_account_name
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
> make sure to add metadata.labels.`apps.tanzu.vmware.com/use-sonarqube: true` to match with `task.yml`. task.yml can take multiple language workload.
> make sure to add  spec.params.`testing_pipeline_matching_labels` to match with testing pipeline for specific language.( no relation to sonarqube)

#### apply yaml to Developer namespace

```
export DEVELOPER_NAMESPACE=my-space

kubectl apply -f sonarqube-credentials.yaml  -n $DEVELOPER_NAMESPACE
kubectl apply -f task.yml -n $DEVELOPER_NAMESPACE
kubectl apply -f cluster-run-template.yml -n $DEVELOPER_NAMESPACE
kubectl apply -f cluster-source-template.yml -n $DEVELOPER_NAMESPACE
kubectl apply -f rbac.yml -n $DEVELOPER_NAMESPACE

kubectl apply -f source-test-scan-to-url-sonarqube.yml 

tanzu apps workload delete tanzu-java-web-app -n ${DEVELOPER_NAMESPACE} 
tanzu apps workload apply -f ./workload-tanzu-java-web-app.yaml --yes   -n ${DEVELOPER_NAMESPACE}
```

check supply chain.
```
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

login to sonarqube server and check report at http://sonar-server.h2o-2-22280.h2o.vmware.com/dashboard?id=test



## references
https://community.sonarsource.com/t/sonar-scanner-cannot-established-to-https-sonarqube-server/68090
