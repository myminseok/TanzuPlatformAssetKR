#!/bin/bash
SCRIPTDIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )

## kubectl delete cm config-network -n knative-serving

$SCRIPTDIR/../35-reconcile-component.sh cnrs
echo "checking cnrs updates:"
echo "  kubectl get cm config-network -n knative-serving -o yaml | grep https "
kubectl get cm config-network -n knative-serving -o yaml | grep "https"

echo ""
echo "if not updated, then manually delete configmap:"
echo "  kubectl delete cm config-network -n knative-serving"