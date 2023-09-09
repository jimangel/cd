# run locally

helm template workloads/kube-prometheus-stack/config/helm-local-chart

# grafana login

u: admin
p: prom-operator (set by: grafana.adminPassword https://github.com/sathieu/helm-charts-prometheus-community/blob/main/charts/kube-prometheus-stack/values.yaml#L608)