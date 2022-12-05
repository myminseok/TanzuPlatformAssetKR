#!/bin/bash
SCRIPTDIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )

## only for view cluster, full cluster

kubectl apply -f $SCRIPTDIR/tap-gui-certificate.yaml -n tap-gui


TAP_GUI_CERT=$(kubectl get secret -n tap-gui tap-gui-cert -o yaml -ojsonpath='{.data.ca\.crt}' | base64 -d)
## verify
if [[ "x$TAP_GUI_CERT" == "x" ]]; then
  echo ""
  echo "ERROR: certificate 'tap-gui-cert' is invalid. "
  echo "   kubectl get secret -n tap-gui tap-gui-cert"
  echo ""
  exit 1
fi
echo "$TAP_GUI_CERT" > /tmp/tap-gui-cert.txt
echo "certificate 'tap-gui-cert' is saved to /tmp/tap-gui-cert.txt "
