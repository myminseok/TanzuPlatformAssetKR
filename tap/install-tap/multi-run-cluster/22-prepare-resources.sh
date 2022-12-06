#!/bin/bash
export SCRIPTDIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
source $SCRIPTDIR/../common-scripts/prepare-resources.sh $@
load_env_file $SCRIPTDIR/../tap-env

run_script "$SCRIPTDIR/../https-overlay/1-apply-cnrs-default-tls-run-cluster.sh"

run_script "$SCRIPTDIR/../multi-build-cluster/tap-gui-viewer-service-account-rbac.sh"
