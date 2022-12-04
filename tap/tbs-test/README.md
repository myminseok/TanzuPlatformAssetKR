tbs , kpack tutorial
https://docs.vmware.com/en/VMware-Tanzu-Application-Platform/1.3/tap/GUID-tanzu-build-service-tbs-image-signing.html
https://github.com/pivotal/kpack/blob/main/docs/tutorial.md

## install kpack k8s
```
kubectl apply -f https://github.com/pivotal/kpack/releases/download/v0.8.0/release-0.8.0.yaml
```
## kpack cli
https://github.com/vmware-tanzu/kpack-cli/releases


## reuse resources from TAP
```
k get clusterstore
NAME      READY
default   True

k get clusterstack
NAME         READY
base         True
base-jammy   True
default      True
full         True
full-jammy   True
tiny         True
tiny-jammy   True
```

## testing
```
k create ns tbs-test
kubectl apply -f builder.yaml
kubectl apply -f image.yaml
```
```
k get image.kpack.io -n tbs-test
NAME             LATESTIMAGE                                                                                                                     READY
tutorial-image   harbor.h2o-2-2257.h2o.vmware.com/tap/minseok-tbs-test@sha256:c9bbc025ea82249a528f4a8eb99397b6bec8c0a7592bcc2aa2e8f576878c1171   True
```
```
docker run -p 8080:9090 harbor.h2o-2-2257.h2o.vmware.com/tap/minseok-tbs-test@sha256:c9bbc025ea82249a528f4a8eb99397b6bec8c0a7592bcc2aa2e8f576878c1171
```
