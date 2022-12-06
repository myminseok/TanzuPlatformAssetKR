#!/bin/bash
export SCRIPTDIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
source $SCRIPTDIR/../common-scripts/common.sh
load_env_file $SCRIPTDIR/../tap-env

echo "This script should run on VIEW cluster"

## replace TAP-DOMAIN
cp $SCRIPTDIR/tap-gui-certificate.yaml.template /tmp/tap-gui-certificate.yaml
sed -i -r "s/TAP_DOMAIN/${TAP_DOMAIN}/g" /tmp/tap-gui-certificate.yaml
kubectl apply -f /tmp/tap-gui-certificate.yaml -o yaml  --dry-run=client -n tap-gui  | kubectl apply -f-

echo " Please wait for few seconds for certificate 'tap-gui-cert' is created ..."
sleep 2

## verify
echo "Verifying ... certificate 'tap-gui-cert' "
echo "kubectl get secret -n tap-gui tap-gui-cert -o yaml -ojsonpath='{.data.ca\.crt}'"
set +e
TAP_GUI_CERT=$(kubectl get secret -n tap-gui tap-gui-cert -o yaml -ojsonpath='{.data.ca\.crt}' | base64 -d)
set -e
if [ "x$TAP_GUI_CERT" == "x" ]; then
  echo ""
  echo "[ERROR] NOT FOUND certificate 'tap-gui-cert' "
  echo "  check if TAP is installed successfully and wait few minutes ... and re-run "
  echo "    kubectl get secret -n tap-gui tap-gui-cert"
  echo "    kubectl get app -A"
  exit 1
fi
echo "$TAP_GUI_CERT" > /tmp/tap-gui-cert.txt
echo "Verifying ... DNS section in certificate 'tap-gui-cert' ..."
set +e
DATA=$(openssl x509 -text -in  /tmp/tap-gui-cert.txt | grep $TAP_DOMAIN)
set -e
if [ "x$DATA" == "x" ]; then
  echo ""
  echo "[ERROR] certificate 'tap-gui-cert' doesn't include TAP_DOMAIN '$TAP_DOMAIN' in DNS section "
  echo "    kubectl get secret -n tap-gui tap-gui-cert"
  echo "    check TAP_ENV file"
  echo "    kubectl get app -A"
  exit 1
else
  echo "[OK] certificate 'tap-gui-cert' generated properly and saved to /tmp/tap-gui-cert.txt "
fi


