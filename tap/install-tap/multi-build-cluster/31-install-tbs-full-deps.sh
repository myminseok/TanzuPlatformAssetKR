#!/bin/bash
export SCRIPTDIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
source $SCRIPTDIR/../common-scripts/prepare-resources.sh $@

run_script "$SCRIPTDIR/../30-setup-repository-tbs-full-deps.sh" -y

run_script "$SCRIPTDIR/../31-install-tbs-full-deps.sh" -y

run_script "$SCRIPTDIR/../32-status-build-service.sh" -y