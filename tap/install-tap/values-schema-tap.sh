#!/bin/bash

#tanzu package available list -A
tanzu package available get tap.tanzu.vmware.com/1.5.0 --values-schema --namespace tap-install
