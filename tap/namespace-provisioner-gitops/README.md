# testing  namespace provisioner gitops model with gitlab.

Tested on:
- TAP 1.6.3, 1.7.2
- gitlab

```
tanzu package installed list -A 
tap-install  tap      tap.tanzu.vmware.com                                 1.7.2                    
tap-install  namespace-provisioner  namespace-provisioner.apps.tanzu.vmware.com          0.5.0                  
```

### [sample git repo here](nsp-config-repo)

```
└── nsp-config-repo
    ├── nsp 
    │   ├── desired-namespaces.yaml  ## define list of desired namespace
    │   ├── namespaces.yml           ## template to be used to create namespace
    │  
    └── others 
        ├── role.yml 
        └── secret.yml
```

[desired-namespaces.yaml](nsp-config-repo/nsp/desired-namespaces.yaml)
```
#@data/values
---
namespaces:
#! The only required parameter is the name of the namespace. All additional values provided here 
#! for a namespace will be available under data.values for templating additional sources
- name: dev
- name: qa
- name: my-space

```


### [tap-values.yaml](tap-full-values.yml)

create gitlab secrets by following [docs](https://docs.vmware.com/en/VMware-Tanzu-Application-Platform/1.7/tap/namespace-provisioner-use-case7.html). There is a current limitation in kapp-controller which does not allow you to re-use the same Git secret multiple time: [see TAP 1.7 doc ](https://docs.vmware.com/en/VMware-Tanzu-Application-Platform/1.7/tap/namespace-provisioner-use-case3.html#git-private) - click `Using GitOps tab`.

[gitlab-auth-install.yml](gitlab-auth-install.yaml) 

```
k get secrets -A  | grep gitlab-auth
tap-install                  gitlab-auth                                                    Opaque                                2      141m
tap-install                  gitlab-auth-install
```

[tap-values.yaml](tap-full-values.yml) [see TAP 1.7 doc ](https://docs.vmware.com/en/VMware-Tanzu-Application-Platform/1.7/tap/namespace-provisioner-use-case3.html#git-authentication-for-private-repository-for-workloads-and-supply-chain-3) - click `Using GitOps tab`.
```
...
namespace_provisioner:
  controller: false
  gitops_install: ## mainly for desired namespace list
    ref: origin/main
    subPath: nsp
    url: https://gitlab.lab.pcfdemo.net/root/nsp-config-repo.git
    secretRef:
      name: gitlab-auth-install  ## Caution!!  There is a current limitation in kapp-controller which does not allow you to re-use the same Git secret multiple time
      namespace: tap-install
      create_export: true
  additional_sources: ## all other resource that  will be created on each desired namespaces.
  - git:
      ref: origin/main
      subPath: others
      url: https://gitlab.lab.pcfdemo.net/root/nsp-config-repo.git
      secretRef:
        name: gitlab-auth   ##
        namespace: tap-install
        create_export: true
  default_parameters:
    supply_chain_service_account:
      secrets:
      - from-nsp-gitops
      imagePullSecrets:
      - from-nsp-gitops
...
```


provision tap and package status

```
k get app -A | grep namespace
tap-install                  namespace-provisioner                Reconcile succeeded   2m10s          79m
tap-namespace-provisioning   provisioner                          Reconcile succeeded   7s             79m
```

### k8s resource from namespace provisioner gitops

created service account resources.

```
k get sa default -o yaml -n my-space
apiVersion: v1
imagePullSecrets:
- name: registries-credentials
- name: from-nsp-gitops
kind: ServiceAccount
metadata:
  name: default
  namespace: my-space
secrets:
- name: registries-credentials
- name: from-nsp-gitops
```

created secrets resources 
```
k get secrets -A | grep nsp-gitops
dev                          others-secret-from-nsp-gitops                                  kubernetes.io/basic-auth              2      23m
my-space                     others-secret-from-nsp-gitops                                  kubernetes.io/basic-auth              2      23m
qa                           others-secret-from-nsp-gitops                                  kubernetes.io/basic-auth              2      23m
tap-namespace-provisioning   test-simple-from-nsp-gitops                                    kubernetes.io/basic-auth              2      13m

```

created role resources.
```
k get role -A | grep nsp-gitops
dev                          others-role-from-nsp-gitops                       2024-01-15T15:24:36Z
my-space                     others-role-from-nsp-gitops                       2024-01-15T15:24:36Z
qa                           others-role-from-nsp-gitops                       2024-01-15T15:24:36Z

```


### namespace_provisioner.import_data_values_secrets
https://docs.vmware.com/en/VMware-Tanzu-Application-Platform/1.7/tap/namespace-provisioner-use-case3.html

create [user-defined-secrets-for-import.yaml](user-defined-secrets-for-import.yaml)

define [git-import.yaml](nsp-config-repo/others/git-import.yaml)

apply to  [tap-values.yaml](tap-full-values.yml)

```
namespace_provisioner:
  controller: false
  gitops_install:
  ...
  additional_sources:
  ...
  import_data_values_secrets:
  - name: user-defined-secrets
    namespace: tap-install
    create_export: true
```

verify resources.
```

k get secrets -A | grep import
dev                          others-imported-from-nsp-gitops                                kubernetes.io/basic-auth              2      12m
my-space                     others-imported-from-nsp-gitops                                kubernetes.io/basic-auth              2      12m
qa                           others-imported-from-nsp-gitops                                kubernetes.io/basic-auth              2      12m'


➜  namespace-provisioner-gitops git:(main) ✗ k get secrets -n dev                          others-imported-from-nsp-gitops -o yaml
apiVersion: v1
data:
  password: dmFsdWUy
  username: dmFsdWUx
kind: Secret
metadata:
  ...
  labels:
    kapp.k14s.io/app: "1705329201740697674"
    kapp.k14s.io/association: v1.4f712478e6e3567f39cfbe78624f8011
  name: others-imported-from-nsp-gitops
  namespace: dev
type: kubernetes.io/basic-auth

```


## TODO list
ytt_lib
https://docs.vmware.com/en/VMware-Tanzu-Application-Platform/1.7/tap/namespace-provisioner-customize-installation.html

