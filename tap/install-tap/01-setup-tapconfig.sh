## it will create ~/.tapconfig which will use to load `TAP_ENV` environment variable
## and copy TanzuPlatformAssetKR/tap/install-tap/tap-env.template to ~/homelab/tap-env

#!/bin/bash
SCRIPTDIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
source $SCRIPTDIR/common-scripts/common.sh

TAP_ENV_FILE=$1
set_tapconfig $TAP_ENV_FILE
