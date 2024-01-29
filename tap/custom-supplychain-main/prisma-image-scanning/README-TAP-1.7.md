This sample follows [scanning v2 guide](https://docs.vmware.com/en/VMware-Tanzu-Application-Platform/1.7/tap/scst-store-amr-install-amr-observer.html)

## prerequisites
- get prisma cloud access credentials which is only for supply chain. supply chain doesn't require prisma cloud app access permission in https://apps.paloaltonetworks.com/apps

- uninstall beta package from TAP 1.6.x
```
tanzu package installed delete amr-observer -n tap-install  -y
```

## install AMR
https://docs.vmware.com/en/VMware-Tanzu-Application-Platform/1.7/tap/scst-store-amr-auth-k8s-sa-autoconfiguration.html


### Install metadata_store, AMR for `FULL` profile cluster
- architecture: https://docs.vmware.com/en/VMware-Tanzu-Application-Platform/1.7/tap/scst-store-amr-architecture.html
- [Supply Chain Security Tools - Store](https://docs.vmware.com/en/VMware-Tanzu-Application-Platform/1.7/tap/scst-store-deployment-details.html)

- it is embedded in metadata_store in TAP full profile.


```
kubectl get all -n metadata-store

kubectl rollout restart -n metadata-store deployment.apps/amr-cloudevent-handler 

kubectl logs -n metadata-store deployment.apps/amr-cloudevent-handler -f
```

###  Install AMR cloud event handler on `VIEW` profile cluster
- https://docs.vmware.com/en/VMware-Tanzu-Application-Platform/1.7/tap/scst-store-amr-install-amr-cloudevent-handler.html

tap-values.yml
```
amr:
  cloudevent_handler:
    auth:
      kubernetes_service_accounts: true ## default true, #Enable authentication and authorization for services accessing Artifact Metadata Repository
      autoconfigure: true  ## default true, Delegate creation of authentication token secret to the artifact metadata repository
```


###  Install AMR observer on `Full`,`BUILD`,`RUN` profile cluster
The `AMR Observer` is deployed by default on the Tanzu Application Platform Full, Build and Run profiles

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


