helm upgrade --install tap-monitoring prometheus-community/kube-prometheus-stack -n monitoring --create-namespace -f helm-values-modified.yaml