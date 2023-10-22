#TODO: also allow seeding / interactive secrets

# https://dashboard.ngrok.com/api
# created static domain
export NGROK_API_KEY="KET FROM GENERATION"
export NGROK_AUTHTOKEN="AUTH TOKEN FROM SETIP PAGE"
# https://dashboard.ngrok.com/get-started/setup/kubernetes

```
cat <<EOF | kubectl apply -f -
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: argo-ui-ingress
  namespace: argocd
spec:
  ingressClassName: ngrok
  rules:
    - host: cool-buzzard-manually.ngrok-free.app
      http:
        paths:
          - path: /api/webhook
            pathType: Exact
            backend:
              service:
                name: argocd-server
                port:
                  number: 80
EOF

# "Unknown webhook event" = good
# password for DDOS
```