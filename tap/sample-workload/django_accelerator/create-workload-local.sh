

tanzu apps workload delete django-app --yes
tanzu apps workload apply --file ./workload.yaml \
	--source-image us-central1-docker.pkg.dev/tap-sandbox-dev/tap-balanced-fowl/django-app \
	--debug --yes --local-path .


## tanzu apps workload update -f ./workload.yaml --source-image us-central1-docker.pkg.dev/tap-sandbox-dev/tap-balanced-fowl/django-app


