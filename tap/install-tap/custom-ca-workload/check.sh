
#!/bin/bash
export SCRIPTDIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
source $SCRIPTDIR/../common-scripts/common.sh
load_env_file $SCRIPTDIR/../tap-env

echo "---------------------------------------------------------------------------------------"
echo "Checking cnrs updates (persistent volume features) to 'config-features' -n knative-serving "
## verify
set +e
DATA=$(kubectl get cm config-features -n knative-serving -o yaml | grep 'persistent-volume' | grep 'enabled')
set -e
if [  "x$DATA" == "x" ]; then
  echo ""
  echo "  [WARNING]  Not Applied the cnrs updates to 'config-features' -n knative-serving"
  echo "    kubectl get cm config-features -n knative-serving -o yaml | grep 'persistent-volume' | grep 'enabled'"
  echo ""
  echo "  if not updated, then"
  echo "  1. manually delete configmap:"
  echo "    kubectl delete cm config-features -n knative-serving "
  echo "  2. reconcine cnrs:"
  echo "   ../29-reconcile-component.sh cnrs"
else
  echo "  [OK] applied the cnrs updates to 'config-features' -n knative-serving"
  echo "    kubectl get cm config-features -n knative-serving -o yaml | grep 'persistent-volume' | grep 'enabled'"
fi


