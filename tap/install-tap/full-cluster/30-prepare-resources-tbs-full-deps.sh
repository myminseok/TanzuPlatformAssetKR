#!/bin/bash
export SCRIPTDIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
source $SCRIPTDIR/../common-scripts/common.sh
load_env_file $SCRIPTDIR/../tap-env

$SCRIPTDIR/../06-offline-relocate-images-tbs-full-deps.sh $@
$SCRIPTDIR/../30-prepare-resources-tbs-full-deps.sh $@