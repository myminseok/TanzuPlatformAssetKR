#!/bin/bash
SCRIPTDIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )


echo "Checking if secret 'cnrs-ca' -n tanzu-system-ingress is created ..."
echo "  kubectl get secret -n tanzu-system-ingress cnrs-ca -o yaml -ojsonpath='{.data.ca\.crt}' | base64 -d"
## verify
DATA=$(kubectl get secret -n tanzu-system-ingress cnrs-ca -o yaml -ojsonpath='{.data.ca\.crt}' | base64 -d)
if [[ "x$DATA" == "x" ]]; then
  echo ""
  echo "  WARNING:  secret 'cnrs-ca' -n tanzu-system-ingress is NOT created "
  echo "    kubectl get secret -n tanzu-system-ingress cnrs-ca -o yaml -ojsonpath='{.data.ca\.crt}' | base64 -d"
  echo ""
else
  echo "  OK:  secret 'cnrs-ca' -n tanzu-system-ingress is created "
fi

echo "  ======================================="
## kubectl delete cm config-network -n knative-serving

echo "Checking cnrs updates to 'config-network' -n knative-serving "
echo "  if not updated, then"
echo "  1. reconcine cnrs:"
echo "    $SCRIPTDIR/../29-reconcile-component.sh cnrs"
echo "  2. manually delete configmap:"
echo "    kubectl delete cm config-network -n knative-serving"
echo ""
echo "  kubectl get cm config-network -n knative-serving -o yaml | grep https "
## verify
DATA=$(kubectl get cm config-network -n knative-serving -o yaml | grep 'default-external-scheme: https')
if [[ "x$DATA" == "x" ]]; then
  echo ""
  echo "  WARNING: Not applied the cnrs updates to 'config-network' -n knative-serving"
  echo "    kubectl get cm config-network -n knative-serving -o yaml | grep 'default-external-scheme: https'"
  echo ""
else
  echo "  OK:  applied the cnrs updates to 'config-network' -n knative-serving"
fi



