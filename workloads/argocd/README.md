This is meta-argocd managing argocd. The original attempt was in helm (moved to WIP), now trying this way:

https://argo-cd.readthedocs.io/en/stable/operator-manual/declarative-setup/#manage-argo-cd-using-argo-cd


https://argo-cd.readthedocs.io/en/stable/operator-manual/declarative-setup/

https://github.com/argoproj/argoproj-deployments/tree/master/argocd

## Run locally

kubectl kustomize workloads/argocd/config/overlays/staging/ 