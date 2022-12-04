#!/bin/bash
export SCRIPTDIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
source $SCRIPTDIR/../common-scripts/prepare-resources.sh $@

chmod +x $SCRIPTDIR/*.sh
chmod +x $SCRIPTDIR/../https-overlay/*.sh
chmod +x $SCRIPTDIR/../metastore-access/*.sh

$SCRIPTDIR/../https-overlay/1-apply-tap-gui-https-view-cluster.sh
#$SCRIPTDIR/../metastore-access/1-check-metastore-health-view-cluster.sh
$SCRIPTDIR/../metastore-access/2-fetch-metastore-cert-view-cluster.sh
$SCRIPTDIR/metadata-store-read-client.sh