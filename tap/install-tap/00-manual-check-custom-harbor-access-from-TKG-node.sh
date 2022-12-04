#!/bin/bash
SCRIPTDIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
source $SCRIPTDIR/common-scripts/common.sh
load_env_file $SCRIPTDIR/tap-env

echo "Checking access to TKG_CUSTOM_IMAGE_REPOSITORY: '$IMGPKG_REGISTRY_HOSTNAME' from TKG "
echo "  by deploying a sample deployment from the image registry."
echo ""
echo "docker pull hello-world:latest"
echo "docker tag hello-world:latest $IMGPKG_REGISTRY_HOSTNAME/library/hello-world:latest"
echo "docker push $IMGPKG_REGISTRY_HOSTNAME/library/hello-world:latest"
echo "kubectl run hello-world --image=$IMGPKG_REGISTRY_HOSTNAME/library/hello-world:latest"
echo "kubectl describe pod hello-world"
echo "kubectl logs hello-world"
echo ""
echo "then, following logs should be shown:"
echo "> Hello from Docker!"
echo "> This message shows that your installation appears to be working correctly."