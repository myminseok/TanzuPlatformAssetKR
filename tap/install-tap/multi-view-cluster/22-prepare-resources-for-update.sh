#!/bin/bash
export SCRIPTDIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
source $SCRIPTDIR/../common-scripts/prepare-resources.sh $@

run_script "$SCRIPTDIR/../https-overlay/1-apply-tap-gui-https-view-cluster.sh"

run_script "$SCRIPTDIR/../metastore-access/2-fetch-grype-metastore-access-from-view-cluster.sh"

## uncomment if 'metadata-store-read-client' is required.
#run_script "$SCRIPTDIR/../metastore-access/metadata-store-read-client-view-cluster.sh"
