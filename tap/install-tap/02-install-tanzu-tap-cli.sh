#!/bin/bash

## tanzu-framework-linux-amd64.tar
TAP_BIN=/data/tapbin-1.3

## tanzu cli
set -ex
TANZU_BIN=$TAP_BIN/tanzu
mkdir -p $TANZU_BIN
if [ ! -d "$TANZU_BIN/cli" ]; then
  echo "untar tanzu-framework-linux-amd64.tar"
  tar xf $TAP_BIN/tanzu-framework-linux-amd64.tar -C $TANZU_BIN
fi

tap_cli=$(find $TANZU_BIN/cli -name "tanzu-core-linux_amd64")
echo $tap_cli
chmod +x $tap_cli
sudo cp $tap_cli /usr/local/bin/tanzu
export TANZU_CLI_NO_INIT=true
tanzu version


## cli plugin
export TANZU_CLI_NO_INIT=true
#tanzu plugin clean
tanzu plugin install --local $TANZU_BIN/cli all
tanzu plugin list

#chmod +x $TAP_BIN/insight-1.0.1_linux_amd64
#cp $TAP_BIN/insight-1.0.1_linux_amd64 /usr/local/bin/insight 
