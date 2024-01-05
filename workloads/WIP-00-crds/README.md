Put any important CRDs here (like Gateway API). This allows for "pre-loading" CRDs that would normally prevent ArgoCD from syncing.

- Gateway API

```
# test locally
kubectl kustomize workloads/WIP-00-crds/config/base

# kubectl kustomize workloads/WIP-00-crds/config/base | grep "Kind: "

# apply
kubectl apply -k workloads/WIP-00-crds/config/base
```