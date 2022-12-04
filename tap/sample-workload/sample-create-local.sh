tanzu apps workload delete tanzu-java-web-app --yes -n demo-app
tanzu apps workload apply --file ./tanzu-java-web-app/config/workload.yaml \
	--namespace demo-app \
	--source-image harbor.h2o-2-2257.h2o.vmware.com/tap/tanzu-java-web-app-source-image \
	--debug --yes --local-path ./tanzu-java-web-app

