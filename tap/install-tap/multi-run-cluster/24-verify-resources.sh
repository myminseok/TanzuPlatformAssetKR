#!/bin/bash
export SCRIPTDIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
source $SCRIPTDIR/../common-scripts/prepare-resources.sh -y

run_script "$SCRIPTDIR/../https-overlay/2-fetch-cnrs-run-cluster.sh"
