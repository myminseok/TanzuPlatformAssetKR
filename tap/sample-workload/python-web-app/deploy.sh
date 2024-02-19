
tanzu apps workload delete python-web-app -n my-space --yes

tanzu apps workload apply -f config/workload.yaml -n my-space --yes


watch tanzu apps workload get python-web-app --namespace my-space 

## kubectl get cm -n my-space python-web-app-deliverable -o jsonpath='{.data.deliverable}' > ./deliverable.yml
