#!/bin/bash
export SCRIPTDIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
source $SCRIPTDIR/../common-scripts/prepare-resources.sh $@

run_script "$SCRIPTDIR/../metastore-secrets/grype-metastore.sh"

### TODO: on TAP 1.5, overlaying to scantemplate broke scan job validation webhook. 
run_script "$SCRIPTDIR/../scanning-overlay/scanning-ca-overlay.sh"

run_script "$SCRIPTDIR/../metastore-access/3-apply-grype-metastore-access-to-build-cluster.sh"

run_script "$SCRIPTDIR/../tap-gui/tap-gui-viewer-service-account-rbac.sh"


## create overlay that used in tap-values.yml
kubectl apply -f $SCRIPTDIR/../setup-developer-namespace/namespace-provisioner-overlay.yml -n tap-install

