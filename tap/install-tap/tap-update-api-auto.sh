#!/bin/bash
SCRIPTDIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
source $SCRIPTDIR/common-scripts/common.sh
load_env_file $SCRIPTDIR/tap-env

print_current_k8s

tanzu package installed update api-auto-registration -p apis.apps.tanzu.vmware.com -v 0.1.1 --values-file tap-values-api-auto.yml -n tap-install
