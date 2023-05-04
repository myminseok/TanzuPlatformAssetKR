#!/bin/bash

#!/bin/bash
if [ -z "$1" ]; then
  echo "please give path to tanzu-framework-*.tar"
  echo "Usage: $0 /path/to/tap-tar-dir"
  echo "  the folder should include:"
  echo "    tanzu-framework-linux-amd64.tar"
  exit 1
fi

TAP_BIN=$1

## detect  os.
OS=$(uname | tr '[:upper:]' '[:lower:]')
#ARCH=$(arch) 
ARCH="amd64" ## arm is not yet released
TAP_TAR_FILE="tanzu-framework-$OS-$ARCH-*.tar"
echo "TAP_TAR_FILE: $TAP_TAR_FILE"

## detect file
set -ex
if [ $(ls -al $TAP_BIN/$TAP_TAR_FILE | wc -l ) -eq 0 ]; then
  echo "ERROR file not found  $TAP_BIN/$TAP_TAR_FILE"
  exit 1
fi


## tanzu cli
set -ex
TAP_UNTAR_PATH=$TAP_BIN/tanzu
mkdir -p $TAP_UNTAR_PATH
if [ ! -d "$TAP_UNTAR_PATH/cli" ]; then
  echo "untar $TAP_TAR_FILE ..."
  tar xf $TAP_BIN/$TAP_TAR_FILE -C $TAP_UNTAR_PATH
fi

tap_cli=$(find $TAP_UNTAR_PATH/cli -name "tanzu-core-${OS}_${ARCH}")
echo $tap_cli
chmod +x $tap_cli
sudo cp $tap_cli /usr/local/bin/tanzu
export TANZU_CLI_NO_INIT=true
tanzu version


## cli plugin
export TANZU_CLI_NO_INIT=true
#tanzu plugin clean
tanzu plugin install --local $TAP_UNTAR_PATH/cli all
tanzu plugin list

#chmod +x $TAP_BIN/insight-1.0.1_linux_amd64
#cp $TAP_BIN/insight-1.0.1_linux_amd64 /usr/local/bin/insight 
