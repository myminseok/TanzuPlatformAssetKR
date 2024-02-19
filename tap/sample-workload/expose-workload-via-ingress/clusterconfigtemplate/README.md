https://docs.vmware.com/en/VMware-Tanzu-Reference-Architecture/services/tanzu-solutions-workbooks/solution-workbooks-tap-workloads-avi-l4-l7.html

```
kubectl get ClusterConfigTemplate server-template -o yaml -ojsonpath='{.spec.ytt}' > spec-ytt.yaml

SPEC_YTT=$(cat spec-ytt.yaml) yq eval -i '.spec.ytt |= strenv(SPEC_YTT)' avi-l4-l7-server-template.yaml

yq eval -i '.metadata.name = "avi-l4-l7-server-template"' avi-l4-l7-server-template.yaml

kubectl apply -f avi-l4-l7-server-template.yaml





k get clustersupplychains
NAME                         READY   REASON   AGE
scanning-image-scan-to-url   True    Ready    62m
source-test-scan-to-url      True    Ready    62m


k get clustersupplychains source-test-scan-to-url -o yaml > source-test-scan-to-url.yml

  selectorMatchExpressions:
  - key: apps.tanzu.vmware.com/workload-type
    operator: In
    values:
    - web
    - server
    - worker
    - avi-l4-l7-server
status:



kubectl get ingress -A



```
