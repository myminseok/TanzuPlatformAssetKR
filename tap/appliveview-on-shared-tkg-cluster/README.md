
## motivation
This doc shows how to install TAP on k8s cluster where cert-manager and contour is alreay installed. for example, if you have to install TAP on share TKG cluster where harbor TKG extensions is already on.
this docs is tested on
- TKG 2.3
- TAP 1.7.2

## install TKG extensions
there will be following packages installed on TKGM workload cluster initially.
```
kubectl  get app -A
NAMESPACE    NAME                                DESCRIPTION           SINCE-DEPLOY   AGE
tkg-system   antrea                              Reconcile succeeded   3m             31m
tkg-system   load-balancer-and-ingress-service   Reconcile succeeded   4m14s          31m
tkg-system   metrics-server                      Reconcile succeeded   4m2s           31m
tkg-system   secretgen-controller                Reconcile succeeded   4m24s          31m
tkg-system   vsphere-cpi                         Reconcile succeeded   74s            31m
tkg-system   vsphere-csi                         Reconcile succeeded   4m20s          31m
```
- cert-manager, contour, harbor
follow https://github.com/myminseok/vmware-docs/tree/main/tkgext-main/tkgm2.3


## Install TAP (without cert-manager, contour)
The ingress issuer is designated by the single Tanzu Application Platform configuration value shared.ingress_issuer. It refers to a cert-manager.io/v1/ClusterIssuer. if you install TAP excluding cert-manager packaged on TAP and using cert-manager from TKG, required k8s resources will not be created by TAP automatically.
https://docs.vmware.com/en/VMware-Tanzu-Application-Platform/1.6/tap/security-and-compliance-tls-and-certificates-ingress-issuer.html

#### 1) Create missing Self Signed ClusterIssuer amd Certs manually
Ingress certificates inventory in Tanzu Application Platform (tap-selfsigned-issuer.yml)[tap-selfsigned-issuer.yml] and delegates those to TAP components by (delegation-custom-cert-tls.yml)[delegation-custom-cert-tls.yml]

#### 2) Install TAP (with default self signed issuer)
install TAP with default tap-values.yml. then all certs and secrets should be ready.
```
kubectl get httpproxy -A
kubectl get secrets -A
```
and you should be able to access TAP gui.

## Set Custom Certs to TAP (if need)

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
#### apply custom certs to TAP components.
refer to default tap-values. (tap-values-view-sample.yml)[tap-values-view-sample.yml], (tap-values-run-sample.yml)[tap-values-run-sample.yml]. 
- see https://docs.vmware.com/en/VMware-Tanzu-Application-Platform/1.6/tap/tap-gui-tls-enable-tls-existing-cert.html
- for TAP components list, see https://docs.vmware.com/en/VMware-Tanzu-Application-Platform/1.6/tap/security-and-compliance-tls-and-certificates-ingress-inventory.html

apply tap-values. then you can see the custom cert is applied to TAP.
```
kubectl get httpproxy -A                                      

NAMESPACE        NAME                             FQDN                                              TLS SECRET                            STATUS   STATUS DESCRIPTION
api-portal       api-portal                       api-portal.view.tap.lab.pcfdemo.net               api-portal-tls-cert                   valid    Valid HTTPProxy
app-live-view    appliveview                      appliveview.view.tap.lab.pcfdemo.net              tap-gui/tap-wildcard-cert             valid    Valid HTTPProxy
metadata-store   amr-cloudevent-handler-ingress   amr-cloudevent-handler.view.tap.lab.pcfdemo.net   amr-cloudevent-handler-ingress-cert   valid    Valid HTTPProxy
metadata-store   amr-graphql-ingress              amr-graphql.view.tap.lab.pcfdemo.net              amr-ingress-cert                      valid    Valid HTTPProxy
metadata-store   metadata-store-ingress           metadata-store.view.tap.lab.pcfdemo.net           ingress-cert                          valid    Valid HTTPProxy
tap-gui          tap-gui                          tap-gui.view.tap.lab.pcfdemo.net                  tap-gui/tap-wildcard-cert             valid    Valid HTTPProxy

```
