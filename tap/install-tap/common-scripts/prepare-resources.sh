#!/bin/bash
COMMON_SCRIPTDIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
source $COMMON_SCRIPTDIR/common.sh
load_env_file $COMMON_SCRIPTDIR/../tap-env

parse_args "$@"

print_current_k8s

if [ "$YES" != "y" ]; then
 confirm_target_k8s
fi
echo ""

