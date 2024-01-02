https://docs.vmware.com/en/VMware-Tanzu-Kubernetes-Grid/2.3/using-tkg/workload-packages-prometheus.html



add kube-state-metrics scrape config to `prometheus-data-values.yaml`
```
prometheus:
  config:
    prometheus_yml: |
      scrape_configs:
      - job_name: 'tap-monitoring-kube-state-metrics'
        static_configs:
        - targets: ['tap-monitoring-kube-state-metrics.kube-state-metrics-helm.svc.cluster.local:8080']

```

check package version
```
  tanzu package available list prometheus.tanzu.vmware.com -A

  NAMESPACE                  NAME                         VERSION                RELEASED-AT
  tanzu-package-repo-global  prometheus.tanzu.vmware.com  2.27.0+vmware.1-tkg.1  2021-05-13 03:00:00 +0900 KST
  tanzu-package-repo-global  prometheus.tanzu.vmware.com  2.27.0+vmware.2-tkg.1  2021-05-13 03:00:00 +0900 KST
  tanzu-package-repo-global  prometheus.tanzu.vmware.com  2.36.2+vmware.1-tkg.1  2022-06-24 03:00:00 +0900 KST
  tanzu-package-repo-global  prometheus.tanzu.vmware.com  2.37.0+vmware.1-tkg.1  2022-10-26 03:00:00 +0900 KST
  tanzu-package-repo-global  prometheus.tanzu.vmware.com  2.37.0+vmware.3-tkg.1  2022-10-26 03:00:00 +0900 KST
```


install package
```
kubectl create ns tkg-install

tanzu package install prometheus \
--package prometheus.tanzu.vmware.com \
--version 2.37.0+vmware.3-tkg.1 \
--values-file prometheus-data-values.yaml \
--namespace tkg-install

```

verify

```
kubectl get all -n tanzu-system-monitoring
```

verify metrics.

```
kubectl get httpproxy -A
NAMESPACE                 NAME                                                              FQDN                                               TLS SECRET                                            STATUS   STATUS DESCRIPTION
tanzu-system-monitoring   prometheus-httpproxy                                              prometheus.lab.pcfdemo.net                         prometheus-tls                                        valid    Valid HTTPProxy
```


```
kubectl get svc -n tanzu-system-ingress
NAME      TYPE           CLUSTER-IP       EXTERNAL-IP    PORT(S)                      AGE
contour   ClusterIP      100.67.183.224   <none>         8001/TCP                     6d17h
envoy     LoadBalancer   100.68.231.222   192.168.0.29   80:30006/TCP,443:32090/TCP   6d17h

```

```
192.168.0.29 prometheus.lab.pcfdemo.net
```

open https://prometheus.lab.pcfdemo.net/


```
tanzu package installed delete prometheus --namespace tkg-install
```