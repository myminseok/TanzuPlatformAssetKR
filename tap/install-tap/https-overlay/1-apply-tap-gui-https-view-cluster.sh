#!/bin/bash
SCRIPTDIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )

## only for view cluster, full cluster

kubectl apply -f $SCRIPTDIR/tap-gui-certificate.yaml -n tap-gui