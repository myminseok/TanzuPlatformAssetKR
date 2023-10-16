
## supplychain > build step 


> maven settings.xml
https://docs.vmware.com/en/VMware-Tanzu-Application-Platform/1.6/tap/tanzu-build-service-tbs-workload-config.html

```
--param-yaml buildServiceBindings='[{"name": "my-root-ca-cert", "kind": "Secret"}, {"name": "settings-xml", "kind": "Secret"}]'

```
supplychain > build step > ca certs
https://github.com/paketo-buildpacks/ca-certificates
BP_EMBED_CERTS=true

hack: https://github.com/alexandreroman/tap-recipes/tree/main/air-gapped-supply-chains



## supply chain > testing step(tekton)

https://docs.vmware.com/en/VMware-Tanzu-Application-Platform/1.6/tap/tekton-install-tekton.html

https://docs.vmware.com/en/VMware-Tanzu-Buildpacks/services/tanzu-buildpacks/GUID-java-java-buildpack.html

supplychain > tekton pipeline. mounting secret
https://tekton.dev/docs/pipelines/workspaces/#secret => not work.


```
kubectl apply -f ./maven-settings-secret.yml -n ${DEVELOPER_NAMESPACE}
kubectl apply -f ./maven-custom-certs.yml -n ${DEVELOPER_NAMESPACE}

tanzu apps workload create tanzu-java-web-app \
--git-repo https://github.com/myminseok/tanzu-java-web-app \
--git-branch main \
--type web \
--label app.kubernetes.io/part-of=tanzu-java-web-app \
--label apps.tanzu.vmware.com/has-tests=true \
--param-yaml buildServiceBindings='[{"name": "maven-settings", "kind": "Secret"}, {"apiVersion": "v1", "kind": "Secret", "name": "my-ca-certs"}]' \
--service-ref my-ca-certs=v1:Secret:my-ca-certs \
--yes -n ${DEVELOPER_NAMESPACE}
```

k get ClusterSourceTemplate source-template -o yaml > source-template.yml
k get ClusterImageTemplate kpack-template -o yaml > kpack-template.yml


k apply -f overlay-ootb-templates-airgapped.yml -n tap-install
```
package_overlays:
- name: ootb-templates
  secrets:
  - name: overlay-ootb-templates-airgapped
```



my-space    0s          Normal    ExceededResourceQuota          taskrun/scan-tanzu-java-web-app-wkh8c                                                TaskRun Pod exceeded available resources: pods "scan-tanzu-java-web-app-wkh8c-pod" is forbidden: exceeded quota: sandbox-resource-quotas, requested: limits.cpu=14, used: limits.cpu=0, limited: limits.cpu=9