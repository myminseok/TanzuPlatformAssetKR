#!/bin/bash
export SCRIPTDIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
source $SCRIPTDIR/../common-scripts/prepare-resources.sh -y

chmod +x $SCRIPTDIR/*.sh
chmod +x $SCRIPTDIR/../https-overlay/*.sh

set -x
$SCRIPTDIR/../https-overlay/2-verify-cnrs-run-cluster.sh
set +x

echo ""
echo "==============================================================="
echo "Manully update tap-values file on VIEW cluster"
echo "---------------------------------------------------------------"
echo "  file: $TAP_ENV_DIR/tap-values-view-2nd-overlay-TEMPLATE.yml"
echo "    api_auto_registration.ca_cert_data"
echo ""
echo "  - Fetch CA for app workload domain from FULL cluster"
echo "    kubectl get secret -n tanzu-system-ingress cnrs-ca -o yaml -ojsonpath='{.data.ca\.crt}' | base64 -d"
echo ""
kubectl get secret -n tanzu-system-ingress cnrs-ca -o yaml -ojsonpath='{.data.ca\.crt}' | base64 -d