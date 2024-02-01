kustomize build workloads/WIP-metallb/config/overlays/baremetal/

kubectl -n metallb-system kustomize workloads/WIP-metallb/config/overlays/baremetal/ | kubectl apply -f -

## TODO:

- CRD removal?
- config automation

## Debug

```
kubectl logs -f -l component=speaker -n metallb-system
```

## Delete (manual)

```
kubectl -n metallb-system kustomize workloads/WIP-metallb/config/overlays/baremetal/ | kubectl delete -f -
```