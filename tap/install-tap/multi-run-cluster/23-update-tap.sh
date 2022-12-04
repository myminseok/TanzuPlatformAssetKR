#!/bin/bash
SCRIPTDIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
source $SCRIPTDIR/../common-scripts/common.sh

PROFILE="run"

if yml_arg_not_exist "$@"; then
  YML_1st=$SCRIPTDIR/tap-values-${PROFILE}-1st-TEMPLATE.yml
  YML_2nd=$SCRIPTDIR/tap-values-${PROFILE}-2nd-overlay-TEMPLATE.yml
  YTT_YML="/tmp/tap-values-YTT-TEMPLATE.yml"
  set -ex
  ytt --ignore-unknown-comments -f $YML_1st -f $YML_2nd  > $YTT_YML
  set +x
fi

$SCRIPTDIR/../common-scripts/update-tap.sh -p ${PROFILE} -f $YTT_YML $@