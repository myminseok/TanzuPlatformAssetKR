#!/bin/bash


# tanzu package installed list -n tap-install | grep grype
tanzu package available get grype.scanning.apps.tanzu.vmware.com/1.5.0 --values-schema --namespace tap-install
