

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

####
it is not set by default. and will use default value from package(`overlay-knative-gc-defaults.yaml`). fetch example config.
```
kubectl get configmap config-gc --namespace knative-serving --output jsonpath='{.data._example}
```

```

apiVersion: v1
kind: ConfigMap
metadata:
  name: config-gc
  namespace: knative-serving
  labels:
    app.kubernetes.io/name: knative-serving
    app.kubernetes.io/component: controller
    app.kubernetes.io/version: devel
  annotations:
    knative.dev/example-checksum: "aa3813a8"
data:
  _example: |
    ################################
    #                              #
    #    EXAMPLE CONFIGURATION     #
    #                              #
    ################################

    # This block is not actually functional configuration,
    # but serves to illustrate the available configuration
    # options and document them in a way that is accessible
    # to users that `kubectl edit` this config map.
    #
    # These sample configuration options may be copied out of
    # this example block and unindented to be in the data block
    # to actually change the configuration.

    # ---------------------------------------
    # Garbage Collector Settings
    # ---------------------------------------
    #
    # Active
    #   * Revisions which are referenced by a Route are considered active.
    #   * Individual revisions may be marked with the annotation
    #      "serving.knative.dev/no-gc":"true" to be permanently considered active.
    #   * Active revisions are not considered for GC.
    # Retention
    #   * Revisions are retained if they are any of the following:
    #       1. Active
    #       2. Were created within "retain-since-create-time"
    #       3. Were last referenced by a route within
    #           "retain-since-last-active-time"
    #       4. There are fewer than "min-non-active-revisions"
    #     If none of these conditions are met, or if the count of revisions exceed
    #      "max-non-active-revisions", they will be deleted by GC.
    #     The special value "disabled" may be used to turn off these limits.
    #
    # Example config to immediately collect any inactive revision:
    #    min-non-active-revisions: "0"
    #    max-non-active-revisions: "0"
    #    retain-since-create-time: "disabled"
    #    retain-since-last-active-time: "disabled"
    #
    # Example config to always keep around the last ten non-active revisions:
    #     retain-since-create-time: "disabled"
    #     retain-since-last-active-time: "disabled"
    #     max-non-active-revisions: "10"
    #
    # Example config to disable all garbage collection:
    #     retain-since-create-time: "disabled"
    #     retain-since-last-active-time: "disabled"
    #     max-non-active-revisions: "disabled"
    #
    # Example config to keep recently deployed or active revisions,
    # always maintain the last two in case of rollback, and prevent
    # burst activity from exploding the count of old revisions:
    #      retain-since-create-time: "48h"
    #      retain-since-last-active-time: "15h"
    #      min-non-active-revisions: "2"
    #      max-non-active-revisions: "1000"
```

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
kubectl get configmap config-gc --namespace knative-serving --output jsonpath='{.data.max-non-active-revisions}
```
if it doesn't apply, delete the configmap and wait until it is reconciled automatically.
```
kubectl delete configmap config-gc -n knative-serving 
```
