#!/bin/bash
export SCRIPTDIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
source $SCRIPTDIR/../common-scripts/prepare-resources.sh $@
load_env_file $SCRIPTDIR/../tap-env

chmod +x $SCRIPTDIR/*.sh
chmod +x $SCRIPTDIR/../https-overlay/*.sh
chmod +x $SCRIPTDIR/../multi-build-cluster/*.sh

$SCRIPTDIR/../https-overlay/1-apply-cnrs-default-tls-run-cluster.sh
$SCRIPTDIR/../multi-build-cluster/tap-gui-viewer-service-account-rbac.sh

echo ""
echo "==============================================================="
echo "Manully update tap-values file on RUN cluster"
echo "---------------------------------------------------------------"
echo "  file: $TAP_ENV_DIR/tap-values-run-2nd-overlay-TEMPLATE.yml"
echo "    api_auto_registration.ca_cert_data"
echo "  - CA for TAP GUI domain from VIEW cluster"
echo "    kubectl get secret -n tap-gui tap-gui-cert -o yaml -ojsonpath='{.data.ca\.crt}' | base64 -d"
echo "  - CA for app workload domain from RUN cluster"
echo "    kubectl get secret -n tanzu-system-ingress cnrs-ca -o yaml -ojsonpath='{.data.ca\.crt}' | base64 -d"