# Motivation

 [TAP `1.3` installation procedures](https://docs.vmware.com/en/VMware-Tanzu-Application-Platform/1.3/tap/GUID-install-intro.html) are really complicated and easy to make *"human mistakes"*. This projects is inteneded to provide following benefits
- provide comprehensive scripts that *"suggest clear install/update steps"* by following exact the same procedure from TAP public docs.
- cover single cluster and [multi cluster installation](https://docs.vmware.com/en/VMware-Tanzu-Application-Platform/1.3/tap/GUID-multicluster-about.html) by profile(full,view,build,run) based scripts
- provide scripts that requires minimal typing and confirm steps that *"lower human mistakes"*
- can *"seperate sensitive config files from scripts"*
- considered internet-ristricted environment.
- straight forward project sturcture and file naming to follow installation steps.
- easy to modify scripts for the future change with minimal efforts with shared structure.

This Scripts is not intened to 
- provides Gitops model based TAP installation.

Following scripts are compatible for TAP `1.3` and only tested on
- TKG on vSphere
- Ubuntu
- Mac OS

=======================================================================================
# Procedure

## Setup Jumpbox
To run this scripts conveniently, it would be good to have a config file.

### Prerequitest tools on Jumpbox.
- ytt
- [cluster essentials](https://docs.vmware.com/en/Cluster-Essentials-for-VMware-Tanzu/1.3/cluster-essentials/GUID-deploy.html) installed if it is not TKG
- cert-manager, contour will be installed as part of TAP insallation.


### Setup TAP_ENV (01-setup-tapconfig.sh)

to seperate config file from scripts, this script uses `~/.tapconfig` file and `TAP_ENV`, `TAP_ENV_DIR` environment variables

`~/.tapconfig` simply points to TAP_ENV file path
```
export TAP_ENV=/home/ubuntu/tap-config/tap-env
export TAP_ENV_DIR=/home/ubuntu/tap-config
```
- `TAP_ENV_DIR` has all config files required to this scripts.
-  `tap-env` file is key=value store where the KEY will be applied to tap-values file while installing and updating tap later on.

for example, following key in the `tap-env` file,
```
IMGPKG_REGISTRY_USERNAME="admin"
```
then the install-tap/update-tap script(tap/install-tap/multi-view-cluster/21-install-tap.sh) wil generate `/tmp/tap-values-build-1st-CONVERTED.yml` from the `tap/install-tap/multi-view-cluster/tap-values-view-1st-TEMPLATE.yml` by replacing the string `IMGPKG_REGISTRY_USERNAME` with the value from `tap-env` file.
so, tap/install-tap/multi-view-cluster/tap-values-view-1st-TEMPLATE.yml
```
shared:
  ...
    username: "IMGPKG_REGISTRY_USERNAME"
```
will be turned into `/tmp/tap-values-build-1st-CONVERTED.yml` as:
```
shared:
  ...
    username: "admin"
```
please note that the replacement only affects to the only file with filename included `*TEMPLATE*` such as `tap-values-{profile}-1st-TEMPLATE.yml`.

### how to create TAP_ENV
run following script with existing tap-env file or new file path.
```
01-setup-tapconfig.sh ~/tap-config/tap-env
```
it will `~/.tapconfig` will be created as following.
```
export TAP_ENV=/home/ubuntu/tap-config/tap-env
export TAP_ENV_DIR=/home/ubuntu/tap-config
```
and do following:
- if the given diretory is not exist, it will be created. 
- if the given file is not exist, then it will be copied from tap/install-tap/tap-env.template 
- it will copy all tap-values-TEMPLATE.yml to $TAP_ENV_DIR if the file doesn't exist in the $TAP_ENV_DIR

### install-tanzu-cli (02-install-tanzu-tap-cli.sh)
to install the tap cli 

download the following file to target folder 
```
mkdir /data/tapbin-1.3

ls -al 
tanzu-framework-linux-amd64.tar
```

and edit 02-install-tanzu-tap-cli.sh 
```
...
TAP_BIN=/data/tapbin-1.3
...
```
and run the scripts 02-install-tanzu-tap-cli.sh.


## Relocate TAP packages to local image repository

### Relocate tap packages (03-relocate-images-tap.sh)
do following before relocate packages (check TAP_ENV)
- docker login registry.tanzu.vmware.com
- docker login $IMGPKG_REGISTRY_HOSTNAME
- create repo  $IMGPKG_REGISTRY_HOSTNAME/$IMGPKG_REPO as PUBLIC

### Relocate tap `tbs full deps` depencencies (04-relocate-images-tbs-full-deps.sh)
relocate images to image registry(check TAP_ENV)

=======================================================================================

## Checks TKG cluster Readiness
run following checks for All Workload cluster (View, Build, Run, Iterate)

### check harbor access from TKG cluster
00-manual-check-custom-harbor-access-from-TKG-node.sh

### check kapp-controller-config from mgmt-cluster
on workload cluster. kapp controller init might fails if there is no proper config such as CA in kapp-controller-config in mgmt cluster.
ref: https://carvel.dev/kapp-controller/docs/v0.42.0/controller-config/

on management cluster
```
kubectl --context mgmt-admin@mgmt get secret build-kapp-controller-data-values \
-o jsonpath='{.data.values\.yaml}' | base64 -d
```
and on workload cluster
```
kubectl get cm -n tkg-system kapp-controller-config -o yaml
```

### NOTE: Changing Profile
Please note that, if you want to change profile, for example one cluster already installed `build` profile and wants to change to `run` profile, then it would be safe to delete the existing tap first before installing new tap profile as SOMETIMES the CR is not properly installed.
may use install-tap/99-delete-tap.sh.

=======================================================================================
## Install TAP on `VIEW` cluster

### locate k8s context

### 00-manual-check-custom-harbor-access-from-TKG-node.sh
see 'Check for All Workload cluster (View, Build, Run, Iterate)' section

### check kapp-controller-config from mgmt-cluster
see 'Check for All Workload cluster (View, Build, Run, Iterate)' section

### 11-setup-repository-tap.sh

### (Optional) edit tap-values-{profile}-1st-TEMPLATE.yml
```
$TAP_ENV_DIR/multi-{profile}-cluster/tap-values-{profile}-1st-TEMPLATE.yml
```
>  TAP_ENV_DIR: defined in  ~/.tapconfig 
original copy is in `install-tap/multi-{profile}-cluster/tap-values-{profile}-1st-TEMPLATE.yml`

### install tap with profile (21-install-tap.sh)
for installing cert-manager, ingress with minimum default configuratons
```
install-tap/multi-{profile}-cluster/21-install-tap.sh
```
it will show current k8s context.
```
[ENV] Loading env from ~/.tapconfig
[ENV] Using env from '/Users/kminseok/_dev/tanzu-main/homelab/tap/tap-env'
Current cluster: view-admin@view
Are you sure the target cluster 'view-admin@view'? (Y/y)
```
you may ignore the k8s context confirm with `-y` option. it is the same for all other scripts.
```
install-tap/multi-{profile}-cluster/21-install-tap.sh -y
```

it will use tap-values template file under the `TAP_ENV_DIR` and it will replace values from the `TAP_ENV` file.

or you may specify other file:
```
install-tap/multi-{profile}-cluster/21-install-tap.sh -f /path/to/my-values.yml
```
please note that the replacement only affects to the only file with filename included 'TEMPLATE' such as tap-values-{profile}-1st-TEMPLATE.yml.


you may debug script internal steps  with `--debug` option. it is the same for all other scripts.
```
install-tap/multi-{profile}-cluster/21-install-tap.sh  --debug
```

### prepare resources before updating TAP (22-prepare-resources.sh)

verify metastore access:
- [tanzu insight plugin](https://docs.vmware.com/en/VMware-Tanzu-Application-Platform/1.3/tap/GUID-cli-plugins-insight-cli-configuration.html) should be installed: 
run install-tap/metastore-access/1-check-metastore-health-view-cluster-manually.sh

run `install-tap/multi-{profile}-cluster/22-prepare-resources.sh`

install-tap/multi-{profile}-cluster/22-prepare-resources.sh will run following scripts internally:
- install-tap/https-overlay/1-apply-tap-gui-https-view-cluster.sh: will create `tap-gui-certificate` in  `tap-gui` namespace
- install-tap/metastore-access/metadata-store-read-client-view-cluster.sh
- install-tap/metastore-access/2-fetch-grype-metastore-cert-view-cluster.sh:  it will creates temp files to apply `build` cluster later on : /tmp/secret-metadata-store-read-write-client.txt, /tmp/store_ca.yaml


then records any output with '[MANUAL]' keyword from the standard output of `22-prepare-resources.sh`
```
---------------------------------------------------------------------------------------
[MANUAL]:  Manully update tap-values 'api_auto_registration.ca_cert_data' file on RUN/FULL cluster
---------------------------------------------------------------------------------------
file: $TAP_ENV_DIR/tap-values-{PROFILE}-2nd-overlay-TEMPLATE.yml"
api_auto_registration.ca_cert_data"
- Update CA for app workload domain from RUN cluster will be created AFTER TAP update completes with 'package_overlays' 
kubectl get secret -n tanzu-system-ingress cnrs-ca -o yaml -ojsonpath='{.data.ca\.crt}' | base64 -d
```

you may ignore the k8s context confirm with `-y` option.
```
install-tap/multi-{profile}-cluster/22-prepare-resources.sh -y
```

### edit tap-values-{profile}-2nd-overlay-TEMPLATE.yml
update any output from previous step especially with '[MANUAL]' keyword from the standard output of `22-prepare-resources.sh`
configure any changes from previous step
```
$TAP_ENV_DIR/tap-values-{profile}-2nd-overlay-TEMPLATE.yml
```
>  TAP_ENV_DIR: defined in  ~/.tapconfig 

### update tap with VIEW profile (23-update-tap.sh)
apply changes. repeats until successful.
```
install-tap/multi-{profile}-cluster/23-update-tap.sh
```
it will combine following two file by default:
- tap-values-{profile}-1st-TEMPLATE.yml
- tap-values-{profile}-2nd-overlay-TEMPLATE.yml

it will use yml file under the `TAP_ENV_DIR` and it will replace values from the `TAP_ENV` file to tap-values.yml

or you may specify other file:
```
install-tap/multi-{profile}-cluster/23-update-tap.sh -f /path/to/my-values.yml
```
please note that the replacement only affects to the only file with filename included 'TEMPLATE' such as tap-values-{profile}-1st-TEMPLATE.yml.


you may ignore the k8s context confirm with `-y` option.
```
install-tap/multi-{profile}-cluster/23-update-tap.sh -y
```

### verify tap updates (24-verify-resources.sh)

run `24-verify-resources.sh` to check the change applied. output should be with `OK`.
```
[ENV] Loading env from ~/.tapconfig
[ENV] Using env from '/data/tap-config/tap-env'
Current cluster: build-admin@build
=======================================================================================
[RUN-BEGIN] /data/TanzuPlatformAssetKR/tap/install-tap/full-cluster/../https-overlay/2-fetch-cnrs-run-cluster.sh

[ENV] Loading env from ~/.tapconfig
[ENV] Using env from '/data/tap-config/tap-env'
---------------------------------------------------------------------------------------
Checking cnrs updates(https) to 'config-network' -n knative-serving
  OK:  applied the cnrs updates to 'config-network' -n knative-serving
---------------------------------------------------------------------------------------
Checking if secret 'cnrs-ca' -n tanzu-system-ingress is created ...
  kubectl get secret -n tanzu-system-ingress cnrs-ca -o yaml -ojsonpath='{.data.ca\.crt}' | base64 -d
  OK:  secret 'cnrs-ca' -n tanzu-system-ingress is created
```

if there is 'ERROR' or 'WARNING', follow instruction from the output.
```
[ENV] Loading env from ~/.tapconfig
[ENV] Using env from '/data/tap-config/tap-env'
Current cluster: build-admin@build
=======================================================================================
[RUN-BEGIN] /data/TanzuPlatformAssetKR/tap/install-tap/full-cluster/../https-overlay/2-fetch-cnrs-run-cluster.sh

[ENV] Loading env from ~/.tapconfig
[ENV] Using env from '/data/tap-config/tap-env'
---------------------------------------------------------------------------------------
Checking cnrs updates(https) to 'config-network' -n knative-serving
Error from server (NotFound): configmaps "config-network" not found

  WARNING: Not Applied the cnrs updates to 'config-network' -n knative-serving
    kubectl get cm config-network -n knative-serving -o yaml | grep 'default-external-scheme: https'

  if not updated, then
  1. manually delete configmap:
    kubectl delete cm config-network -n knative-serving
  2. reconcine cnrs:
    ../29-reconcile-component.sh cnrs

```

### verify tap-gui access.
open https://tap-gui.TAP-DOMAIN (check TAP_ENV)

=======================================================================================
## Install TAP on `BUILD` cluster

### locate k8s context

### 00-manual-check-custom-harbor-access-from-TKG-node.sh
see 'Check for All Workload cluster (View, Build, Run, Iterate)' section

### check kapp-controller-config from mgmt-cluster
see 'Check for All Workload cluster (View, Build, Run, Iterate)' section

### 11-setup-repository-tap.sh

### (Optional) edit tap-values-{profile}-1st-TEMPLATE.yml
```
$TAP_ENV_DIR/multi-{profile}-cluster/tap-values-{profile}-1st-TEMPLATE.yml
```
>  TAP_ENV_DIR: defined in  ~/.tapconfig 
original copy is in `install-tap/multi-{profile}-cluster/tap-values-{profile}-1st-TEMPLATE.yml`


### install tap with profile (21-install-tap.sh)
for installing cert-manager, ingress with minimum default configuratons
```
install-tap/multi-{profile}-cluster/21-install-tap.sh
```

### prepare resources before updating TAP (22-prepare-resources.sh)

if you missed to fetch metastore cert from `view` cluster
- switch context to `view` cluster
- install-tap/metastore-access/2-fetch-grype-metastore-cert-view-cluster.sh
it will creates temp files to apply `build` cluster:
- /tmp/secret-metadata-store-read-write-client.txt
- /tmp/store_ca.yaml

run install-tap/multi-{profile}-cluster/22-prepare-resources.sh 
it will run following scripts internally:
- install-tap/multi-build-cluster/grype-metastore.sh: SecretExport info for grype.metastore in tap-values.yml
- install-tap/common-scripts/scanning-ca-overlay.sh: As a TAP operator, create CUSTOM CA configmap on DEVELOPER namespace. add additional config map as much as you need. 
- install-tap/metastore-access/3-apply-grype-metastore-cert-build-cluster.sh: apply metastore config
- install-tap/common-scripts/tap-gui-viewer-service-account-rbac.sh: create service accout to access `BUILD` cluster from Tap-gui on view cluster.

#### setup RBAC access to `BUILD` cluster from tap-gui on `VIEW` cluster
in the standard output, copy `CLUSTER_URL` and `CLUSTER_TOKEN` and edit install-tap/multi-view-cluster/tap-values-view-2nd-overlay-TEMPLATE.yml 
and and locate `VIEW` cluster and update the tap on `VIEW` cluster
- install-tap/multi-view-cluster/23-update-tap.sh

### edit tap-values-{profile}-2nd-overlay-TEMPLATE.yml
update any output from previous step especially with '[MANUAL]' keyword from the standard output of `22-prepare-resources.sh`
configure any changes from previous step
```
$TAP_ENV_DIR/tap-values-{profile}-2nd-overlay-TEMPLATE.yml
```
>  TAP_ENV_DIR: defined in  ~/.tapconfig 

optionally you can change supply_chanin as following.
```
#@ load("@ytt:overlay", "overlay")
#@overlay/match by=overlay.all
---
...
#@overlay/match missing_ok=True
supply_chain: testing_scanning # Can take testing, testing_scanning.
...
```

### update tap with profile (23-update-tap.sh)
apply changes until successful.
```
install-tap/multi-{profile}-cluster/23-update-tap.sh
```
it will combine following two file by default:
- tap-values-{profile}-1st-TEMPLATE.yml
- tap-values-{profile}-2nd-overlay-TEMPLATE.yml

or you may specify other file:
```
install-tap/multi-{profile}-cluster/23-update-tap.sh -f /path/to/my-values.yml
```

### install tap `tbs full deps` depencencies (31-setup-repository-tbs-full-deps.sh)

switch context to `build` and install package.
```
install-tap/31-setup-repository-tbs-full-deps.sh
install-tap/32-install-tbs-full-deps.sh
```

verify clusterbuilder status by running
```
install-tap/33-status-build-service.sh
```
all builder should be Ready status.


=======================================================================================
## Install TAP on `RUN` cluster

### locate k8s context

### 00-manual-check-custom-harbor-access-from-TKG-node.sh
see 'Check for All Workload cluster (View, Build, Run, Iterate)' section

### check kapp-controller-config from mgmt-cluster
see 'Check for All Workload cluster (View, Build, Run, Iterate)' section

### 11-setup-repository-tap.sh

### (Optional) edit tap-values-{profile}-1st-TEMPLATE.yml
```
$TAP_ENV_DIR/multi-{profile}-cluster/tap-values-{profile}-1st-TEMPLATE.yml
```
>  TAP_ENV_DIR: defined in  ~/.tapconfig 
original copy is in `install-tap/multi-{profile}-cluster/tap-values-{profile}-1st-TEMPLATE.yml`


### install tap with profile (21-install-tap.sh)
for installing cert-manager, ingress with minimum default configuratons
```
install-tap/multi-{profile}-cluster/21-install-tap.sh
```

### prepare resources before updating TAP (22-prepare-resources.sh)

run install-tap/multi-{profile}-cluster/22-prepare-resources.sh 
it will run following scripts internally:
- install-tap/https-overlay/1-apply-cnrs-default-tls-run-cluster.sh: create `cnrs-default-tls` in `tap-install` namespace
- install-tap/common-scripts/tap-gui-viewer-service-account-rbac.sh: create service accout to access `BUILD` cluster from Tap-gui on view cluster.

#### setup RBAC access to `RUN` cluster from tap-gui on `VIEW` cluster
in the standard output, copy `CLUSTER_URL` and `CLUSTER_TOKEN` and edit install-tap/multi-view-cluster/tap-values-view-2nd-overlay-TEMPLATE.yml 
and and locate `VIEW` cluster and update the tap on `VIEW` cluster
- install-tap/multi-view-cluster/23-update-tap.sh

### edit tap-values-{profile}-2nd-overlay-TEMPLATE.yml
update any output from previous step especially with '[MANUAL]' keyword from the standard output of `22-prepare-resources.sh`
configure any changes from previous step
```
$TAP_ENV_DIR/tap-values-{profile}-2nd-overlay-TEMPLATE.yml
```
>  TAP_ENV_DIR: defined in  ~/.tapconfig 


### update tap with profile (23-update-tap.sh)
apply changes until successful.
```
install-tap/multi-{profile}-cluster/23-update-tap.sh
```
it will combine following two file by default:
- tap-values-{profile}-1st-TEMPLATE.yml
- tap-values-{profile}-2nd-overlay-TEMPLATE.yml

or you may specify other file:
```
install-tap/multi-{profile}-cluster/23-update-tap.sh -f /path/to/my-values.yml
```

## verify update and fetch data(24-verify-resources.sh)


run `install-tap/multi-{profile}-cluster/24-verify-resources.sh`.
it will check following:
- check CA for app workload domain on RUN cluster. 
- check the cnrs updates to 'config-network' configmap in knative-serving namespace.

### check CA for app workload domain on RUN cluster
CA for app workload domain on RUN cluster will be created AFTER TAP update completes with 'package_overlays'(23-update-tap.sh)
```
 kubectl get secret -n tanzu-system-ingress cnrs-ca -o yaml \
   -ojsonpath='{.data.ca\.crt}' | base64 -d
```

### check the cnrs updates to 'config-network' configmap in knative-serving namespace.
```
kubectl get cm config-network -n knative-serving -o yaml \
  | grep 'default-external-scheme: https'
```
if not updated, then
- 1. manually delete configmap: 
```
kubectl delete cm config-network -n knative-serving
```
- 2. reconcine cnrs
```
../29-reconcile-component.sh cnrs
```

=======================================================================================
## Install TAP on `ITERATE` cluster

### locate k8s context

### 00-manual-check-custom-harbor-access-from-TKG-node.sh

### check kapp-controller-config from mgmt-cluster

### 11-setup-repository-tap.sh

### (Optional) edit tap-values-{profile}-1st-TEMPLATE.yml

### install tap with profile (21-install-tap.sh)

### prepare resources before updating TAP (22-prepare-resources.sh)

#### setup RBAC access to `ITERATE` cluster from tap-gui on `VIEW` cluster
in the standard output, copy `CLUSTER_URL` and `CLUSTER_TOKEN` and edit install-tap/multi-view-cluster/tap-values-view-2nd-overlay-TEMPLATE.yml 
and and locate `VIEW` cluster and update the tap on `VIEW` cluster
- install-tap/multi-view-cluster/23-update-tap.sh

### edit tap-values-{profile}-2nd-overlay-TEMPLATE.yml

### update tap with profile (23-update-tap.sh)

## verify update and fetch data(24-verify-resources.sh)
run `install-tap/multi-{profile}-cluster/24-verify-resources.sh`.
it will check following:
- check CA for app workload domain on ITERATE cluster. 
- check the cnrs updates to 'config-network' configmap in knative-serving namespace.

see the the same section(`verify update and fetch data(24-verify-resources.sh`) on RUN cluster

=======================================================================================
## Testing Sample workload

### Deploy workload on `BUILD` cluster
setup developer namespace
- install-tap/70-setup-developer-namespace-build-full-cluster.sh
it will create 
- scan policy 
- testing pipeline

and verify resources before deploying workload
```
kubectl get clusterbuilder
kubectl get ScanPolicy -A
kubectl get Pipeline -A
```

generate git token and gitops secrets
```
cp setup-developer-namespace/gitops-ssh-secret-basic.yml.template \
  /any/path/gitops-ssh-secret-basic.yml"
edit /any/path/gitops-ssh-secret-basic.yml

kubectl apply -f /any/path/gitops-ssh-secret-basic.yml -n $DEVELOPER_NAMESPACE
```

deploy workload
- sample-workload/multi-cluster-workload/1-create-sample-workload-on-build-cluster.sh
check workload from tap-gui and fetch `deliverable`:
- sample-workload/multi-cluster-workload/2-fetch-deliverable-from-build-cluster.sh
it will create files on /tmp folder
- /tmp/${WORKLOAD_NAME}-delivery.yml

### Deploy workload on `RUN` cluster
setup developer namespace
- install-tap/71-setup-developer-namespace-run-iterate-cluster.sh

apply gitops secrets (the same from previous step)
```
cp setup-developer-namespace/gitops-ssh-secret-basic.yml.template \
  /any/path/gitops-ssh-secret-basic.yml"
edit /any/path/gitops-ssh-secret-basic.yml
kubectl apply -f /any/path/gitops-ssh-secret-basic.yml -n $DEVELOPER_NAMESPACE
```

apply the delivery 
- sample-workload/multi-cluster-workload/3-apply-deliverable-to-run-cluster.sh

it will apply 
```
kubectl -n ${DEVELOPER_NAMESPACE} apply -f /tmp/${WORKLOAD_NAME}-deliverable.yml
```
and verify resources
```
kubectl get deliverables.carto.run -A
kubectl get httpproxy -A
```

and verify access
- sample-workload/multi-cluster-workload/4-verify.sh

### Deploy workload on `ITERATE` cluster
setup developer namespace
- install-tap/71-setup-developer-namespace-run-iterate-cluster.sh




