#!/bin/bash
SCRIPTDIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
source $SCRIPTDIR/common-scripts/common.sh
load_env_file $SCRIPTDIR/tap-env

if [ "$YES" != "y" ]; then
 confirm_target_k8s
fi

#kubectl edit PackageInstall cnrs -n tap-install
#kapp delete --app tap-ctrl -n tap-install
tanzu package installed delete tap -n tap-install 
