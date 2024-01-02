# k get packages -A | grep grafana
image_url=$(kubectl -n tanzu-package-repo-global get packages  grafana.tanzu.vmware.com.7.5.17+vmware.2-tkg.1 -o jsonpath='{.spec.template.spec.fetch[0].imgpkgBundle.image}')
imgpkg pull -b $image_url -o ./spec