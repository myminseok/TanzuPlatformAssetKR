#!/bin/bash
export SCRIPTDIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
source $SCRIPTDIR/../common-scripts/prepare-resources.sh $@

PROFILE="full"

chmod +x $SCRIPTDIR/*.sh
chmod +x $SCRIPTDIR/../https-overlay/*.sh


echo "$SCRIPTDIR/../https-overlay/1-apply-tap-gui-https-view-cluster.sh"
$SCRIPTDIR/../https-overlay/1-apply-tap-gui-https-view-cluster.sh
echo "$SCRIPTDIR/../https-overlay/1-apply-cnrs-default-tls-run-cluster.sh"
$SCRIPTDIR/../https-overlay/1-apply-cnrs-default-tls-run-cluster.sh
echo "$SCRIPTDIR/../multi-build-cluster/scanning-ca-overlay.sh"
$SCRIPTDIR/../multi-build-cluster/scanning-ca-overlay.sh
