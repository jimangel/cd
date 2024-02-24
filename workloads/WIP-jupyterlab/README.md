Move away from janky mounts in the cloud

## Deploy locally

```
# use create vs. apply to assume deleting before changing
kubectl create -f workloads/WIP-jupyterlab/config

kubectl delete -f workloads/WIP-jupyterlab/config
```