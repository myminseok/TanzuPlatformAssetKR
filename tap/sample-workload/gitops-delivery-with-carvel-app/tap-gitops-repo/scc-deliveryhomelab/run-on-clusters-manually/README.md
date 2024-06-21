# Use Gitops delivery with a Carvel app (beta)
https://docs.vmware.com/en/VMware-Tanzu-Application-Platform/1.8/tap/scc-delivery-with-carvel-app.html


## on run-cluster
k create ns run-space
kubectl label namespaces run-space apps.tanzu.vmware.com/tap-ns=""
k apply -f rbac-run-cluster-namespace.yml -n run-space
k create rolebinding app-package-and-pkgi-install-role  --serviceaccount=run-space:default --role=app-package-and-pkgi-install-role -n run-space

## on build-cluster
k delete -f /Users/kminseok/_dev/tanzu-main/tanzu-main-repo/env-homelab/tap/gitops-ssh-carvel-package.yml -n my-space 
k apply -f /Users/kminseok/_dev/tanzu-main/tanzu-main-repo/env-homelab/tap/gitops-ssh-carvel-package.yml -n my-space 

kubectl create secret generic homelab-run-cluster-kubeconfig \
   -n my-space \
   --from-file=value.yaml=/Users/kminseok/.kube/config


kubectl delete -f carvel-app-on-buildcluster.yml -n my-space
kubectl apply -f carvel-app-on-buildcluster.yml -n my-space

k get app -n my-space   carvel-package-tanzu-java-web-app -o yaml

## on run-cluster
package will be installed automatically.
```
k get packages -n run-space

NAME                                                               PACKAGEMETADATA NAME              VERSION                            AGE
tanzu-java-web-app.my-space.tap.20240621075123.0.0+build.763ba0d   tanzu-java-web-app.my-space.tap   20240621075123.0.0+build.763ba0d   10m5s
tanzu-java-web-app.my-space.tap.20240621081049.0.0+build.763ba0d   tanzu-java-web-app.my-space.tap   20240621081049.0.0+build.763ba0d   10m5s
```

```
k get packageinstall -n run-space tanzu-java-web-app

NAME                 PACKAGE NAME                      PACKAGE VERSION                    DESCRIPTION           AGE
tanzu-java-web-app   tanzu-java-web-app.my-space.tap   20240621081049.0.0+build.763ba0d   Reconcile succeeded   10m
```

```
k get all -n run-space            
NAME                                      READY   STATUS    RESTARTS   AGE
pod/tanzu-java-web-app-8587f8fbb5-c2sfv   1/1     Running   0          10m
pod/tanzu-java-web-app-8587f8fbb5-csxw9   1/1     Running   0          10m

NAME                         TYPE        CLUSTER-IP       EXTERNAL-IP   PORT(S)    AGE
service/tanzu-java-web-app   ClusterIP   100.71.220.242   <none>        8080/TCP   10m

NAME                                 READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/tanzu-java-web-app   2/2     2            2           10m

NAME                                            DESIRED   CURRENT   READY   AGE
replicaset.apps/tanzu-java-web-app-8587f8fbb5   2         2         2       10m
```

