

cp grafana-data-values.yaml /tmp/grafana-data-values-commentout.yaml 
yq -i eval '... comments=""' /tmp/grafana-data-values-commentout.yaml 

kubectl create ns tkg-install

tanzu package install grafana \
--package grafana.tanzu.vmware.com \
--version 7.5.17+vmware.2-tkg.1 \
--values-file /tmp/grafana-data-values-commentout.yaml  \
--namespace tkg-install