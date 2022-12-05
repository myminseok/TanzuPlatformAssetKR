#!/bin/bash
export SCRIPTDIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
source $SCRIPTDIR/../common-scripts/prepare-resources.sh -y

chmod +x $SCRIPTDIR/*.sh
chmod +x $SCRIPTDIR/../https-overlay/*.sh

echo "$SCRIPTDIR/../https-overlay/2-verify-cnrs-run-cluster.sh"
$SCRIPTDIR/../https-overlay/2-verify-cnrs-run-cluster.sh

