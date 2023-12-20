
This sample is for TAP 1.6.3 only. and follows [scanning v2 guide](https://docs.vmware.com/en/VMware-Tanzu-Application-Platform/1.6/tap/scst-scan-install-app-scanning.html)


## Setup ISV

### Prerequisites
- get prisma cloud access credentials which is only for supply chain. supply chain doesn't require prisma cloud app access permission in https://apps.paloaltonetworks.com/apps
see [scanning v2 guide](https://docs.vmware.com/en/VMware-Tanzu-Application-Platform/1.6/tap/scst-scan-install-app-scanning.html)


### Install AMR for `FULL` profile cluster
see [AMR documentation](https://docs.vmware.com/en/VMware-Tanzu-Application-Platform/1.6/tap/scst-store-amr-install-amr-observer.html)<br>
for `full` profile cluster, tap-values.yml should be:
```
metadata_store:
  ns_for_export_app_cert: "*"
  app_service_type: ClusterIP
  amr:
    deploy: true
    deploy_observer: true
```

you need to patch tap-gui with `allowedHeaders` config by following this [doc](https://docs.vmware.com/en/VMware-Tanzu-Application-Platform/1.6/tap/tap-gui-troubleshooting.html#sbom-not-working) in TAP 1.6.
```
tap_gui:
  metadataStoreAutoconfiguration: false 
  tls:
    namespace: tap-gui
    secretName: tap-gui-cert
  service_type: ClusterIP # If the shared.ingress_domain is set as above, this must be set to ClusterIP
  app_config:
    customize:
      custom_name: "Developer Portal"
    organization:
      name: "DevOps Team"
    proxy:
      /metadata-store:
        target: https://metadata-store-app.metadata-store:8443/api/v1
        changeOrigin: true
        secure: false
        ## https://docs.vmware.com/en/VMware-Tanzu-Application-Platform/1.6/tap/tap-gui-troubleshooting.html#sbom-not-working
        allowedHeaders: ['Accept', 'Report-Type-Format']
        ...

```
and update tap.

```
kubectl get all -n metadata-store

kubectl logs -n metadata-store deployment.apps/amr-persister -f

kubectl rollout restart -n metadata-store deployment.apps/amr-persister 
```


install amr-observer without any values file (no need on single cluster)
```
tanzu package available list amr-observer.apps.tanzu.vmware.com -n tap-install

tanzu package install amr-observer --package amr-observer.apps.tanzu.vmware.com \
    --version 0.1.1-alpha.2 \
    --namespace tap-install
```

```
kubectl get all -n  amr-observer-system

kubectl logs -n  amr-observer-system deployment.apps/amr-observer-controller-manager -f

kubectl rollout restart -n amr-observer-system deployment.apps/amr-observer-controller-manager
```


go to [`install SCST - scan 2.0` section](#install-scst---scan-20-for-full-build-profile-cluster-only)


###  Install AMR on `VIEW` profile cluster
tap-values.yml
```
metadata_store:
  ns_for_export_app_cert: "*"
  app_service_type: ClusterIP
  amr:
    deploy: true
```
and update tap.

```
kubectl get all -n metadata-store

kubectl logs -n metadata-store deployment.apps/amr-persister -f

kubectl rollout restart -n metadata-store deployment.apps/amr-persister 

```


###  Install AMR on `BUILD` profile cluster

fetch amr info from `view` cluster
```
kubectl get httpproxy -n metadata-store   amr-persister-ingress
NAME                    FQDN                                TLS SECRET                   STATUS   STATUS DESCRIPTION
amr-persister-ingress   amr-persister.tap.lab.pcfdemo.net   amr-persister-ingress-cert   valid    Valid HTTPProxy
```

```
kubectl get secrets amr-persister-ingress-cert -n metadata-store -o jsonpath='{.data.ca\.crt}' | base64 -d
```


and edit tap-amr-observer-values.yml
```
eventhandler:
  endpoint: https://amr-persister.tap.lab.pcfdemo.net
ca_cert_data: |
  -----BEGIN CERTIFICATE-----
  ...
  -----END CERTIFICATE-----
```


install amb-observer on `build` profile cluster
```
tanzu package available list amr-observer.apps.tanzu.vmware.com -n tap-install

tanzu package install amr-observer --package amr-observer.apps.tanzu.vmware.com \
    --version 0.1.1-alpha.2 \
    --namespace tap-install \
    --values-file tap-amr-observer-values.yaml
```


```
kubectl get all -n  amr-observer-system

kubectl logs -n  amr-observer-system deployment.apps/amr-observer-controller-manager -f

kubectl rollout restart -n amr-observer-system deployment.apps/amr-observer-controller-manager
```

optionally, verify amb-observer config:
```
kubectl get secrets -n tap-install amr-observer-tap-install-values -o yaml -ojsonpath='{.data.values\.yaml}' | base64 -d
```

to uninstall,
```
tanzu package installed delete amr-observer -n tap-install  -y
```

go to [`install SCST - scan 2.0` section](#install-scst---scan-20-for-full-build-profile-cluster-only)


##  Install SCST - scan 2.0 (for `FULL`, `BUILD` profile cluster only)
see [SCST - scan 2.0](https://docs.vmware.com/en/VMware-Tanzu-Application-Platform/1.6/tap/scst-scan-install-app-scanning.html#install-2)<br>

it is required for CRD of scanning v2. donot install to `view` profile cluster.
```
tanzu package available list app-scanning.apps.tanzu.vmware.com --namespace tap-install

tanzu package install app-scanning-beta --package app-scanning.apps.tanzu.vmware.com \
    --version 0.1.0-beta.137 \
    --namespace tap-install \
    --values-file tap-app-scanning-values.yaml
```
verify installation status:
```
tanzu package installed get -n tap-install                  app-scanning-beta
```

to uninstall,
```
tanzu package installed delete app-scanning-beta  -n tap-install  -y
```

## Testing ISV

### test `clusterimagetemplate` ISV on  ( `full`, `build` profile cluster)

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
and update tap with tanzu package installed update command. and test sample workload
`image-scanner` step will run on custom scanner and AMR component(observer) will fetch scanning result to metastore(AMR) and will be shown in TAP-GUI.
```
Supply Chain
   name:   source-test-scan-to-url

   NAME               READY   HEALTHY   UPDATED   RESOURCE
   source-provider    True    True      24m       gitrepositories.source.toolkit.fluxcd.io/tanzu-java-web-app
   source-tester      True    True      24m       runnables.carto.run/tanzu-java-web-app
   image-provider     True    True      22m       images.kpack.io/tanzu-java-web-app
   image-scanner      True    True      21m       imagevulnerabilityscans.app-scanning.apps.tanzu.vmware.com/tanzu-java-web-app-grype-scan-c4gb5
   config-provider    True    True      21m       podintents.conventions.carto.run/tanzu-java-web-app
   app-config         True    True      21m       configmaps/tanzu-java-web-app
   service-bindings   True    True      21m       configmaps/tanzu-java-web-app-with-claims
   api-descriptors    True    True      21m       configmaps/tanzu-java-web-app-with-api-descriptors
   config-writer      True    True      21m       runnables.carto.run/tanzu-java-web-app-config-writer
```
scanning result should be shown on `image-scanner` step in supply-chain in TAP-GUI.

## Authoring custom ISV

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

edit image-vulnerability-scan-prisma-tap1.6.yaml and apply to cluster.
make sure to edit `PRISMA-SCANNER-IMAGE` placeholder. 
```
kubectl apply -f image-vulnerability-scan-prisma-tap1.6.yaml

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
imgpkg pull -b $SCAN_RESULT_URL -o scan-results-grype-ISV/
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


## TODO
- image build guide



