kubectl patch configmap config-domain -n knative-serving --type merge --patch '{"data":{"apps.tap.lab.pcfdemo.net":""}}'
