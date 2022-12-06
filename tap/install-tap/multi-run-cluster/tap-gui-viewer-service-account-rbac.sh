## https://docs.vmware.com/en/VMware-Tanzu-Application-Platform/1.3/tap/GUID-tap-gui-cluster-view-setup.html

#!/bin/bash
SCRIPTDIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
source $SCRIPTDIR/../tap-env

sh $SCRIPTDIR/../common-scripts/tap-gui-viewer-service-account-rbac.sh