helm template eg oci://docker.io/envoyproxy/gateway-helm --version v0.0.0-latest -n envoy-gateway-system --create-namespace


https://github.com/envoyproxy/gateway/tree/main/charts/gateway-helm


envoy gateway api:



https://gateway.envoyproxy.io/v0.6.0/user/quickstart/

I then need to install all the CRDs (?)

```
# need to move to namespace / templatize

cat <<EOF | kubectl apply -f -
apiVersion: gateway.networking.k8s.io/v1
kind: GatewayClass
metadata:
  name: eg
spec:
  controllerName: gateway.envoyproxy.io/gatewayclass-controller
  parametersRef:
    group: gateway.envoyproxy.io
    kind: EnvoyProxy
    name: custom-proxy-config
    namespace: envoy-gateway-system
EOF


+

cat <<EOF | kubectl apply -f -
apiVersion: gateway.envoyproxy.io/v1alpha1
kind: EnvoyProxy
metadata:
  name: custom-proxy-config
  namespace: envoy-gateway-system
spec:
  provider:
    type: Kubernetes
    kubernetes:
      envoyDeployment:
        replicas: 1
      envoyService:
        type: NodePort
EOF
```

## Fix the TLS endpoint:


```
# create cert
cat <<EOF | kubectl apply -f -
apiVersion: cert-manager.io/v1
kind: Certificate
metadata:
  name: gateway-http-https-wildcard-cert
  namespace: envoy-gateway-system
spec:
  secretName: gateway-http-https-wildcard-cert
  issuerRef:
    name: cloudydemo-googledns-issuer
    kind: ClusterIssuer
  dnsNames:
  - gpu-local.cloudydemo.com
  - "*.gpu-local.cloudydemo.com"
EOF
```


```
cat <<EOF | kubectl apply -n default -f -
apiVersion: gateway.networking.k8s.io/v1
kind: Gateway
metadata:
  name: eg
  namespace: envoy-gateway-system
spec:
  gatewayClassName: eg
  listeners:
  - name: http
    port: 80
    protocol: HTTP
    # hostname: "*.example.com"
  - name: https
    port: 443
    protocol: HTTPS
    # hostname: "*.example.com"
    tls:
      mode: Terminate
      certificateRefs:
      - kind: Secret
        name: example-com
EOF


cat <<EOF | kubectl apply -f -
apiVersion: gateway.networking.k8s.io/v1beta1
kind: Gateway
metadata:
  name: eg
  namespace: envoy-gateway-system
spec:
  gatewayClassName: eg
  listeners:
  - name: https
    hostname: "*.gpu-local.cloudydemo.com"
    port: 443
    protocol: HTTPS
    tls:
      mode: Terminate
      certificateRefs:
      - name: "gateway-http-https-wildcard-cert"
    allowedRoutes:
      namespaces:
        from: All
  - name: http
    protocol: HTTP
    port: 80
    hostname: "*.gpu-local.cloudydemo.com"
    allowedRoutes:
      namespaces:
        from: All
      kinds:
      - kind: HTTPRoute
EOF
```

## set up argocd


```
cat <<EOF | kubectl -n argocd apply -f -
apiVersion: gateway.networking.k8s.io/v1beta1
kind: HTTPRoute
metadata:
  name: argocd-http-redirect
spec:
  parentRefs:
  - name: eg
    namespace: envoy-gateway-system
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
  - name: eg
    namespace: envoy-gateway-system
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
```


## Fix ports

```
kubectl get svc envoy-envoy-gateway-system-eg-5391c79d -n envoy-gateway-system -o json | jq '.spec.ports |= map(. + {"nodePort": .port})' | kubectl apply -f -
```