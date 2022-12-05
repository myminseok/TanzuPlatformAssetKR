#!/bin/bash
export SCRIPTDIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
source $SCRIPTDIR/../common-scripts/prepare-resources.sh $@
load_env_file $SCRIPTDIR/../tap-env

PROFILE="run"

chmod +x $SCRIPTDIR/*.sh
chmod +x $SCRIPTDIR/../https-overlay/*.sh
chmod +x $SCRIPTDIR/../multi-build-cluster/*.sh

echo "$SCRIPTDIR/../https-overlay/1-apply-cnrs-default-tls-run-cluster.sh"
$SCRIPTDIR/../https-overlay/1-apply-cnrs-default-tls-run-cluster.sh

echo "$SCRIPTDIR/../multi-build-cluster/tap-gui-viewer-service-account-rbac.sh"
$SCRIPTDIR/../multi-build-cluster/tap-gui-viewer-service-account-rbac.sh
