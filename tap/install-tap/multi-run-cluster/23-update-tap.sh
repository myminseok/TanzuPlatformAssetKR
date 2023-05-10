#!/bin/bash
export SCRIPTDIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
source $SCRIPTDIR/../common-scripts/common.sh
load_env_file $SCRIPTDIR/../tap-env

PROFILE="run"

$SCRIPTDIR/../common-scripts/install-update-tap.sh --update -p ${PROFILE} $@