
#tanzu apps workload delete node-http -n my-space --yes

tanzu apps workload apply -f config/workload.yaml -n my-space --yes

watch tanzu apps workload get node-http --namespace my-space 

## kubectl get cm -n my-space node-http-deliverable -o jsonpath='{.data.deliverable}' > ./deliverable.yml
