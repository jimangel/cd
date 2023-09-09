## enable istio injection after install

- TODO: auotmate into stack

Mainly https://istio.io/latest/docs/setup/additional-setup/getting-started/

Installs the base + istiod helm charts (https://istio.io/latest/docs/setup/install/helm/)

Does not install gateways (https://artifacthub.io/packages/helm/istio-official/gateway)

---

After ArgoCD installs the core components, enable injection on the default namespace and test:

```
kubectl label namespace default istio-injection=enabled
```

## Deploy sample app

https://istio.io/latest/docs/setup/additional-setup/getting-started/#bookinfo

```
kubectl config set-context --current --namespace=default

kubectl apply -f https://raw.githubusercontent.com/istio/istio/release-1.19/samples/bookinfo/platform/kube/bookinfo.yaml
```

## locally preview yaml

```
helm template --repo https://istio-release.storage.googleapis.com/charts istiod


kubectl config set-context --current --namespace=istio-system
kubectl -n istio-system kustomize --enable-helm .
```

## Run locally

```
kustomize build --enable-helm workloads/istio/config/kustomized-helm/


      ignoreDifferences:
      # for the specified json pointers
      - group: admissionregistration.k8s.io
        kind: ValidatingWebhookConfiguration
        jqPathExpressions:
        - '.webhooks[].clientConfig.caBundle'
        - '.webhooks[].failurePolicy'
```