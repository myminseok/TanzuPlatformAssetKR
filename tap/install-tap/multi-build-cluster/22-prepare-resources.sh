#!/bin/bash
export SCRIPTDIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
source $SCRIPTDIR/../common-scripts/prepare-resources.sh $@

chmod +x $SCRIPTDIR/*.sh
chmod +x $SCRIPTDIR/../metastore-access/*.sh

$SCRIPTDIR/grype-metastore.sh
$SCRIPTDIR/scanning-ca-overlay.sh
$SCRIPTDIR/../metastore-access/3-apply-metastore-cert-build-cluster.sh
$SCRIPTDIR/tap-gui-viewer-service-account-rbac.sh