

# Prometheus and grafana for TAP.
Sample implementation for TAP key metrics. this is inspired by following references. tested on TAP 1.6.3.

References:
- https://apps-cloudmgmt.techzone.vmware.com/resource/how-configure-and-monitor-vmware-tanzu-application-platform-prometheus-loki-and-grafana#prerequisites
- https://vrabbi.cloud/post/monitoring-tap-with-prometheus-and-grafana/
- https://github.com/x95castle1/tap-grafana-dashboard-with-ksm
- https://github.com/kubernetes/kube-state-metrics

### Setup
```
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update
```

```
helm upgrade --install tap-monitoring prometheus-community/kube-prometheus-stack -n monitoring --create-namespace -f helm-values-modified.yaml
```

verify
```
kubectl get all -n monitoring

kubectl get ingress -A
NAMESPACE    NAME                                    CLASS    HOSTS                        ADDRESS        PORTS     AGE
monitoring   tap-monitoring-grafana                  <none>   grafana.lab.pcfdemo.net      192.168.0.29   80, 443   3m9s
monitoring   tap-monitoring-kube-promet-prometheus   <none>   prometheus.lab.pcfdemo.net   192.168.0.29   80, 443   3m9s
```

### Troubleshooting  
#### `tap-monitoring-kube-state-metrics` error 
sample implentation [`values-example.yaml`](https://github.com/vrabbi-tap/tap-kube-state-metrics/blob/main/values-example.yaml) is not compatible for TAP. and needs to be patched. you can see errors as following:
```
kubectl logs -n monitoring deployment.apps/tap-monitoring-kube-state-metrics -f 

[status,conditions]: [1]: [status]: strconv.ParseFloat: parsing \"Unknown\": invalid syntax
```
refer to the [related issue ticket](https://github.com/kubernetes/kube-state-metrics/issues/2070).
and solution is to patch . and replacing `Gauge` metric with `Info` in `values-example.yaml`. 
see `helm-values-modified.yaml`
```
 - name: workload_status
                help: Workload status from conditions
                each:
                  # type: Gauge
                  # gauge:
                  #   path: [status, conditions]
                  #   labelsFromPath:
                  #     type: ["type"] 
                  #     status: ["status"] # Unknown 
                  #     reason: ["reason"]
                  #     message: ["message"]
                  #     last_transition_ime: ["lastTransitionTime"]
                  #   valueFrom: ["status"]

                  type: Info
                  info:
                    path: [status, conditions]
                    labelsFromPath:
                      type: ["type"]
                      status: [ status ]                      
                      reason: ["reason"]
                      message: ["message"]
                      last_transition_Time: ["lastTransitionTime"]
                    valueFrom: ["status"]
```
see the detailed metric spec of [kube-state-metrics](https://github.com/kubernetes/kube-state-metrics/blob/main/docs/customresourcestate-metrics.md)

### add additional metrics and RBAC config
you can add additional metric to `kube-state-metrics` by patching `helm-values-modified.yaml` as following.
```
kube-state-metrics:
  rbac:
    extraRules:
    ...
    - apiGroups: ["app-scanning.apps.tanzu.vmware.com"]
      resources: ["imagevulnerabilityscans"]
      verbs: ["list", "watch"]
  customResourceState:
    enabled: true
    config:
      spec:
        resources:
          - groupVersionKind:
              group: app-scanning.apps.tanzu.vmware.com
              version: "v1alpha1"
              kind: ImageVulnerabilityScan
            labelsFromPath:
              name: [metadata, name]
              namespace: [metadata, namespace]
              image: [spec, registry, image]
              component: [metadata, labels, app.kubernetes.io/component]
              owner: [metadata, ownerReferences, "0", name]
              owner_type: [metadata, ownerReferences, "0", kind]
              workload: [metadata, labels, carto.run/workload-name]
              carto_resource: [metadata, labels, carto.run/resource-name]
              supply_chain: [metadata, labels, carto.run/supply-chain-name]
              scanner_name: [status, scannedBy, scanner, name]
              scanner_version: [status, scannedBy, scanner, version]
            metricNamePrefix: scst
            metrics:
              - name: image_vulnerability_scan_status
                help: Image vulnerability Scan status from conditions
                each:
                  type: Info
                  info:
                    path: [status, conditions]
                    labelsFromPath:
                      ref: [ status ]
```

# Useful metrics and Implementation.
all metrics are inspired from https://vrabbi.cloud/post/monitoring-tap-with-prometheus-and-grafana/

### Workloads
- workload without a matching supply chain
name, namespace, last_transition_time, Failure, Reason, Message
- Workload in Failed State
- Workloads with latest revision Not Ready
- Number of Workloads per workload type
- Number of wokrloads Per supply chain
- Number of workloads per source type: git sourced / OCI sourced
- workload with remote debugging enabled


### Workload Progressing or Failing (DONE)
Grafana query: 
```
cartographer_workload_status{status!="True", message!=""}
```
> workload, name, time(last) , namespace, status, reason, message

"Transform data" tab in grafana:
- "Sort by" transform:  "time" ascending order.
- "Organize fields" transform: select fields to display
- "Group by" transform: 1) name: group by 2) other column: calculated, Last


### Workload without a matching supply chain(DONE)
Grafana query: 
```
cartographer_workload_status{reason="SupplyChainNotFound", type="Ready"}
```

### Number of Workloads per workload type (DONE)
Grafana query: 
```
count(cartographer_workload_info{type=~".*"}) by (type)
```

### Tekton Details
- Successful Testing pipeline Runs per workloads
- failed Testing pipeline Runs per workloads
- Successful Config writer Tasks per workloads
- failed Config writer Tasks per workloads


### Tekton Pipeline Progressing or Failing (DONE)
Grafana query: 
```
tekton_pipeline_run_status{status!="True", message!=""}
```
> name, time(last) , namespace, status, reason, message

"Transform data" tab in grafana:
- "Sort by" transform:  "time" ascending order.
- "Organize fields" transform: select fields to display
- "Group by" transform: 1) name: group by 2) other column: calculated, Last


### Tanzu Build Service Details
- Number of workload Using each buildpacks
- clusterbuilder status


###  Build Progressing or Failing (DONE)
Grafana query: 
```
kpack_build_status{status!="True"}
```
> name, time(last) , namespace, status, reason
- "Transform data" tab in grafana:

"Transform data" tab in grafana:
- "Sort by" transform:  "time" ascending order.
- "Organize fields" transform: select fields to display
- "Group by" transform: 1) name: group by 2) other column: calculated, Last


### Number of NOT successful kpack build
Grafana query: 
```
kpack_build_status{type!="Succeeded"}
```

### Scanning details
- scanner package installations

### Image Vulnerability_ Scan - Progressing or Failed (DONE)
Grafana query: 
```
scst_image_vulnerability_scan_status{status!="True"}
```


### KNative 
- knative services in bad state
- Failed knative revisions
- knative service with latest Revision Not Ready


### Knative Progressing or Failing (DONE)
Grafana query: 
```
knative_service_status{status!="True"}
```
> name, time(last) , namespace, status, reason

"Transform data" tab in grafana:
- "Sort by" transform:  "time" ascending order.
- "Organize fields" transform: select fields to display
- "Group by" transform: 1) name: group by 2) other column: calculated, Last


### Deliverables
- Deliverables in Failed State
- Deliverable in good state
- Number of Deliverable Per source type

### Service Binding
- cluster instance classes
- Number of class Claim per cluster instance classes
- Class Claims status
- Resource claims status
- Failed Resource claims

