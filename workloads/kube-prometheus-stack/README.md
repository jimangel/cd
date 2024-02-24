# run locally

helm template workloads/kube-prometheus-stack/config/addon-chart-gateway

# grafana login

u: admin
p: prom-operator (set by: grafana.adminPassword https://github.com/prometheus-community/helm-charts/blob/main/charts/kube-prometheus-stack/values.yaml#L963)

# UI

HTTPRoutes are in the config sub helm for add on URLs (fixing to envoy)