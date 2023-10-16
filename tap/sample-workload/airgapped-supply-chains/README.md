
## supplychain > build step 

### maven settings.xml
https://docs.vmware.com/en/VMware-Tanzu-Application-Platform/1.6/tap/tanzu-build-service-tbs-workload-config.html
```
--param-yaml buildServiceBindings='[{"name": "my-root-ca-cert", "kind": "Secret"}, {"name": "settings-xml", "kind": "Secret"}]'
```

### supplychain > build step > ca certs
- https://github.com/paketo-buildpacks/ca-certificates

## supply chain > testing step(tekton)
- https://docs.vmware.com/en/VMware-Tanzu-Application-Platform/1.6/tap/tekton-install-tekton.html
- https://docs.vmware.com/en/VMware-Tanzu-Buildpacks/services/tanzu-buildpacks/GUID-java-java-buildpack.html

## supplychain > tekton pipeline. mounting secret

- see testing-pipeline-airgapped.yml
- https://tekton.dev/docs/pipelines/workspaces/#secret => not work.
- hack: https://github.com/alexandreroman/tap-recipes/tree/main/air-gapped-supply-chains
