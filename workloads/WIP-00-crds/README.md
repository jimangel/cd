Put any important CRDs here (like Gateway API). This allows for "pre-loading" CRDs that would normally prevent ArgoCD from syncing.

- Gateway API

```
# test locally
kubectl kustomize workloads/00-crds/config/base

# apply
kubectl apply -k workloads/00-crds/config/base
```