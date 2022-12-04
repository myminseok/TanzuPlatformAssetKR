kubectl get authservers.sso.apps.tanzu.vmware.com my-authserver-example -o jsonpath='{.status.issuerURI}'

kubectl get po,svc,ing -n default
