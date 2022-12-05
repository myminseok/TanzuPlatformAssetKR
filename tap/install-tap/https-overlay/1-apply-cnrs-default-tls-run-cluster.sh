#!/bin/bash
SCRIPTDIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )

## only for run cluster, full cluster

kubectl create secret generic cnrs-default-tls -n tap-install \
  -o yaml \
  --dry-run=client \
  --from-file=$SCRIPTDIR/cnrs-default-tls.yml \
  | kubectl apply -f-

