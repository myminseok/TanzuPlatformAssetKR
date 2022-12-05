## it will create ~/.tapconfig which will use to load `TAP_ENV` environment variable
## and copy TanzuPlatformAssetKR/tap/install-tap/tap-env.template to ~/tap-config/tap-env

#!/bin/bash
export SCRIPTDIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
source $SCRIPTDIR/common-scripts/common.sh

if [ -z $1 ]; then
  echo "$0 /path/to/tap-env-file"
  exit 1
fi

TAP_ENV_FILE=$1
set_tapconfig $TAP_ENV_FILE
