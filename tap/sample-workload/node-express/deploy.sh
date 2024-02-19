
tanzu apps workload delete node-express -n my-space --yes

tanzu apps workload apply -f config/workload.yaml -n my-space --yes

watch tanzu apps workload get node-express --namespace my-space 

## kubectl get cm -n my-space node-express-deliverable -o jsonpath='{.data.deliverable}' > ./deliverable.yml
