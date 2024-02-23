## problem
this doc shows how to increase fluxcd-source-controller resources by overlay. for more reference, https://docs.vmware.com/en/VMware-Tanzu-Application-Platform/1.7/tap/customize-package-installation.html
tested on TAP 1.7.2

## author and verify overlay 
```
kubectl get deploy -n flux-system fluxcd-source-controller -o yaml > fluxcd-source-controller-orig.yml
ytt -f fluxcd-source-controller-orig.yml -f fluxcd-source-overlay.yaml | grep -A 5 resources

```

## apply to tap
```
kubectl create secret generic fluxcd-source-controller-overlay -n tap-install --from-file=./fluxcd-source-controller-overlay.yaml 

```

updates tap-values
```
package_overlays:
- name: fluxcd-source-controller
  secrets:
  - name: fluxcd-source-controller-overlay
```

update tap 

```
tanzu package installed update ...
```
kick template
```
tanzu package installed kick -n tap-install fluxcd-source-controller
```

verify

```
kubectl get deploy -n flux-system fluxcd-source-controller -o yaml  -o yaml | grep -A 6 resources

        resources:
          limits:
            cpu: "2"
            memory: 2Gi
          requests:
            cpu: "1"

```
