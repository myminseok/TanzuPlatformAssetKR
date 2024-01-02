
tanzu package installed update prometheus \
--package prometheus.tanzu.vmware.com \
--version 2.37.0+vmware.3-tkg.1 \
--values-file prometheus-data-values.yaml \
--namespace tkg-install