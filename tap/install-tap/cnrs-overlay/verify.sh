echo "kubectl get secrets cnrs-cm-overlay -n tap-install "
kubectl get secrets cnrs-cm-overlay -n tap-install -o jsonpath='{.data.overlay-gc-cm\.yaml}' | base64 -d

echo "kubectl get configmap config-gc -n knative-serving"
echo "min-non-active-revisions: $(kubectl get configmap config-gc --namespace knative-serving --output jsonpath='{.data.min-non-active-revisions}')"
echo "max-non-active-revisions: $(kubectl get configmap config-gc --namespace knative-serving --output jsonpath='{.data.max-non-active-revisions}')"
echo "retain-since-create-time: $(kubectl get configmap config-gc --namespace knative-serving --output jsonpath='{.data.retain-since-create-time}')"
echo "retain-since-last-active-time: $(kubectl get configmap config-gc --namespace knative-serving --output jsonpath='{.data.retain-since-last-active-time}')"
