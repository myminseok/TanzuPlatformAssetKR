## Motivation
add PodDisruptionBudget for workload by adding overlaying the existing `config-template` ClusterConfigTemplate. 

with this overlay, in the workload.yml, you can:
- set PDB minAvailable, maxUnavailable 
- if autoscaling.knative.dev/minScale is more than 2, PDB is created. if less than 2 or empty, then PDB will be removed if exists.

this overlay works for `web` workload type, you can extend to other workload type by applying similar pattern. 

tested on TAP 1.7.2. this is revised from the original [github.com/categolj/k8s-manifests](https://github.com/categolj/k8s-manifests/blob/main/lime-build/config/platform/tap/overlays/ootb-templates-overlay-pdb.yaml)

### Test overlay
fetch ClusterConfigTemplate and apply the overlay and check PodDisruptionBudget
```
kubectl get ClusterConfigTemplate config-template -o yaml > config-template.yaml

ytt -f config-template.yaml -f config-template-pdb-overlay.yaml 
```

### Create a overlay secret
```
kubectl delete secret config-template-pdb-overlay-secret -n tap-install   
kubectl create secret generic config-template-pdb-overlay-secret  -n tap-install --from-file=./config-template-pdb-overlay.yaml
```
and verify
```
kubectl get secret config-template-pdb-overlay-secret -n tap-install  -o jsonpath='{.data.config-template-pdb-overlay\.yaml}' | base64 -d
```

### Updates TAP with the overlay
```
...
package_overlays:
- name: ootb-templates
  secrets:
  - name: config-template-pdb-overlay-secret
```
and update tap 
```
tanzu package installed update ...
```

### Verify clusterconfigtemplate having PDB template
```
kubectl get clusterconfigtemplate config-template -o yaml -o jsonpath='{.spec.ytt}' 
```

if not applied, then kick template && verify clusterconfigtemplate
```
tanzu package installed kick -n tap-install ootb-templates --yes
```
or delete template and kick package
```
kubectl delete clusterconfigtemplate config-template
tanzu package installed kick -n tap-install ootb-templates --yes
```

### Deploy workload and verify PDB


```
apiVersion: carto.run/v1alpha1
kind: Workload
metadata:
  name: tanzu-java-web-app
  labels:
    apps.tanzu.vmware.com/workload-type: web
    app.kubernetes.io/part-of: tanzu-java-web-app
  annotations:
    autoscaling.knative.dev/minScale: "2"
spec:
  source:
    git:
      url: https://github.com/myminseok/tanzu-java-web-app
      ref:
        branch: main
  params:
  - name: pdb_maxUnavailable
    value: 50%
```
> workload-type should be `web` to use the updated config-template
> autoscaling.knative.dev/minScale: if more than 2, PDB is created. if less than 2 or empty, then PDB will be removed if exists.
> pdb_minAvailable: set any value as string. default is 1 if empty.
> pdb_maxUnavailable: set any value as string. if pdb_minAvailable is set, then pdb_maxUnavailable is ignored.

```
tanzu apps workload apply --yes  -n my-space -f ./workload-tanzu-java-web-app.yaml
```

```
kubectl get pdb -n my-space tanzu-java-web-app
```

sometime delete following resources and wait for pdb
```
kubectl delete podintents.conventions.carto.run/tanzu-java-web-app -n my-space
kubectl delete apps.kappctrl.k14s.io/tanzu-java-web-app -n my-space
```

### reference
- 
