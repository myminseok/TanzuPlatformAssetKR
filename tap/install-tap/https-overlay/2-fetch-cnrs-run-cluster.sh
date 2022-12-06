#!/bin/bash
export SCRIPTDIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
source $SCRIPTDIR/../common-scripts/common.sh
load_env_file $SCRIPTDIR/../tap-env



echo "---------------------------------------------------------------------------------------"
echo "Checking cnrs updates(https) to 'config-network' -n knative-serving "
## verify
set +e
DATA=$(kubectl get cm config-network -n knative-serving -o yaml | grep 'default-external-scheme: https')
set -e
if [  "x$DATA" == "x" ]; then
  echo ""
  echo "  WARNING: Not Applied the cnrs updates to 'config-network' -n knative-serving"
  echo "    kubectl get cm config-network -n knative-serving -o yaml | grep 'default-external-scheme: https'"
  echo ""
  echo "  if not updated, then"
  echo "  1. manually delete configmap:"
  echo "    kubectl delete cm config-network -n knative-serving"
  echo "  2. reconcine cnrs:"
  echo "    $SCRIPTDIR/../29-reconcile-component.sh cnrs"
else
  echo "  OK:  applied the cnrs updates to 'config-network' -n knative-serving"
fi

echo "---------------------------------------------------------------------------------------"
echo "Checking if secret 'cnrs-ca' -n tanzu-system-ingress is created ..."
echo "  kubectl get secret -n tanzu-system-ingress cnrs-ca -o yaml -ojsonpath='{.data.ca\.crt}' | base64 -d"
## verify
set +e
DATA=$(kubectl get secret -n tanzu-system-ingress cnrs-ca -o yaml -ojsonpath='{.data.ca\.crt}' | base64 -d)
set -e
if [ "x$DATA" == "x" ]; then
  echo ""
  echo "  WARNING:  secret 'cnrs-ca' -n tanzu-system-ingress is NOT created "
  echo "    kubectl get secret -n tanzu-system-ingress cnrs-ca -o yaml -ojsonpath='{.data.ca\.crt}' | base64 -d"
  echo ""
else
  echo "  OK:  secret 'cnrs-ca' -n tanzu-system-ingress is created "
  echo ""
fi

echo "---------------------------------------------------------------------------------------"
echo "Manully update tap-values 'api_auto_registration.ca_cert_data' file on RUN/FULL cluster"
echo "---------------------------------------------------------------------------------------"
echo "  file: $TAP_ENV_DIR/tap-values-{PROFILE}-2nd-overlay-TEMPLATE.yml"
echo "    api_auto_registration.ca_cert_data"
echo ""
echo "  - Fetch CA for app workload domain from RUN cluster"
echo "    kubectl get secret -n tanzu-system-ingress cnrs-ca -o yaml -ojsonpath='{.data.ca\.crt}' | base64 -d"
kubectl get secret -n tanzu-system-ingress cnrs-ca -o yaml -ojsonpath='{.data.ca\.crt}' | base64 -d