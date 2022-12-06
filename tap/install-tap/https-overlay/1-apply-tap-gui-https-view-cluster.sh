#!/bin/bash
SCRIPTDIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )

## only for view cluster, full cluster

kubectl apply -f $SCRIPTDIR/tap-gui-certificate.yaml -n tap-gui
echo "ATTENTION: wait few minutes for certificate 'tap-gui-cert' created"
echo "    kubectl get secret -n tap-gui tap-gui-cert"
echo "    kubectl get app -A"

sleep 2
## verify
echo "Verifying ... certificate 'tap-gui-cert' "
echo "kubectl get secret -n tap-gui tap-gui-cert -o yaml -ojsonpath='{.data.ca\.crt}'"
TAP_GUI_CERT=$(kubectl get secret -n tap-gui tap-gui-cert -o yaml -ojsonpath='{.data.ca\.crt}' | base64 -d)
if [[ "x$TAP_GUI_CERT" == "x" ]]; then
  echo ""
  echo "ATTENTION: NOT FOUND certificate 'tap-gui-cert' "
  echo "  check if TAP is installed successfully and wait few minutes ... and re-run "
  echo "    kubectl get secret -n tap-gui tap-gui-cert"
  echo "    kubectl get app -A"
  exit 1
fi
echo "$TAP_GUI_CERT" > /tmp/tap-gui-cert.txt
echo "certificate 'tap-gui-cert' is saved to /tmp/tap-gui-cert.txt "


