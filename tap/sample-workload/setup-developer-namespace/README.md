## adding docker registry credentials to NS.

tanzu secret registry add docker-registry-credentials \
--server https://index.docker.io/v1/  \
--username xxx \
--password xxx \
--namespace tap-install \
--export-to-all-namespaces --yes

kubectl get secretexports -A | grep docker-registry-credentials

kubectl apply -f secretimport.yml -n TARGET_NS