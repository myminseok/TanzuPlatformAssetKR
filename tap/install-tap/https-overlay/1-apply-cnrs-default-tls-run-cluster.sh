#!/bin/bash
export SCRIPTDIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
source $SCRIPTDIR/../common-scripts/common.sh
load_env_file $SCRIPTDIR/../tap-env

echo "This script should run on RUN cluster"

kubectl create secret generic cnrs-default-tls -n tap-install \
  -o yaml \
  --dry-run=client \
  --from-file=$SCRIPTDIR/cnrs-default-tls.yml \
  | kubectl apply -f-

kubectl get secret  cnrs-default-tls -n tap-install

echo "---------------------------------------------------------------------------------------"
echo "Manully update tap-values 'api_auto_registration.ca_cert_data' file on RUN/FULL cluster"
echo "---------------------------------------------------------------------------------------"
echo "  file: $TAP_ENV_DIR/tap-values-{PROFILE}-2nd-overlay-TEMPLATE.yml"
echo "    api_auto_registration.ca_cert_data"
echo ""
echo "  - ATTENTION: CA for app workload domain from RUN cluster will be created AFTER TAP update completes with 'package_overlays' "
echo "    kubectl get secret -n tanzu-system-ingress cnrs-ca -o yaml -ojsonpath='{.data.ca\.crt}' | base64 -d"


