#!/bin/bash

#tanzu package available list -A
tanzu package available get tap.tanzu.vmware.com/1.6.3 --values-schema --namespace tap-install

tanzu package available get namespace-provisioner.apps.tanzu.vmware.com/0.4.0  --namespace tap-install --default-values-file-output namespace-provisioner.yml
