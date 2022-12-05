#!/bin/bash
export SCRIPTDIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
source $SCRIPTDIR/../common-scripts/common.sh
load_env_file $SCRIPTDIR/../tap-env

export PROFILE="build"
copy_if_not_exist $SCRIPTDIR/tap-values-${PROFILE}-1st-TEMPLATE.yml $TAP_ENV_DIR/
copy_if_not_exist $SCRIPTDIR/tap-values-${PROFILE}-2nd-overlay-TEMPLATE.yml $TAP_ENV_DIR/