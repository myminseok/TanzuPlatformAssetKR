
### NOTE
Please note that there are two scanning standard in TAP 1.6
- [SCST(Supply Chain Security Tools) - Scan](https://docs.vmware.com/en/VMware-Tanzu-Application-Platform/1.6/tap/scst-scan-overview.html)=> [Prisma Scanner for Supply Chain Security Tools - Scan (Alpha)](https://docs.vmware.com/en/VMware-Tanzu-Application-Platform/1.6/tap/scst-scan-install-prisma-integration.html)
- [SCST(Supply Chain Security Tools) - scan 2.0](https://docs.vmware.com/en/VMware-Tanzu-Application-Platform/1.6/tap/scst-scan-install-app-scanning.html)
this sample follows `Prisma Scanner for Supply Chain Security Tools - Scan 2.0`. 

## Contents
- [Prerequisites](#prerequisites)
- [Architecture](#architecture)
- [setup guide for `full` profile cluster](#for-full-profile-cluster)
- [setup guide for `multi cluster` deployment](#for-multi-cluster)
- [Testing Out of the box IVS (grype)](#testing-out-of-the-box-ivs-grype)
- [Authoring custom Prisma IVS](#authoring-custom-prisma-ivs)
- [Troubleshooting](#troubleshooting)

## Prerequisites
- get prisma cloud access credentials which is only for supply chain. supply chain doesn't require prisma cloud app access permission in https://apps.paloaltonetworks.com/apps
see [scanning v2 guide](https://docs.vmware.com/en/VMware-Tanzu-Application-Platform/1.6/tap/scst-scan-install-app-scanning.html)

## Architecture
- [architecture](https://docs.vmware.com/en/VMware-Tanzu-Application-Platform/1.6/tap/scst-store-amr-architecture.html)
- [Supply Chain Security Tools - Store](https://docs.vmware.com/en/VMware-Tanzu-Application-Platform/1.6/tap/scst-store-deployment-details.html)
-  amr package is `alpha` status.
-  app-scanning package is `beta` status.

## Setup 
- [for full profile cluster](README-TAP-1.6.md#for-full-profile-cluster)
- [for multi cluster deployment](README-TAP-1.6.md#for-multi-cluster)

### For `FULL` profile cluster

#### Install Metadata store, AMR for `FULL` profile cluster

on TAP 1.6, AMR is not deployed with SCST - Store. To deploy AMR, you must set the deploy property under amr to true.
for `full` profile cluster, tap-values.yml should be:
```
metadata_store:
  ns_for_export_app_cert: "*"
  app_service_type: ClusterIP
  amr:
    deploy: true
```

You must deploy AMR and AMR CloudEvent Handler if you are using the Full profile.
https://docs.vmware.com/en/VMware-Tanzu-Application-Platform/1.6/tap/scst-store-amr-install-amr-observer.html#install-2

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


install amr-observer without any values file 
- no need on single cluster
- no need to install on TAP installation with [gitops sops)(https://docs.vmware.com/en/VMware-Tanzu-Application-Platform/1.7/tap/install-gitops-sops.html). `amr-observer` is installed automatically with `build` profile. tested on TAP 1.6.3 with `gitops Reference Implementation for TAP 1.7`.

```
tanzu package available list amr-observer.apps.tanzu.vmware.com -n tap-install

tanzu package installed delete amr-observer -n tap-install  -y

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

### For Multi cluster
####  Install AMR store on `VIEW` profile cluster
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

#### Install AMR observer on `BUILD` profile cluster

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
it is required for CRD of scanning v2. refer to [SCST(Supply Chain Security Tools) - scan 2.0 (beta) ](https://docs.vmware.com/en/VMware-Tanzu-Application-Platform/1.6/tap/scst-scan-install-app-scanning.html#install-2)

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

NAMESPACE:          tap-install
NAME:               app-scanning-beta
PACKAGE-NAME:       app-scanning.apps.tanzu.vmware.com
PACKAGE-VERSION:    0.1.0-beta.137
STATUS:             Reconcile succeeded
CONDITIONS:         - type: ReconcileSucceeded
  status: "True"
  reason: ""
  message: ""
```

to uninstall,
```
tanzu package installed delete app-scanning-beta  -n tap-install  -y
```

## Testing Out of the box IVS (grype)
see [README.md#testing-out-of-the-box-ivs-grype ](README.md#testing-out-of-the-box-ivs-grype)

## Authoring custom Prisma IVS
see [README.md#authoring-custom-prisma-ivs](README.md#authoring-custom-prisma-ivs)

## Troubleshooting
see [README.md#troubleshooting](README.md#troubleshooting)
