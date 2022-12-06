#!/bin/bash
SCRIPTDIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
source $SCRIPTDIR/common-scripts/common.sh
load_env_file $SCRIPTDIR/tap-env

print_current_k8s

tanzu package installed update api-portal -p api-portal.tanzu.vmware.com -v 1.2.2 --values-file tap-values-api-portal.yml -n tap-install
