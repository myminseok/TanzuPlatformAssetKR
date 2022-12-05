#!/bin/bash
SCRIPTDIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )

## only for run cluster, full cluster

kubectl create secret generic cnrs-default-tls -n tap-install \
  -o yaml \
  --dry-run=client \
  --from-file=$SCRIPTDIR/cnrs-default-tls.yml \
  | kubectl apply -f-

kubectl get secret  cnrs-default-tls -n tap-install


echo "==============================================================="
echo "Manully update tap-values 'api_auto_registration.ca_cert_data' file on RUN/FULL cluster"
echo "---------------------------------------------------------------"
echo "  file: $TAP_ENV_DIR/tap-values-{PROFILE}-2nd-overlay-TEMPLATE.yml"
echo "    api_auto_registration.ca_cert_data"
echo ""
echo "  - Fetch CA for app workload domain from RUN cluster"
echo "    !!! this app workload domain CA(tanzu-system-ingress cnrs-ca) Will be created after TAP update(package_overlays)"
echo "    kubectl get secret -n tanzu-system-ingress cnrs-ca -o yaml -ojsonpath='{.data.ca\.crt}' | base64 -d"


