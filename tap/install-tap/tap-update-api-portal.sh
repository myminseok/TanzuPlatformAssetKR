#!/bin/bash
SCRIPTDIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
source $SCRIPTDIR/common-scripts/common.sh
check_tanzu_env_file
source $TANZU_ENV

tanzu package installed update api-portal -p api-portal.tanzu.vmware.com -v 1.2.2 --values-file tap-values-api-portal.yml -n tap-install
