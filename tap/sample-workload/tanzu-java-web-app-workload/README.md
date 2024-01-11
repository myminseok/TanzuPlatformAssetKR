# kapp inspect
```
kapp inspect -n my-space                     -a tanzu-java-web-app.app --tree
```

## build 
```
kubectl config use-context build-admin@build 
kubectl get configmaps/tanzu-java-web-app-deliverable -n my-space -o jsonpath='{.data.deliverable}' > deliverable-tanzu-java-web-app.yml
```


```
kubectl config use-context run-admin@run  
kubectl create ns my-space      
kubectl label namespaces my-space apps.tanzu.vmware.com/tap-ns="" 

kubectl apply -f deliverable-tanzu-java-web-app.yml -n my-space 

```