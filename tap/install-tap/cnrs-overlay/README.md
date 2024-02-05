

## problem
workload revision will be keep growing as workload is updated. and wants to limit rol number of revision history.

```

NAME                                                  READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/node-express-00007-deployment         1/1     1            1           3d1h
deployment.apps/node-express-00009-deployment         0/0     0            0           173m
deployment.apps/node-express-00010-deployment         0/0     0            0           110m
deployment.apps/node-express-00011-deployment         0/1     1            0           106m
deployment.apps/tanzu-java-web-app-00010-deployment   0/0     0            0           127m
deployment.apps/tanzu-java-web-app-00011-deployment   0/0     0            0           123m
deployment.apps/tanzu-java-web-app-00012-deployment   1/1     1            1           103m

```

## solutions
knavie(CNRS) has configuration to control the revision history via configmap under `knative-serving` namespace. this configmap is managed by TAP package. and we can overlay those config via package overlay feature. for more reference: https://docs.vmware.com/en/Cloud-Native-Runtimes-for-VMware-Tanzu/2.3/tanzu-cloud-native-runtimes/customizing-cnrs.html


#### steps
1. create secrets for overlay via `cnrs-cm-overlay.yml`
```
kubectl apply -f cnrs-cm-overlay.yml -n tap-install 

kubectl get secrets cnrs-cm-overlay -n tap-install -o jsonpath='{.data.overlay-gc-cm\.yaml}' | base64 -d


```
2. apply the overlay to tap-values.yml(run profile)

```
package_overlays:
- name: cnrs
  secrets:
  - name: cnrs-cm-overlay

```

3. update TAP and see if configmap is reconciled.
```
kubectl get configmap config-gc --namespace knative-serving --output jsonpath='{.data}'
```
