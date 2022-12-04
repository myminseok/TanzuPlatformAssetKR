#!/bin/bash
export SCRIPTDIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
source $SCRIPTDIR/../common-scripts/prepare-resources.sh $@

chmod +x $SCRIPTDIR/*.sh
chmod +x $SCRIPTDIR/../https-overlay/*.sh

$SCRIPTDIR/../https-overlay/1-apply-tap-gui-https-view-cluster.sh
$SCRIPTDIR/../multi-build-cluster/scanning-ca-overlay.sh
