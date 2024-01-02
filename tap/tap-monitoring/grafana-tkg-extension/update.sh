cp grafana-data-values.yaml /tmp/grafana-data-values-commentout.yaml 
yq -i eval '... comments=""' /tmp/grafana-data-values-commentout.yaml 


tanzu package installed update grafana \
--version 7.5.17+vmware.2-tkg.1 \
--values-file /tmp/grafana-data-values-commentout.yaml  \
--namespace monitoring