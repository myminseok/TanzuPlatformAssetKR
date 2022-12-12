
Injecting CA to workload pod with supply chain.
it uses ootb-templates overlay and knative serving overlay. it doesn't use workload.yml
that the injected ca is 'root' access that should be find in normal cases.

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



and set the secret in the workload.yml. (see workload-tanzu-java-web-app-ca.yaml).
```
apiVersion: carto.run/v1alpha1
kind: Workload
metadata:
  name: tanzu-java-web-app
  ...
spec:
  ...
  params:
    - name: volumes
      value: 
      - name: workload-ca-secret
        secret:
          secretName: workload-ca-secret 
    - name: volumeMounts
      value: 
      - name: workload-ca-secret
        mountPath: /etc/ssl/certs/workload-ca.crt
        subPath: workload-ca.crt    

```
> params.volumes: will be the `spec.volumes` section in the workload deployment. set secret name the will be created in the developer namespace manually in the following step.
> params.volumeMounts: will be the `spec.containers.volumeMounts` section in the workload deployment.  `subPath` is the key in the secret that has ca certificate contents. 
> refer to k8s doc for the spec. https://kubernetes.io/docs/concepts/configuration/secret/#using-secrets-as-files-from-a-pod

run `sample-create-file.sh`. it will do create secret
```
kubectl create secret generic workload-ca-secret  -n $DEVELOPER_NAMESPACE --from-file workload-ca.crt
```
and deploy workload.yml

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

kubectl exec [POD] [COMMAND] is DEPRECATED and will be removed in a future version. Use kubectl exec [POD] -- [COMMAND] instead.
Defaulted container "workload" out of: workload, queue-proxy
cnb@tanzu-java-web-app-00001-deployment-6fd7597dc-76979:/workspace$ id
uid=1000(cnb) gid=1000(cnb) groups=1000(cnb)

cnb@tanzu-java-web-app-00001-deployment-6fd7597dc-76979:/etc/ssl/certs$ ls -al workload-ca.crt
-rw-r--r-- 1 root root 1383 Dec  8 05:18 workload-ca.crt
cnb@tanzu-java-web-app-00001-deployment-6fd7597dc-76979:/etc/ssl/certs$ cat workload-ca.crt
-----BEGIN CERTIFICATE-----
MIID0DCCArigAwIBAgIJAMWKW6niC9SmMA0GCSqGSIb3DQEBCwUAMA8xDTALBgNV
BAMMBG15Y2EwIBcNMjIxMjA4MDM0NDM2WhgPMjA1MDA0MjUwMzQ0MzZaMGExCzAJ
BgNVBAYTAktPMQ4wDAYDVQQIDAVTZW91bDEOMAwGA1UEBwwFU2VvdWwxDDAKBgNV
```
