#!/bin/bash
SCRIPTDIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )

chmod +x $SCRIPTDIR/*.sh
chmod +x $SCRIPTDIR/../https-overlay/*.sh

$SCRIPTDIR/../https-overlay/1-apply-tap-gui-https-view-cluster.sh
$SCRIPTDIR/../multi-build-cluster/scanning-ca-overlay.sh
