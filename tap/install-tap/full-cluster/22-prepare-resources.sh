#!/bin/bash
export SCRIPTDIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
source $SCRIPTDIR/../common-scripts/prepare-resources.sh $@


run_script "$SCRIPTDIR/../https-overlay/1-apply-tap-gui-https-view-cluster.sh"

run_script "$SCRIPTDIR/../metastore-access/metadata-store-read-client-view-cluster.sh"

### TODO: on TAP 1.5, overlaying to scantemplate broke scan job validation webhook. 
run_script "$SCRIPTDIR/../scanning-overlay/scanning-ca-overlay.sh"

run_script "$SCRIPTDIR/../https-overlay/1-apply-cnrs-default-tls-run-cluster.sh"

run_script "$SCRIPTDIR/../tap-gui/tap-gui-viewer-service-account-rbac.sh"
