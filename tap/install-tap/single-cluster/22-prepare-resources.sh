#!/bin/bash
export SCRIPTDIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
source $SCRIPTDIR/../common-scripts/prepare-resources.sh $@

chmod +x $SCRIPTDIR/*.sh
chmod +x $SCRIPTDIR/../https-overlay/*.sh

set -x
$SCRIPTDIR/../https-overlay/1-apply-tap-gui-https-view-cluster.sh
echo ""
$SCRIPTDIR/../https-overlay/1-apply-cnrs-default-tls-run-cluster.sh
echo ""
$SCRIPTDIR/../multi-build-cluster/scanning-ca-overlay.sh
set +x

echo ""
echo "==============================================================="
echo "Manully update tap-values file on FULL cluster"
echo "---------------------------------------------------------------"
echo "  file: $TAP_ENV_DIR/tap-values-full-2nd-overlay-TEMPLATE.yml"
echo "    api_auto_registration.ca_cert_data"
echo ""
echo "  - Fetch CA for TAP GUI domain from FULL cluster"
echo "    kubectl get secret -n tap-gui tap-gui-cert -o yaml -ojsonpath='{.data.ca\.crt}' | base64 -d"
echo "    or cat /tmp/tap-gui-cert.txt  (saved to  by $SCRIPTDIR/../https-overlay/1-apply-tap-gui-https-view-cluster.sh)"
echo ""
echo "  - WARNING: Note that app workload domain CA Will be created after TAP update(package_overlays)"
echo "    kubectl get secret -n tanzu-system-ingress cnrs-ca -o yaml -ojsonpath='{.data.ca\.crt}' | base64 -d"
