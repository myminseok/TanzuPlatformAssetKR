#!/bin/bash
SCRIPTDIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
source $SCRIPTDIR/../common-scripts/common.sh

PROFILE="run"

if yml_arg_not_exist "$@"; then
  YML=$SCRIPTDIR/tap-values-${PROFILE}-1st-TEMPLATE.yml
fi

$SCRIPTDIR/../common-scripts/install-tap.sh -p $PROFILE -f $YML $@
