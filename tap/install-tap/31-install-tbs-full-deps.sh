## https://docs.vmware.com/en/VMware-Tanzu-Application-Platform/1.3/tap/GUID-tbs-offline-install-deps.html
#!/bin/bash
SCRIPTDIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
source $SCRIPTDIR/common-scripts/common.sh
load_env_file $SCRIPTDIR/tap-env

print_current_k8s

parse_args "$@"
if [ "$YES" != "y" ]; then
 confirm_target_k8s
fi

# tanzu package installed delete full-tbs-deps   -n tap-install -y

# tanzu package available get  full-deps.buildservice.tanzu.vmware.com -n tap-install

echo "kp_default_repository: $BUILDSERVICE_REGISTRY_HOSTNAME/$BUILDSERVICE_REPO" > /tmp/full-tbs-deps-values.yml
cat /tmp/full-tbs-deps-values.yml
tanzu package install full-tbs-deps -p full-deps.buildservice.tanzu.vmware.com -v "> 0.0.0" -n tap-install --values-file /tmp/full-tbs-deps-values.yml