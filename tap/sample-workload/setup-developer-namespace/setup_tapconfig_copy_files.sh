#!/bin/bash
export SCRIPTDIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
source $SCRIPTDIR/../common-scripts/common.sh
load_env_file $SCRIPTDIR/../tap-env

copy_to_dir_if_not_exist $SCRIPTDIR/testing-pipeline.yml $TAP_ENV_DIR/
copy_to_dir_if_not_exist $SCRIPTDIR/scan-policy.yml $TAP_ENV_DIR/
copy_to_file_if_not_exist $SCRIPTDIR/gitops-ssh-secret-basic.yml.template $TAP_ENV_DIR/gitops-ssh-secret-basic.yml