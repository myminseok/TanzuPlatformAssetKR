#!/bin/bash
export SCRIPTDIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
source $SCRIPTDIR/../common-scripts/prepare-resources.sh $@

chmod +x $SCRIPTDIR/*.sh
chmod +x $SCRIPTDIR/../metastore-access/*.sh

echo "$SCRIPTDIR/grype-metastore.sh"
$SCRIPTDIR/grype-metastore.sh

echo "$SCRIPTDIR/scanning-ca-overlay.sh"
$SCRIPTDIR/scanning-ca-overlay.sh

echo "$SCRIPTDIR/../metastore-access/3-apply-grype-metastore-cert-build-cluster.sh"
$SCRIPTDIR/../metastore-access/3-apply-grype-metastore-cert-build-cluster.sh

echo "$SCRIPTDIR/tap-gui-viewer-service-account-rbac.sh"
$SCRIPTDIR/tap-gui-viewer-service-account-rbac.sh

