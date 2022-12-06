#!/bin/bash
export SCRIPTDIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
source $SCRIPTDIR/../common-scripts/prepare-resources.sh $@

run_script "$SCRIPTDIR/../https-overlay/1-apply-tap-gui-https-view-cluster.sh"

run_script "$SCRIPTDIR/../https-overlay/1-apply-cnrs-default-tls-run-cluster.sh"

run_script "$SCRIPTDIR/../multi-build-cluster/scanning-ca-overlay.sh"

run_script "$SCRIPTDIR/../multi-build-cluster/tap-gui-viewer-service-account-rbac.sh"