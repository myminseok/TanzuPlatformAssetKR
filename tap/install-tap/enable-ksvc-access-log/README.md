
# Enabling request logging in knative serving
by following https://knative.dev/docs/serving/observability/logging/request-logging/


## how to apply using overlay

#### steps
1. create secrets for overlay
```
kubectl delete -f knative-cm-config-observability-overlay.yml
kubectl apply -f knative-cm-config-observability-overlay.yml
```
2. apply the overlay to tap-values.yml 

```
package_overlays:
- name: cnrs
  secrets:
  - name: knative-cm-config-observability-overlay

```
and update TAP

3. check the configmap
delete the configmap to apply the change from overlay.

```
kubectl delete cm -n knative-serving config-observability 

kubectl patch packageinstall/cnrs -n tap-install -p '{"spec":{"paused":true}}' --type=merge
kubectl patch packageinstall/cnrs -n tap-install -p '{"spec":{"paused":false}}' --type=merge%          

kubectl get cm -n knative-serving config-observability -o yaml

```
4. once the configmap is updated, access logging should be enabled automatically.
```
k logs -n my-space service/tanzu-java-web-app-00001-private -c queue-proxy -f
k logs -n my-space deployment.apps/tanzu-java-web-app-00001-deployment -c queue-proxy -f
tanzu apps workload tail tanzu-java-web-app --namespace my-space

```




## manual updates
1. update configmap directly.
```
a) k get cm -n knative-serving config-observability -o yaml > config-observability.yml
b) and edit config-observability.yml

apiVersion: v1
data:
  logging.enable-request-log: "true"
  logging.request-log-template: '{"httpRequest": {"requestMethod": "{{.Request.Method}}", "requestUrl": "{{js .Request.RequestURI}}", "requestSize": "{{.Request.ContentLength}}", "status": {{.Response.Code}}, "responseSize": "{{.Response.Size}}", "userAgent": "{{js .Request.UserAgent}}", "remoteIp": "{{js .Request.RemoteAddr}}", "serverIp": "{{.Revision.PodIP}}", "referer": "{{js .Request.Referer}}", "latency": "{{.Response.Latency}}s", "protocol": "{{.Request.Proto}}"}, "traceId": "{{index .Request.Header "X-B3-Traceid"}}"}'
  _example: |
...
```
c) k delete -f config-observability.yml && k apply -f config-observability.yml

2. once the configmap is updated, access logging should be enabled automatically.
```
k logs -n my-space service/tanzu-java-web-app-00001-private -c queue-proxy -f
k logs -n my-space deployment.apps/tanzu-java-web-app-00001-deployment -c queue-proxy -f
tanzu apps workload tail tanzu-java-web-app --namespace my-space

```

