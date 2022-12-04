#!/bin/bash
SCRIPTDIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
source $SCRIPTDIR/common-scripts/common.sh
load_env_file $SCRIPTDIR/tap-env

APP=$1
kubectl patch packageinstall/$APP -n tap-install -p '{"spec":{"paused":true}}' --type=merge
kubectl patch packageinstall/$APP -n tap-install -p '{"spec":{"paused":false}}' --type=merge