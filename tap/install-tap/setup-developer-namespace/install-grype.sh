#!/bin/bash
SCRIPTDIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
source $SCRIPTDIR/../common-scripts/common.sh
load_env_file $SCRIPTDIR/../tap-env

tanzu package install grype-scanner-my-space5 \
  --package grype.scanning.apps.tanzu.vmware.com \
  --version 1.5.0 \
  --namespace tap-install \
  --values-file ./grype-values.yml