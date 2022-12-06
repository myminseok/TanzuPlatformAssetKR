#!/bin/bash


#tanzu package available list -A
tanzu package available get accelerator.apps.tanzu.vmware.com/1.3.1 --values-schema --namespace tap-install
