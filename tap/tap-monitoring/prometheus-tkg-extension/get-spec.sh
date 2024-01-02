# k get packages -A | grep prometheus
image_url=$(kubectl -n tanzu-package-repo-global get packages   prometheus.tanzu.vmware.com.2.37.0+vmware.3-tkg.1 -o jsonpath='{.spec.template.spec.fetch[0].imgpkgBundle.image}')
imgpkg pull -b $image_url -o ./spec