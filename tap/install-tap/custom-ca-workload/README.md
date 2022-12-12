
Injecting CA to workload pod with supply chain.
it uses ootb-templates overlay and knative serving overlay. it doesn't use workload.yml

### procedure

1. TAP should be installed.

2. check TAP_ENV

3. create ootb-templates-overlay on tap-install namespace.

```
install-tap/custom-ca-workload/apply.sh
```

4. update "ootb-templates-overlay" on tap.

vi $TAP_ENV/tap-values-{profile}-2nd-overlay-TEMPLATE.yml
```
...
#@overlay/match missing_ok=True
package_overlays:
- name: cnrs
  secrets:
  - name: cnrs-default-tls
  ## for workload ca on knative.
  - name: "knative-serving-overlay"
- name: ootb-templates
  secrets:
  ## for workload ca on knative.
  - name: "ootb-templates-overlay"
```
and run
```
install-tap/full-cluster/23-update-tap.sh
```
or
```
install-tap/multi-{profile}-cluster/23-update-tap.sh
```

5. create custom CA secret and deploy workload

prepare workload-ca.crt
and edit workload-tanzu-java-web-app-ca.yaml
```
apiVersion: carto.run/v1alpha1
kind: Workload
metadata:
  name: tanzu-java-web-app
  labels:
    apps.tanzu.vmware.com/workload-type: web
    app.kubernetes.io/part-of: tanzu-java-web-app
    apps.tanzu.vmware.com/has-tests: true
    apis.apps.tanzu.vmware.com/register-api: "true"
  annotations:
    autoscaling.knative.dev/minScale: "1"
spec:
  source:
    git:
      url: https://github.com/myminseok/tanzu-java-web-app
      ref:
        branch: main
spec:
  source:
    git:
      url: https://github.com/myminseok/tanzu-java-web-app
      ref:
        branch: main
  params:
    - name: volumes
      value: 
      - name: workload-ca-secret
        secret:
          secretName: workload-ca-secret #<-- name of the secret that contains ca. ie) workload-ca-secret
    - name: volumeMounts
      value: 
      - name: workload-ca-secret
        mountPath: /etc/ssl/certs/workload-ca.crt
        subPath: workload-ca.crt      #<-- key in the secret that is pointing to ca certificate. 

```
run
```
sample-create-file.sh
```

7. check the volume from the secret on the workload pod.
```
kubectl get po -n my-space

NAME                                                    READY   STATUS      RESTARTS   AGE
tanzu-java-web-app-00001-deployment-6fd7597dc-76979     2/2     Running     0          7m
tanzu-java-web-app-build-1-build-pod                    0/1     Completed   0          13m
tanzu-java-web-app-config-writer-qqn42-pod              0/1     Completed   0          8m8s
tanzu-java-web-app2-00001-deployment-697c4878dd-5224l   2/2     Running     0          11h
tanzu-java-web-app2-build-1-build-pod                   0/1     Completed   0          11h
tanzu-java-web-app2-config-writer-62btm-pod             0/1     Completed   0          11h
tanzu-java-web-app2-config-writer-9xj87-pod             0/1     Completed   0          11h
tanzu-java-web-app2-pdmzj-test-pod                      0/1     Completed   0          11h
```

8. verify the ca injected to /etc/ssl/certs

```
kubectl get po -n my-space  exec -it tanzu-java-web-app-00001-deployment-6fd7597dc-76979 -n my-space bash

cnb@tanzu-java-web-app-00001-deployment-6fd7597dc-76979:/etc/ssl/certs$ ls -al workload-ca.crt
-rw-r--r-- 1 root root 1383 Dec  8 05:18 workload-ca.crt
cnb@tanzu-java-web-app-00001-deployment-6fd7597dc-76979:/etc/ssl/certs$ cat workload-ca.crt
-----BEGIN CERTIFICATE-----
MIID0DCCArigAwIBAgIJAMWKW6niC9SmMA0GCSqGSIb3DQEBCwUAMA8xDTALBgNV
BAMMBG15Y2EwIBcNMjIxMjA4MDM0NDM2WhgPMjA1MDA0MjUwMzQ0MzZaMGExCzAJ
BgNVBAYTAktPMQ4wDAYDVQQIDAVTZW91bDEOMAwGA1UEBwwFU2VvdWwxDDAKBgNV
```