This sample follows [scanning v2 guide](https://docs.vmware.com/en/VMware-Tanzu-Application-Platform/1.6/tap/scst-scan-install-app-scanning.html)

#### prerequisites
- get prisma cloud access credentials which is only for supply chain. supply chain doesn't require prisma cloud app access permission in https://apps.paloaltonetworks.com/apps
see [scanning v2 guide](https://docs.vmware.com/en/VMware-Tanzu-Application-Platform/1.6/tap/scst-scan-install-app-scanning.html)

#### install AMR
for `full` profile cluster, tap-values.yml should be:
```
metadata_store:
  ns_for_export_app_cert: "*"
  app_service_type: ClusterIP
  amr:
    deploy: true
    deploy_observer: true
```
see [AMR documentation](https://docs.vmware.com/en/VMware-Tanzu-Application-Platform/1.6/tap/scst-store-amr-install-amr-observer.html)


#### install SCST - scan 2.0
fetch available version. it is required for CRD of scanning v2. see [SCST - scan 2.0](https://docs.vmware.com/en/VMware-Tanzu-Application-Platform/1.6/tap/scst-scan-install-app-scanning.html#install-2)

```
tanzu package available list app-scanning.apps.tanzu.vmware.com --namespace tap-install
```

```
tanzu package install app-scanning-beta --package app-scanning.apps.tanzu.vmware.com \
    --version 0.1.0-beta.137 \
    --namespace tap-install \
    --values-file tap-app-scanning-values-file.yaml
```


### prepare supply chanin runtime image
PRISMA-SCANNER-IMAGE is the image containing the Prisma Cloud twistcli, podman, and a utility to convert the Prisma summary report in JSON format to a CycloneDX SBOM in XML format. see [Example ImageVulnerabilityScan](https://docs.vmware.com/en/VMware-Tanzu-Application-Platform/1.6/tap/scst-scan-ivs-prisma.html#example-imagevulnerabilityscan-1)

### prepare prisma secrets
edit prisma-auth.yml and apply to the developer namespace.

### Author a ClusterImageTemplate for Supply Chain integration
- for [ClusterImageTemplate](https://docs.vmware.com/en/VMware-Tanzu-Application-Platform/1.6/tap/scst-scan-clusterimagetemplates.html)
- for [ImageVulnerabilityScan](https://docs.vmware.com/en/VMware-Tanzu-Application-Platform/1.6/tap/scst-scan-ivs-prisma.html)
refer to image-vulnerability-scan-prisma-tap1.6.yaml and apply to cluster.

### Add App Scanning to default Test and Scan supply chains
https://docs.vmware.com/en/VMware-Tanzu-Application-Platform/1.6/tap/scst-scan-integrate-app-scanning.html

tap-values.yml
```
ootb_supply_chain_testing_scanning:
  image_scanner_template_name: image-vulnerability-scan-prisma
  registry:
  ...
```
and update tap.

### test sample workload
`image-scanner` step will run on custom scanner and AMR component(observer) will fetch scanning result to metastore(AMR) and will be shown in TAP-GUI.
```
Supply Chain
   name:   source-test-scan-to-url

   NAME               READY   HEALTHY   UPDATED   RESOURCE
   source-provider    True    True      24m       gitrepositories.source.toolkit.fluxcd.io/tanzu-java-web-app
   source-tester      True    True      24m       runnables.carto.run/tanzu-java-web-app
   image-provider     True    True      22m       images.kpack.io/tanzu-java-web-app
   image-scanner      True    True      21m       imagevulnerabilityscans.app-scanning.apps.tanzu.vmware.com/tanzu-java-web-app-prisma-scan-c4gb5
   config-provider    True    True      21m       podintents.conventions.carto.run/tanzu-java-web-app
   app-config         True    True      21m       configmaps/tanzu-java-web-app
   service-bindings   True    True      21m       configmaps/tanzu-java-web-app-with-claims
   api-descriptors    True    True      21m       configmaps/tanzu-java-web-app-with-api-descriptors
   config-writer      True    True      21m       runnables.carto.run/tanzu-java-web-app-config-writer
```


### TODO
- multi cluster testing
- image build guide
