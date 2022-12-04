tanzu apps workload get tanzu-java-web-app -o yaml
#kubectl get gitrepository.source.toolkit.fluxcd.io/tanzu-java-web-app -o yaml --show-managed-fields=false
#kubectl get image.kpack.io/tanzu-java-web-app -o yaml
#kubectl get podintent.conventions.apps.tanzu.vmware.com/tanzu-java-web-app -o yaml

watch kubectl get clustersupplychains,workload,gitrepository,scantemplate,pipelinerun,images.kpack,podintent,app,services.serving -A

#k logs tanzu-java-web-app-8jvsk-test-pod -c step-test -f
