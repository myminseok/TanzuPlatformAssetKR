## it will create ~/.tapconfig which will use to load `TAP_ENV` environment variable
## and copy TanzuPlatformAssetKR/tap/install-tap/tap-env.template to ~/tap-config/tap-env

#!/bin/bash
export SCRIPTDIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
source $SCRIPTDIR/common-scripts/common.sh

if [ -z $1 ]; then
  echo "Usage: $0 /path/to/tap-env-file"
  echo " - /path/to/tap-env-file: it can be existing path to tap-env file or new path."
  echo "                          the directory will be created if not exist and tap-env.template will be copied."
  exit 1
fi

TAP_ENV_FILE=$1
set_tapconfig $TAP_ENV_FILE
