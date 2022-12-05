#!/bin/bash
SCRIPTDIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )

## only for view cluster, full cluster

kubectl apply -f $SCRIPTDIR/tap-gui-certificate.yaml -n tap-gui
echo "kubectl get secret -n tap-gui tap-gui-cert -o yaml -ojsonpath='{.data.ca\.crt}'"
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


echo "==============================================================="
echo "Manully update tap-values 'api_auto_registration.ca_cert_data' file on RUN/FULL cluster"
echo "---------------------------------------------------------------"
echo "  file: $TAP_ENV_DIR/tap-values-{profile}-2nd-overlay-TEMPLATE.yml"
echo "    api_auto_registration.ca_cert_data"
echo ""
echo "  - Fetch CA for TAP GUI domain from VIEW cluster"
echo "    kubectl get secret -n tap-gui tap-gui-cert -o yaml -ojsonpath='{.data.ca\.crt}' | base64 -d"
echo "    or cat /tmp/tap-gui-cert.txt  (saved to  by $SCRIPTDIR/../https-overlay/1-apply-tap-gui-https-view-cluster.sh)"

