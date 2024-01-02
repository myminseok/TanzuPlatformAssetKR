https://docs.vmware.com/en/VMware-Tanzu-Kubernetes-Grid/2.3/using-tkg/workload-packages-grafana.html

check package version
```
tanzu package available list grafana.tanzu.vmware.com -A

  NAMESPACE                  NAME                      VERSION                RELEASED-AT
  tanzu-package-repo-global  grafana.tanzu.vmware.com  7.5.16+vmware.1-tkg.1  2022-05-20 03:00:00 +0900 KST
  tanzu-package-repo-global  grafana.tanzu.vmware.com  7.5.17+vmware.2-tkg.1  2022-05-20 03:00:00 +0900 KST
  tanzu-package-repo-global  grafana.tanzu.vmware.com  7.5.7+vmware.1-tkg.1   2021-05-20 03:00:00 +0900 KST
  tanzu-package-repo-global  grafana.tanzu.vmware.com  7.5.7+vmware.2-tkg.1   2021-05-20 03:00:00 +0900 KST
```

edit grafana-data-values.yaml

```
echo -n "changeme" | base64
Y2hhbmdlbWU=
```

set dns.
```
192.168.0.28 grafana.lab.pcfdemo.net
```

open https://grafana.lab.pcfdemo.net/  admin / changeme

import `grafana-dashboard-example-tap-workload-tkg-extension.json`


delete
```
tanzu package installed delete grafana --namespace tkg-install
```

