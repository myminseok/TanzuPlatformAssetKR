# Prometheus and grafana for TAP.

References:
- https://github.com/kubernetes/kube-state-metrics?tab=readme-ov-file#helm-chart
- https://github.com/prometheus-community/helm-charts/tree/main/charts/kube-state-metrics



### Setup
```
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update
```

```
helm repo list
NAME                    URL                                               
prometheus-community    https://prometheus-community.github.io/helm-charts

```

```
helm upgrade --install tap-monitoring prometheus-community/kube-state-metrics -n monitoring --create-namespace -f helm-values.yaml
```

verify
```
kubectl get all -n kube-state-metrics

```

verify metric endpoints. kube-state-metrics is a simple service that listens to the Kubernetes API server and generates metrics about the state of the objects.The exposed metrics can be found here:
https://github.com/kubernetes/kube-state-metrics/blob/master/docs/README.md#exposed-metrics

The metrics are exported on the HTTP endpoint /metrics on the listening port.
In your case, tap-monitoring-kube-state-metrics.monitoring.svc.cluster.local:8080/metrics

```
kubectl port-forward service/tap-monitoring-kube-state-metrics -n monitoring 8080:8080
```

```
curl http://localhost:8080/metrics

# HELP kube_configmap_annotations Kubernetes annotations converted to Prometheus labels.
# TYPE kube_configmap_annotations gauge
# HELP kube_configmap_labels [STABLE] Kubernetes labels converted to Prometheus labels.
# TYPE kube_configmap_labels gauge
# HELP kube_configmap_info [STABLE] Information about configmap.
# TYPE kube_configmap_info gauge
kube_configmap_info{namespace="tap-install",configmap="spring-boot-conventions.app"} 1
kube_configmap_info{namespace="services-toolkit",configmap="kapp-config"} 1

```


helm uninstall  tap-monitoring -n kube-state-metrics-helm


