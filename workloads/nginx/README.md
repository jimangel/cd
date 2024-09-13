

Supported versions: https://github.com/kubernetes/ingress-nginx?tab=readme-ov-file#supported-versions-table


kubectl exec -it ds/nginx-local-ingress-nginx-controller -n ingress-nginx -- cat /etc/nginx/nginx.conf


kubectl kustomize workloads/nginx/config/base