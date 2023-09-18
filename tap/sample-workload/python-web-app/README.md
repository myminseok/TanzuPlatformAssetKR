# python-web-app
## Tanzu Python Flask Web App 
## Tanzu Application Platform

pip download -r requirements.txt -d ./vendor/ --platform x86_64 --no-deps

tanzu apps workload apply -f config/workload.yaml -n my-space --local-path . --source-image infra-harbor.lab.pcfdemo.net/regops/python-web-app --registry-ca-cert /data/tapconfig/tkg-custom-ca.crt -y

