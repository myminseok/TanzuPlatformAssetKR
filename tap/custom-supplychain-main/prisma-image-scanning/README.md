
# IVS(image-vulnerability-scan)
### NOTE
Please note that there are two scanning standard in TAP 1.7
- [SCST(Supply Chain Security Tools) - Scan](https://docs.vmware.com/en/VMware-Tanzu-Application-Platform/1.7/tap/scst-scan-overview.html)=> [Prisma Scanner for Supply Chain Security Tools - Scan (Alpha)](https://docs.vmware.com/en/VMware-Tanzu-Application-Platform/1.7/tap/scst-scan-install-prisma-integration.html)
- [SCST(Supply Chain Security Tools) - scan 2.0](https://docs.vmware.com/en/VMware-Tanzu-Application-Platform/1.7/tap/scst-scan-install-app-scanning.html)
this sample follows `Prisma Scanner for Supply Chain Security Tools - Scan 2.0`. 

## Contents
- [Prerequisites](#prerequisites)
- [Architecture](#architecture)
- [setup guide for TAP-1.6](README-TAP-1.6.md)
- [setup guide for TAP-1.7](README-TAP-1.7.md)
- [Testing Out of the box IVS (grype)](#testing-out-of-the-box-ivs-grype)
- [Authoring custom Prisma IVS](#authoring-custom-prisma-ivs)
- [Troubleshooting](#troubleshooting)

## Prerequisites
- get prisma cloud access credentials which is only for supply chain. supply chain doesn't require prisma cloud app access permission in https://apps.paloaltonetworks.com/apps
see [scanning v2 guide](https://docs.vmware.com/en/VMware-Tanzu-Application-Platform/1.6/tap/scst-scan-install-app-scanning.html)

## Architecture
- [architecture](https://docs.vmware.com/en/VMware-Tanzu-Application-Platform/1.6/tap/scst-store-amr-architecture.html)
- [Supply Chain Security Tools - Store](https://docs.vmware.com/en/VMware-Tanzu-Application-Platform/1.6/tap/scst-store-deployment-details.html)

## Setup Metadata store, AMR
- [for TAP-1.6](README-TAP-1.6.md)
- [for TAP-1.7](README-TAP-1.7.md)

## Testing Out of the box IVS (grype)

### Setup `clusterimagetemplate` IVS on  ( `full`, `build` profile cluster)

it is good idea to test if ISV scaning is working. you can use `image-vulnerability-scan-grype` clusterimagetemplate.
```
k get clusterimagetemplate
NAME                              AGE
image-provider-template           5h35m
image-scanner-template            5h35m
image-vulnerability-scan-grype    5h35m
kaniko-template                   5h35m
kpack-template                    5h35m
```
change the new scanner to supply-chain by following [guide](https://docs.vmware.com/en/VMware-Tanzu-Application-Platform/1.6/tap/scst-scan-integrate-app-scanning.html).
please note that to clean up the previous scan result for the workload, you need to delete workload and redeploy for the new scanner.
```
ootb_supply_chain_testing_scanning:
  image_scanner_template_name: image-vulnerability-scan-grype
  registry:
  ...
```
and update tap with tanzu package installed update command. 


#### Deploy workloads to Developer namespace
- the custom supply-chain can support polygot language workload. suchas spring boot, nodejs. 
- there no required labels or annotation for Prisma image scanner.

springboot sample `workload-tanzu-java-web-app.yaml`
```
apiVersion: carto.run/v1alpha1
kind: Workload
metadata:
  name: tanzu-java-web-app
  labels:
    apps.tanzu.vmware.com/workload-type: web
    app.kubernetes.io/part-of: tanzu-java-web-app

spec:
  source:
    git:
      url: https://github.com/myminseok/tanzu-java-web-app
      ref:
        branch: main
...
```

and deploy workload to developer namespace
```
export DEVELOPER_NAMESPACE=my-space
tanzu apps workload delete tanzu-java-web-app -n ${DEVELOPER_NAMESPACE} 
tanzu apps workload apply -f ./workload-tanzu-java-web-app.yaml --yes   -n ${DEVELOPER_NAMESPACE}
```

then, check the  supply chain. `imagescanner` step will run on custom scanner and AMR component(observer) will fetch scanning result to metastore(AMR) and will be shown in TAP-GUI.
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
   imagescanner              True    True      3m25s     imagevulnerabilityscans.app-scanning.apps.tanzu.vmware.com/tanzu-java-web-app-grype-scan-s7nqn
   config-provider           True    True      3m25s     podintents.conventions.carto.run/tanzu-java-web-app
   app-config                True    True      3m25s     configmaps/tanzu-java-web-app
   service-bindings          True    True      3m25s     configmaps/tanzu-java-web-app-with-claims
   api-descriptors           True    True      3m25s     configmaps/tanzu-java-web-app-with-api-descriptors
   config-writer             True    True      3m25s     runnables.carto.run/tanzu-java-web-app-config-writer
   deliverable               True    True      142m      configmaps/tanzu-java-web-app-deliverable

```

## Authoring custom Prisma IVS

#### Prepare supply chain runtime image
PRISMA-SCANNER-IMAGE is the image containing the Prisma Cloud twistcli, podman, and a utility to convert the Prisma summary report in JSON format to a CycloneDX SBOM in XML format. see [Example ImageVulnerabilityScan](https://docs.vmware.com/en/VMware-Tanzu-Application-Platform/1.6/tap/scst-scan-ivs-prisma.html#example-imagevulnerabilityscan-1)

#### Prepare prisma secrets
edit prisma-auth.yml and apply to the developer namespace.
make sure to edit `USERNAME`, `PASSWORD` placeholder.
```
kubectl apply -f prima-auth.yml -n DEV_NAMESPACE
```

#### Author a ClusterImageTemplate for Supply Chain integration
- for [ClusterImageTemplate](https://docs.vmware.com/en/VMware-Tanzu-Application-Platform/1.6/tap/scst-scan-clusterimagetemplates.html)
- for [ImageVulnerabilityScan](https://docs.vmware.com/en/VMware-Tanzu-Application-Platform/1.6/tap/scst-scan-ivs-prisma.html)

edit `image-vulnerability-scan-prisma.yaml` and apply to cluster.
make sure to edit `PRISMA-SCANNER-IMAGE` placeholder. 
```
kubectl apply -f image-vulnerability-scan-prisma.yaml

```
#### Add App Scanning to default Test and Scan supply chains
change the new scanner to supply-chain by following [guide](https://docs.vmware.com/en/VMware-Tanzu-Application-Platform/1.6/tap/scst-scan-integrate-app-scanning.html).
please note that to clean up the previous scan result for the workload, you need to delete workload and redeploy for the new scanner.
```
ootb_supply_chain_testing_scanning:
  image_scanner_template_name: image-vulnerability-scan-prisma
  registry:
  ...
```


## Troubleshooting
#### Scan results is not shown in TAP-GUI
clicking on `image scanner` step in supply-chain on browser, displays following error:
```
Cannot read properties of undefined (reading 'resource')
```
or
```
imagevulnerabilityscans.app-scanning.apps.tanzu.vmware.com is forbidden: User "system:serviceaccount:tap-gui:tap-gui-viewer" cannot list resource "imagevulnerabilityscans" in API group "app-scanning.apps.tanzu.vmware.com" at the cluster scope","reason":"Forbidden","details":{"group":"app-scanning.apps.tanzu.vmware.com","kind":"imagevulnerabilityscans"},"code":403
```

solution is to apply proper permission to view service account on `build` profile cluster by following [this doc](https://docs.vmware.com/en/VMware-Tanzu-Application-Platform/1.6/tap/tap-gui-cluster-view-setup.html)


#### Troubleshooting - download imagevulnerabilityscans result directly.

https://docs.vmware.com/en/VMware-Tanzu-Application-Platform/1.6/tap/scst-scan-verify-app-scanning-supply-chain.html

```
SCAN_RESULT_URL=$(kubectl get imagevulnerabilityscan -n my-space    tanzu-java-web-app-grype-scan-l82wh -o jsonpath='{.status.scanResult}')
```

```
imgpkg pull -b $SCAN_RESULT_URL -o scan-results-grype-IVS/
```

#### Troubleshooting  - deployment.apps/amr-persister
```
kubectl logs -n metadata-store deployment.apps/amr-persister -f
```
```
{"level":"debug","ts":"2023-12-19T08:02:09.210656283Z","caller":"persister/persisteradapter.go:76","msg":"Handle single event"}
{"level":"debug","ts":"2023-12-19T08:02:09.210843452Z","caller":"persister/persisteradapter.go:108","msg":"Handle Event"}
{"level":"debug","ts":"2023-12-19T08:02:09.210877122Z","caller":"persister/persisteradapter.go:120","msg":"Knative Event"}
{"level":"info","ts":"2023-12-19T08:02:09.211673399Z","caller":"persister/persisteradapter.go:279","msg":"Sending request to: https://artifact-metadata-repository-app.metadata-store.svc.cluster.local:8443/api/v1/apps with payload: {\"locationReference\":\"f2bdcf34-95a3-45b5-96fb-022ffa3d3731\",\"imageUrl\":\"ghcr.io/myminseok/tap-service/minseok-supply-chain/tanzu-java-web-app-my-space\",\"imageDigest\":\"63d830e4c827bca9bb918f38471217fb5cf7746394e5c91cd12f58c96def725a\",\"namespace\":\"my-space\",\"name\":\"tanzu-java-web-app-00001\",\"instances\":0,\"status\":\"Unavailable\",\"timestamp\":\"2023-12-19T08:02:09Z\"}"}

```
#### Troubleshooting  - scan result is not displayed in TAP-GUI
on build cluster, check logs of amr-observer. 
```
kubectl logs -n  amr-observer-system deployment.apps/amr-observer-controller-manager -f


1-11T13:43:18Z	INFO	Starting workers	{"controller": "imagevulnerabilityscan", "controllerGroup": "app-scanning.apps.tanzu.vmware.com", "controllerKind": "ImageVulnerabilityScan", "worker count": 1}
2024-01-11T13:43:18Z	INFO	Starting workers	{"controller": "replicaset", "controllerGroup": "apps", "controllerKind": "ReplicaSet", "worker count": 1}
2024-01-11T13:43:18Z	INFO	ivs.reconcile	reconciling IVS resource	{"namespacedName": "my-space/tanzu-java-web-app-prisma-scan-z7xbn"}
2024-01-11T13:43:18Z	INFO	ivs.download	Preparing keychain	{"keychain": {"Namespace":"my-space","ServiceAccountName":"default","ImagePullSecrets":null,"UseMountSecrets":true}}
2024-01-11T13:43:19Z	INFO	ivs.download	Fetching scan results	{"imageRef": "ghcr.io/myminseok/tap-service/minseok-supply-chain/tanzu-java-web-app-my-space-scan-results@sha256:6f118737101da478e4b955b27df2d56f7c226bdaaa5bfc9e025d8782f736db7f", "bundleDir": "/tmp/amr-observer1385328797"}
2024-01-11T13:43:19Z	INFO	ivs.reconcile	Downloaded 2 scanresults	{"namespacedName": "my-space/tanzu-java-web-app-prisma-scan-z7xbn", "filepaths": ["/tmp/amr-observer1385328797/scan.cdx.xml", "/tmp/amr-observer1385328797/twist-scan.json"]}
2024-01-11T13:43:19Z	INFO	ivs.reconcile	Generated cloudevents successfully	{"namespacedName": "my-space/tanzu-java-web-app-prisma-scan-z7xbn", "count": 1}
2024-01-11T13:43:19Z	INFO	ivs.reconcile	Sending the request to persister-endpoint...	{"namespacedName": "my-space/tanzu-java-web-app-prisma-scan-z7xbn"}
2024-01-11T13:43:21Z	INFO	httpclient.circuitbreaker	Received response with status	{"status": "204 No Content"}
2024-01-11T13:43:21Z	INFO	httpclient.circuitbreaker	Successfully sent CloudEvent
2024-01-11T13:43:22Z	INFO	ivs.reconcile	Received response with status	{"namespacedName": "my-space/tanzu-java-web-app-prisma-scan-z7xbn", "status": "204 No Content"}
2024-01-11T13:43:22Z	INFO	ivs.reconcile	Reconcile for IVS SUCCEEDED	{"namespacedName": "my-space/tanzu-java-web-app-prisma-scan-z7xbn"}
```
restarting amr-observer might help to re-register workload to TAP-GUI.

```
kubectl rollout restart -n amr-observer-system deployment.apps/amr-observer-controller-manager
```

## TODO
- building prisma scanning image  guide



