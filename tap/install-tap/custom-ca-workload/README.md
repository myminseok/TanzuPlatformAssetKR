
Injecting CA to workload pod with supply chain.
it uses ootb-templates overlay and knative serving overlay. it doesn't use workload.yml
that the injected ca is 'root' access that should be find in normal cases.

### procedure

1. TAP should be installed.

2. check TAP_ENV

3. define WORLOAD_CA_CERTIFICATE in tap-env file.
vi $TAP_ENV/tap-env
```
## EXPERIMENTAL: optional) custom CA to be injected to workload pod via ootb-template overlay. (without using workload.yml)
## used by install-tap/custom-ca-workload/apply.sh
## cat harbor.crt | base6d -w0
## harbor.nestedlab.pcfdemo.net. 
WORLOAD_CA_CERTIFICATE="LSxxxK..."
```
3. apply.sh
ootb-templates-overlay and knative-serving-overlay should be created.

4. update tap
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


run tap/install-tap/full-cluster/23-update-tap.sh
or

run tap/install-tap/multi-{profile}-cluster/23-update-tap.sh

5. check.sh

run tap/install-tap/custom-ca-workload/check.sh
```
➜  custom-ca-workload git:(main) ✗ ./check.sh
[ENV] Loading env from ~/.tapconfig
[ENV] Using env from '/Users/kminseok/_dev/tanzu-main/nested-lab/tap/tap-env'
---------------------------------------------------------------------------------------
Checking cnrs updates(persistent volume) to 'config-network' -n knative-serving
  [OK] applied the cnrs updates to 'config-network' -n knative-serving
    kubectl get cm config-features -n knative-serving -o yaml | grep 'persistent-volume' | grep 'enabled'
```

6. deploy sample workload
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
```

7. check pods.
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
