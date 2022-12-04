## https://docs.vmware.com/en/VMware-Tanzu-Application-Platform/1.3/tap/GUID-tbs-offline-install-deps.html
#!/bin/bash
SCRIPTDIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
source $SCRIPTDIR/common-scripts/common.sh
load_env_file $SCRIPTDIR/tap-env

if [ "$YES" != "y" ]; then
 confirm_target_k8s
fi


#VERSION=1.7.2

VERSION=$(tanzu package available list buildservice.tanzu.vmware.com --namespace tap-install -o json | jq -r '.[] | select(.name=="buildservice.tanzu.vmware.com") | .version')
if [ "$VERSION" == "" ]; then
  echo "ERROR no buildservice.tanzu.vmware.com found"
  exit 1
fi
echo $VERSION

# tanzu package available get -n tap-install full-tbs-deps.tanzu.vmware.com

tanzu package install full-tbs-deps -p full-tbs-deps.tanzu.vmware.com -v $VERSION -n tap-install

# tanzu package installed delete full-tbs-deps  -n tap-install -y