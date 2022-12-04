#!/bin/bash
_SCRIPTDIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )

set -e
source $_SCRIPTDIR/common.sh
load_env_file $_SCRIPTDIR/../tap-env

parse_args "$@"

if [ "$YES" != "y" ]; then
 confirm_target_k8s
fi

