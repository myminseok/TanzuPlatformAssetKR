### NOTE
Please note that there are two scanning standard in TAP 1.7
- [SCST(Supply Chain Security Tools) - Scan](https://docs.vmware.com/en/VMware-Tanzu-Application-Platform/1.7/tap/scst-scan-overview.html)=> [Prisma Scanner for Supply Chain Security Tools - Scan (Alpha)](https://docs.vmware.com/en/VMware-Tanzu-Application-Platform/1.7/tap/scst-scan-install-prisma-integration.html)
- [SCST(Supply Chain Security Tools) - scan 2.0](https://docs.vmware.com/en/VMware-Tanzu-Application-Platform/1.7/tap/scst-scan-install-app-scanning.html)
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
- uninstall beta package from TAP 1.6.x
```
tanzu package installed delete amr-observer -n tap-install  -y
```
## Architecture
- [architecture](https://docs.vmware.com/en/VMware-Tanzu-Application-Platform/1.7/tap/scst-store-amr-architecture.html)
- [Supply Chain Security Tools - Store](https://docs.vmware.com/en/VMware-Tanzu-Application-Platform/1.7/tap/scst-store-deployment-details.html)
-  amr package status is `GA` on TAP 1.7
-  app-scanning package status is `beta` on TAP 1.7


## Setup 
- [for full profile cluster](#for-full-profile-cluster)
- [for multi cluster deployment](#for-multi-cluster)


### For `FULL` profile cluster, 
### Install metadata_store, AMR

it is embedded in metadata_store in TAP full profile.
```
kubectl get all -n metadata-store

kubectl rollout restart -n metadata-store deployment.apps/amr-cloudevent-handler 

kubectl logs -n metadata-store deployment.apps/amr-cloudevent-handler -f
```

### For Multi cluster
####  Install AMR cloud event handler on `VIEW` profile cluster
https://docs.vmware.com/en/VMware-Tanzu-Application-Platform/1.7/tap/scst-store-amr-install-amr-cloudevent-handler.html

tap-values.yml
```
amr:
  cloudevent_handler:
    auth:
      kubernetes_service_accounts: true ## default true, #Enable authentication and authorization for services accessing Artifact Metadata Repository
      autoconfigure: true  ## default true, Delegate creation of authentication token secret to the artifact metadata repository
```

####  Install AMR observer on `BUILD`,`RUN` profile cluster
The `AMR Observer` is deployed by default on the Tanzu Application Platform Build and Run profiles
- https://docs.vmware.com/en/VMware-Tanzu-Application-Platform/1.7/tap/scst-store-amr-configuration.html#amr-observer-0
- https://docs.vmware.com/en/VMware-Tanzu-Application-Platform/1.7/tap/scst-store-amr-install-amr-observer.html

fetch amr info from `view` cluster
```
kubectl -n metadata-store get secrets/amr-cloudevent-handler-ingress-cert -o jsonpath='{.data."crt.ca"}' | base64 -d

kubectl -n metadata-store get httpproxies.projectcontour.io amr-cloudevent-handler-ingress -o jsonpath='{.spec.virtualhost.fqdn}'
```

then, edit tap-values.yml on `Full`,`BUILD`,`RUN` profile cluster
```
amr:
  observer:
    location: |
      labels:
      - key: environment
        value: prod
    resync_period: "10h"
    ca_cert_data: |
      -----BEGIN CERTIFICATE-----
      Custom CA certificate for AMR CloudEvent Handler's HTTPProxy with custom TLS certs
      -----END CERTIFICATE-----
    cloudevent_handler:
      endpoint: "https://amr-cloudevent-handler.DOMAIN" 
      liveness_period_seconds: 10
    auth:
      kubernetes_service_accounts:
        enabled: true
        autoconfigured: true
        secret:
          ref: "amr-observer-edit-token"
          value: ""
    deployed_through_tmc: false
    max_concurrent_reconciles:
      image_vulnerability_scans: 1
```

##  Install SCST - scan 2.0 (for `FULL`, `BUILD` profile cluster only)
it is required for CRD of scanning v2. refer to [SCST(Supply Chain Security Tools) - scan 2.0 (beta) ](https://docs.vmware.com/en/VMware-Tanzu-Application-Platform/1.7/tap/scst-scan-install-app-scanning.html)

```
tanzu package available list app-scanning.apps.tanzu.vmware.com --namespace tap-install

tanzu package install app-scanning-beta --package app-scanning.apps.tanzu.vmware.com \
    --version 0.1.0-beta \
    --namespace tap-install \
    --values-file tap-app-scanning-values.yaml
```
verify installation status:
```
tanzu package installed get -n tap-install                  app-scanning-beta 

NAMESPACE:          tap-install
NAME:               app-scanning-beta
PACKAGE-NAME:       app-scanning.apps.tanzu.vmware.com
PACKAGE-VERSION:    0.1.0-beta
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