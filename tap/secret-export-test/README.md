## Export Secrets from source namespace using secretgen.
1.  create a secret and SecretExport on any namespace
```
kubectl create ns my-space-source
kubectl apply -n my-space-source -f secret.yml
kubectl apply -n my-space-source -f secretexport.yml
```

```
kubectl get secrets -n my-space-source

NAME         TYPE                     DATA   AGE
gitops-ssh   kubernetes.io/ssh-auth   4      34s
```

2.  Create the SecretImport, then secretgen will creates secret to the target namespace.

```
kubectl create ns my-space-target
```

```
kubectl get secrets -n my-space-target
NAME                     TYPE                             DATA   AGE
```

```
kubectl apply -n my-space-target -f secretimport.yml
```

```
kubectl get secrets -n my-space-target

NAME                     TYPE                             DATA   AGE
gitops-ssh               kubernetes.io/ssh-auth           4      4s
```
## Using namespace provisioner
alternatively, use [namespace provisioner](https://docs.vmware.com/en/VMware-Tanzu-Application-Platform/1.7/tap/namespace-provisioner-customize-installation.html#add-additional-resources-to-your-namespaces-from-your-gitops-repository-0).
namespace provisioner with gitops, Create the SecretImport resource in their gitops repo and add that location in the additional_sources of namespace provisioner tap values. on namespace provisoner manages a new namespace, it will create the SecretImport from the additional sources, and secretgen will create the actual secret of the exported secret

