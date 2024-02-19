This config works
TKG2.3
TAP 1.7.2
====================


### Initial TKGm workload cluster
```
k get app -A
NAMESPACE    NAME                                DESCRIPTION           SINCE-DEPLOY   AGE
tkg-system   antrea                              Reconcile succeeded   3m             31m
tkg-system   load-balancer-and-ingress-service   Reconcile succeeded   4m14s          31m
tkg-system   metrics-server                      Reconcile succeeded   4m2s           31m
tkg-system   secretgen-controller                Reconcile succeeded   4m24s          31m
tkg-system   vsphere-cpi                         Reconcile succeeded   74s            31m
tkg-system   vsphere-csi                         Reconcile succeeded   4m20s          31m

```


### install tkg extension(cert-manager, contour)

https://github.com/myminseok/vmware-docs/tree/main/tkgext-main/tkgm2.3


===================

### install TAP (without cert-manager, contour)

https://docs.vmware.com/en/VMware-Tanzu-Application-Platform/1.6/tap/security-and-compliance-tls-and-certificates-ingress-issuer.html

Ingress certificates inventory in Tanzu Application Platform

https://docs.vmware.com/en/VMware-Tanzu-Application-Platform/1.6/tap/security-and-compliance-tls-and-certificates-ingress-inventory.html



### install tap with default self signed issuer


#### create custom cert secrets

```
## *.view.tap.lab.pcfdemo.net

cd generate-self-signed-cert

kubectl create secret tls tap-wildcard-cert --key="domain.key" --cert="domain.crt" -n tap-gui

```

```
k apply -f delegation-custom-cert-tls.yml
```

```
k apply -f  tap-selfsigned-issuer.yml
```

### set custom cert to tap-gui, app-live-view-server
https://docs.vmware.com/en/VMware-Tanzu-Application-Platform/1.6/tap/tap-gui-tls-enable-tls-existing-cert.html

apply tap-values.yml

```
k get httpproxy -A                                      
NAMESPACE        NAME                             FQDN                                              TLS SECRET                            STATUS   STATUS DESCRIPTION
api-portal       api-portal                       api-portal.view.tap.lab.pcfdemo.net               api-portal-tls-cert                   valid    Valid HTTPProxy
app-live-view    appliveview                      appliveview.view.tap.lab.pcfdemo.net              tap-gui/tap-wildcard-cert             valid    Valid HTTPProxy
metadata-store   amr-cloudevent-handler-ingress   amr-cloudevent-handler.view.tap.lab.pcfdemo.net   amr-cloudevent-handler-ingress-cert   valid    Valid HTTPProxy
metadata-store   amr-graphql-ingress              amr-graphql.view.tap.lab.pcfdemo.net              amr-ingress-cert                      valid    Valid HTTPProxy
metadata-store   metadata-store-ingress           metadata-store.view.tap.lab.pcfdemo.net           ingress-cert                          valid    Valid HTTPProxy
tap-gui          tap-gui                          tap-gui.view.tap.lab.pcfdemo.net                  tap-gui/tap-wildcard-cert             valid    Valid HTTPProxy

```
