## problem
workload image by default will have sha based tag. and [OOTB option from TBS](https://docs.vmware.com/en/Tanzu-Build-Service/1.12/vmware-tanzu-build-service/managing-images.html) requires to tag as FQDN which is complicated. this docs shows how to add simple additional tags via workload yml. 

for example, there will be additional tags as following:
```
ghcr.io/myminseok/tap-service/minseok-supply-chain/my-npm-vue-my-space@sha256:60942671e40498742e8feb463a002593e53eb693e4e23b07899d936da8711b6b

ghcr.io/myminseok/tap-service/minseok-supply-chain/my-npm-vue-my-space:my_additional_tag
```
- tested on TAP 1.7.2
- it is referenced from https://github.com/Mpluya/tap-install-azure/blob/main/build-packaging/ootb-templates-overlay.yaml.
- customizing package: https://docs.vmware.com/en/VMware-Tanzu-Application-Platform/1.7/tap/customize-package-installation.html
- customizing cnrs package: https://docs.vmware.com/en/Cloud-Native-Runtimes-for-VMware-Tanzu/2.3/tanzu-cloud-native-runtimes/customizing-cnrs.html
- additionalTags from buipdpack: https://github.com/buildpacks-community/kpack/blob/main/docs/image.md
- workload parameters: additionalTags from TAP: https://docs.vmware.com/en/VMware-Tanzu-Application-Platform/1.7/tap/workloads-spec-reference.html#imageprovider-5

## author and verify overlay 
```
kubectl get ClusterImageTemplate kpack-template  -o yaml > kpack-template.yml
ytt -f kpack-template.yml -f kpack-template-overlay.yml | grep additional_tags

```

## apply to tap
```
kubectl create secret generic kpack-template-overlay -n tap-install --from-file=./kpack-template-overlay.yml 

```

updates tap-values
```
package_overlays:
- name: ootb-templates
  secrets:
  - name: kpack-template-overlay
```

update tap 

```
tanzu package installed update ...
```
kick template
```
kubectl delete secrets ootb-template-overlay -n tap-install 
tanzu package installed kick -n tap-install ootb-templates
```

verify

```
kubectl get ClusterImageTemplate kpack-template  -o yaml | grep additional_tags

end\n\n#@ def additional_tags():\n#@   tags = []\n#@   for val in param(\"additional_tags\"):\n#@     tags.append(\"{}:{}\".format(
      #@ image()\n  #@ if hasattr(data.values.params, \"additional_tags\"):\n  additionalTags:
      #@ additional_tags()\n  #@ end\n  serviceAccountName: #@ data.values.params.serviceAccount\n  builder:\n    kind:
    \  end   \n#@ end\n\n#@ def additional_tags():\n#@   tags = []\n#@   for val in
    param(\"additional_tags\"):\n#@     tags.append(\"{}:{}\".format( image(), val))\n#@
    image()\n  #@ if hasattr(data.values.params, \"additional_tags\"):\n  additionalTags:
    #@ additional_tags()\n  #@ end\n  serviceAccountName: #@ data.values.params.serviceAccount\n

```


workload.yml

```

apiVersion: carto.run/v1alpha1
kind: Workload
metadata:
  name: my-npm-vue
  labels:
    apps.tanzu.vmware.com/workload-type: web
    app.kubernetes.io/part-of: my-npm-vue
    apps.tanzu.vmware.com/has-tests: true
  annotations:
    autoscaling.knative.dev/minScale: "1"
spec:
  source:
    subPath: node-vue/my-npm-vue
    git:
      url : https://github.com/myminseok/tanzu-workload-samples
      ref:
        branch: main
  params:
  - name: additionalTags # it requires to tag as FQDN
    value: 
    - ghcr.io/myminseok/tap-service/minseok-supply-chain/my-npm-vue-my-space:additionalTags1
  - name: additional_tags # can put just tag portion only. customized kpack-template can generate acutal FQDN tag
    value:
    - "my_additional_tag"
```


then, image will have the additional tags besides of default sha tag.
```
    ghcr.io/myminseok/tap-service/minseok-supply-chain/my-npm-vue-my-space:my_additional_tag

```

