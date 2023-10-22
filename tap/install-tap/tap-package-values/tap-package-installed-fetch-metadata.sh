#!/bin/bash -e
PACKAGE=$1
version=$(kubectl get app $PACKAGE -n tap-install -o yaml | grep "packaging.carvel.dev/package-version" | awk '{print $2}')
package_domain=$(kubectl get app $PACKAGE -n tap-install -o yaml | grep "packaging.carvel.dev/package-ref-name" | awk '{print $2}')
pkg_dir_name=${PACKAGE}_${version}
final_pkg_dir="./output/${pkg_dir_name}"
tmp_pkg_dir="/tmp/${pkg_dir_name}"
mkdir -p ./output
mkdir -p $tmp_pkg_dir


function fetch-values-schema(){
  if [ -f  ${final_pkg_dir}/${pkg_dir_name}_values-schema.txt ]; then
    exit 0;
  fi
  echo "Retriveing... values-schema for ${PACKAGE}_${version}"
  mkdir -p $tmp_pkg_dir
  tanzu package available get $package_domain/${version} -n tap-install --values-schema > $tmp_pkg_dir/${pkg_dir_name}_values-schema.txt
  mv $tmp_pkg_dir/${pkg_dir_name}_values-schema.txt ${final_pkg_dir}/${pkg_dir_name}_values-schema.txt
}

set -e
if [ -d ./$final_pkg_dir ]; then
  echo "Skipping... ${PACKAGE}_${version} folder exists"
  fetch-values-schema 
  exit 0;
fi

echo "Retriveing... ${PACKAGE}_${version}"

imgurl=$(kubectl get app $PACKAGE -n tap-install -ojson | jq -r '.spec.fetch[0].imgpkgBundle.image')
img_domain=$(dirname $imgurl | cut -d '/' -f1)

if [ ! -f ./${img_domain}.crt ]; then
  openssl s_client -connect $img_domain:443 -showcerts < /dev/null 2> /dev/null | openssl x509 > ${img_domain}.crt
fi
#set -x
imgpkg pull -b $imgurl  -o $tmp_pkg_dir --registry-ca-cert-path ./${img_domain}.crt
#set +x

mv $tmp_pkg_dir ./output

fetch-values-schema 


