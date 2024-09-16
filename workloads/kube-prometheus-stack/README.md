# run locally

helm template workloads/kube-prometheus-stack/config/addon-chart-gateway

# grafana login

u: admin
p: prom-operator (set by: grafana.adminPassword https://github.com/prometheus-community/helm-charts/blob/main/charts/kube-prometheus-stack/values.yaml#L963)

# UI

HTTPRoutes are in the config sub helm for add on URLs (fixing to envoy)

# check updates

look for version, update environment values.

https://github.com/prometheus-community/helm-charts

IMPORTANT: upgrade CRDs first:

https://github.com/prometheus-community/helm-charts/tree/main/charts/kube-prometheus-stack/#from-61x-to-62x

```
# adding `--force-conflicts` until I break out CRDs to seperate installer portion of management.
kubectl apply --force-conflicts --server-side -f https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/v0.76.0/example/prometheus-operator-crd/monitoring.coreos.com_alertmanagerconfigs.yaml
kubectl apply --force-conflicts --server-side -f https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/v0.76.0/example/prometheus-operator-crd/monitoring.coreos.com_alertmanagers.yaml
kubectl apply --force-conflicts --server-side -f https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/v0.76.0/example/prometheus-operator-crd/monitoring.coreos.com_podmonitors.yaml
kubectl apply --force-conflicts --server-side -f https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/v0.76.0/example/prometheus-operator-crd/monitoring.coreos.com_probes.yaml
kubectl apply --force-conflicts --server-side -f https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/v0.76.0/example/prometheus-operator-crd/monitoring.coreos.com_prometheusagents.yaml
kubectl apply --force-conflicts --server-side -f https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/v0.76.0/example/prometheus-operator-crd/monitoring.coreos.com_prometheuses.yaml
kubectl apply --force-conflicts --server-side -f https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/v0.76.0/example/prometheus-operator-crd/monitoring.coreos.com_prometheusrules.yaml
kubectl apply --force-conflicts --server-side -f https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/v0.76.0/example/prometheus-operator-crd/monitoring.coreos.com_scrapeconfigs.yaml
kubectl apply --force-conflicts --server-side -f https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/v0.76.0/example/prometheus-operator-crd/monitoring.coreos.com_servicemonitors.yaml
kubectl apply --force-conflicts --server-side -f https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/v0.76.0/example/prometheus-operator-crd/monitoring.coreos.com_thanosrulers.yaml
```