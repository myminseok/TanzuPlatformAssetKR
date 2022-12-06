#!/bin/bash
export SCRIPTDIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
source $SCRIPTDIR/../common-scripts/prepare-resources.sh $@

run_script "$SCRIPTDIR/../https-overlay/1-apply-tap-gui-https-view-cluster.sh"

run_script "$SCRIPTDIR/../metastore-access/2-fetch-grype-metastore-cert-view-cluster.sh"

run_script "$SCRIPTDIR/metadata-store-read-client.sh"
