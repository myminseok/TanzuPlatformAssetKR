#!/bin/bash
export SCRIPTDIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
source $SCRIPTDIR/../common-scripts/prepare-resources.sh $@

chmod +x $SCRIPTDIR/*.sh
chmod +x $SCRIPTDIR/../metastore-access/*.sh
set -x
$SCRIPTDIR/grype-metastore.sh
echo ""
$SCRIPTDIR/scanning-ca-overlay.sh
echo ""
$SCRIPTDIR/../metastore-access/3-apply-metastore-cert-build-cluster.sh
echo ""
$SCRIPTDIR/tap-gui-viewer-service-account-rbac.sh
set +x