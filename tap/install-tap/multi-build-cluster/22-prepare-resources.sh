#!/bin/bash
export SCRIPTDIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
source $SCRIPTDIR/../common-scripts/prepare-resources.sh $@

run_script "$SCRIPTDIR/grype-metastore.sh"

run_script "$SCRIPTDIR/../scanning-overlay/scanning-ca-overlay.sh"

run_script "$SCRIPTDIR/../metastore-access/3-apply-grype-metastore-cert-build-cluster.sh"

run_script "$SCRIPTDIR/../tap-gui/tap-gui-viewer-service-account-rbac.sh"

