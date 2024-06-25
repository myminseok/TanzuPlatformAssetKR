this sample elaborates from [official guide](https://docs.vmware.com/en/VMware-Tanzu-Reference-Architecture/services/tanzu-solutions-workbooks/solution-workbooks-tap-workloads-avi-l4-l7.html
) and added some opinions

```
kubectl get ClusterConfigTemplate server-template -o yaml > avi-l4-l7-server-template.yaml

kubectl get ClusterConfigTemplate server-template -o yaml -ojsonpath='{.spec.ytt}' > spec-ytt.yaml


SPEC_YTT=$(cat spec-ytt.yaml) yq eval -i '.spec.ytt |= strenv(SPEC_YTT)' avi-l4-l7-server-template.yaml


SPEC_YTT=$(cat spec-ytt-contour.yaml) yq eval -i '.spec.ytt |= strenv(SPEC_YTT)' avi-l4-l7-server-template.yaml


yq eval -i '.metadata.name = "avi-l4-l7-server-template"' avi-l4-l7-server-template.yaml


kubectl delete -f avi-l4-l7-server-template.yaml


kubectl apply -f avi-l4-l7-server-template.yaml
```

apply to tap-values
```
ootb_supply_chain_testing_scanning:
...
  supported_workloads:
  - type: web
    cluster_config_template_name: config-template
  - type: server
    cluster_config_template_name: server-template
  - type: worker
    cluster_config_template_name: worker-template
  - type: avi-l4-l7-server
    cluster_config_template_name: avi-l4-l7-server-template
```

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



tanzu apps workload apply --yes  -n my-space -f ./workload-tanzu-java-web-app-lb.yaml 

kubectl get svc -n my-space                                                                                                                         kminseokM7WYK.vmware.com: Mon Feb 19 17:33:40 2024

NAME                 TYPE           CLUSTER-IP      EXTERNAL-IP    PORT(S)                       AGE
tanzu-java-web-app   LoadBalancer   100.71.21.118   192.168.0.25   8080:32643/TCP,80:31569/TCP   6m48s

curl http://192.168.0.25:80



tanzu apps workload apply --yes  -n my-space -f ./workload-tanzu-java-web-app-ingress.yaml

kubectl get ingress -A

```
