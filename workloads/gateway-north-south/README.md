The central point of traffic ingress / egress

## Test

```
kustomize build workloads/gateway-north-south/config/overlays/baremetal --enable-helm

or

kubectl kustomize workloads/gateway-north-south/config/overlays/baremetal --enable-helm
```

## DELETE BELOW:

```
# from: https://istio.io/latest/docs/setup/additional-setup/getting-started/

# route
cat <<EOF | kubectl -n argocd apply -f -
apiVersion: gateway.networking.k8s.io/v1beta1
kind: HTTPRoute
metadata:
  name: argocd-http-redirect
spec:
  parentRefs:
  - name: cluster-north-south-gateway
    namespace: istio-gateway
    port: 80
  hostnames:
    - argocd.gpu-local.cloudydemo.com
  rules:
    - filters:
        - type: RequestRedirect
          requestRedirect:
            scheme: https
            statusCode: 301
EOF

cat <<EOF | kubectl -n argocd apply -f -
apiVersion: gateway.networking.k8s.io/v1beta1
kind: HTTPRoute
metadata:
  name: argocd-https-ui
spec:
  parentRefs:
  - name: cluster-north-south-gateway
    namespace: istio-gateway
    port: 443
  hostnames:
    - argocd.gpu-local.cloudydemo.com
  rules:
  -  backendRefs:
     - group: ""
       kind: Service
       name: argocd-server
       port: 80
EOF



cat <<EOF | kubectl -n argocd apply -f -
apiVersion: gateway.networking.k8s.io/v1alpha2
kind: TLSRoute
metadata:
  name: argocd-ui-passthrough
  namespace: argocd
spec:
  parentRefs:
  - name: cluster-north-south-gateway
    namespace: istio-gateway
    port: 443
  hostnames:
  - argocd.cloudydemo.com
  rules:
  -  backendRefs:
     - name: argocd-server
       port: 443
EOF


kubectl apply -f - <<EOF
apiVersion: gateway.networking.k8s.io/v1alpha2
kind: TLSRoute
metadata:
  name: nginx
spec:
  parentRefs:
  - name: cluster-north-south-gateway
    namespace: istio-gateway
    port: 443
  hostnames:
  - "nginx.example.com"
  rules:
  - backendRefs:
    - name: my-nginx
      port: 443
EOF



cat <<EOF | kubectl apply -f -
apiVersion: gateway.networking.k8s.io/v1beta1
kind: HTTPRoute
metadata:
  name: bookinfo
  namespace: default
spec:
  parentRefs:
  - name: cluster-north-south-gateway
    namespace: istio-gateway
  hostnames:
  - bookinfo.cloudydemo.com
  rules:
  - matches:
    - path:
        type: Exact
        value: /productpage
    - path:
        type: PathPrefix
        value: /static
    - path:
        type: Exact
        value: /login
    - path:
        type: Exact
        value: /logout
    - path:
        type: PathPrefix
        value: /api/v1/products
    backendRefs:
    - name: productpage
      port: 9080
EOF



```

> https://gateway-api.sigs.k8s.io/api-types/httproute/



## other

```
kubectl expose deployment testing --name testing-svc \
--type ClusterIP \
--port 80 --target-port 8080
```

Gateway with TLS passthrough ? (maybe get  a cert on the backend for that)

```
  - name: https
    protocol: TLS
    port: 443
    hostname: "argocd.cloudydemo.com"
    tls:
      mode: Passthrough
    allowedRoutes:
      namespaces:
        from: All
      kinds:
      - kind: TLSRoute
```

manually apply a gateway: 

```
helm template workloads/gateway-api-istio-ingress/config/ -f workloads/gateway-api-istio-ingress/config/values-baremetal.yaml
```

Extra

```
  - name: tls
    protocol: TLS
    port: 443
    hostname: "{{ .Values.argocdHost }}"
    tls:
      mode: Passthrough
    allowedRoutes:
      namespaces:
        from: All
      kinds:
      - kind: TLSRoute



      
  listeners:
  - name: https
    hostname: "{{ .Values.argocdHost }}"
    port: 443
    protocol: HTTPS
    tls:
      mode: Terminate
      certificateRefs:
      - name: argocd-ui-cert
    allowedRoutes:
      namespaces:
        from: All
      kinds:
      - kind: HTTPRoute



kubectl -n default expose deployment testing --name ing-svc-echo-server \
--type ClusterIP \
--port 80 --target-port 8080

cat <<EOF | kubectl apply -f -
apiVersion: gateway.networking.k8s.io/v1beta1
kind: HTTPRoute
metadata:
  name: test
  namespace: default
spec:
  parentRefs:
  - name: cluster-north-south-gateway
    namespace: istio-gateway
    port: 80
  hostnames:
    - test.gpu-local.cloudydemo.com
  rules:
  -  backendRefs:
     - name: ing-svc-echo-server
       port: 80
EOF




cat <<EOF | kubectl apply -f -
apiVersion: networking.k8s.io/v1
kind: IngressClass
metadata:
  name: istio
spec:
  controller: istio.io/ingress-controller
---
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: ingress
spec:
  ingressClassName: istio
  rules:
  - host: httpbin.gpu-local.cloudydemo.com
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: ing-svc-echo-server
            port:
              number: 80
EOF
```