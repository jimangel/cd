# cd

## Install cluster

```
# TODO
```

## Copy Repo

git clone cd...

## Install kustomize

```
# https://kubectl.docs.kubernetes.io/installation/
curl -s "https://raw.githubusercontent.com/kubernetes-sigs/kustomize/master/hack/install_kustomize.sh"  | bash
sudo mv kustomize /usr/local/bin/
```

## Install Argo CD

```
# kubectl create ns argocd && kustomize build ./argocd-install/ha/ | kubectl apply -f - -n argocd
kubectl create ns argocd && kustomize build ./argocd-install/non-ha/ | kubectl apply -f - -n argocd
```

Get the password:

```
kubectl -n argocd get secrets argocd-initial-admin-secret \
    -o jsonpath='{.data.password}' | base64 -d
```

## Add a cluster

```

```

## Remove argo

```
# kustomize build ./argocd-install/non-ha/ | kubectl delete -f - -n argocd
kustomize build ./argocd-install/ha/ | kubectl delete -f - -n argocd
```