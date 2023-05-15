#!/bin/bash
tanzu package installed list -n tap-install | grep namespace-provisioner
tanzu package available get namespace-provisioner.apps.tanzu.vmware.com/0.3.1 --values-schema --namespace tap-install
