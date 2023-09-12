# cd

Complex / simple CD setup. After one-time / one-line setup argoCD, future operations look like:

1. add cluster to argoCD
1. create cluster values.json in proper environment

Done!

It is up to you to determine what an "environment" is but the concept to keep management simple is:

- AppSets rule the world (cluster / env selection / e2e CD)
- A cluster config (json) inherits the parent folder name environment
- Cluster config should contain an app list and minimal unique config (such as host names)

Keep the power limited to a few areas (cluster config directory location / AppSet). Try to generalize as much as possible into environment (AppSet) configs.

Following these principals makes updating, scaling, and debugging easier as each "knob" is limited to only a few areas with fewer parameters.

- TODO: rename the files to their hosts (k8s-xxx-thing.yaml, argocd-envxxxxx.json, helm-values-env-xxxx.yaml)

## Pre reqs

```
SSH auth / key between source repo and cluster (or use public repo)
```

## Install cluster

```
# TODO (kubespray / alt)
```

## Copy Repo

```
git clone git@github.com:jimangel/cd.git
```


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


kubectl -n argocd port-forward svc/argocd-server 8080:443

# User: Admin
# Password (below)

kubectl -n argocd get secrets argocd-initial-admin-secret \
-o jsonpath='{.data.password}' | base64 -d
```


---

```
Create rollout extension:

kubectl apply -n argocd \
    -f https://raw.githubusercontent.com/argoproj-labs/rollout-extension/v0.2.1/manifests/install.yaml
Log in to argo cd
https://argo-cd.readthedocs.io/en/stable/getting_started/

# Get admin password (for next step login)

# argocd admin initial-password -n argocd

# for login / ui
kubectl -n argocd port-forward svc/argocd-server 8080:443

#The API server can then be accessed using https://localhost:8080
```

## setup ssh

```
export REPO_NAME="git@github.com:jimangel/cd"

cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Secret
metadata:
  name: private-repo
  namespace: argocd
  labels:
    argocd.argoproj.io/secret-type: repository
stringData:
  type: git
  url: ${REPO_NAME}
  sshPrivateKey: |
$(cat $HOME/.ssh/id_ed25519  | sed 's/^/    /')
EOF
```


---

export CLUSTER_ENV="envs/gpu-box"

cat <<EOF | kubectl apply -f -
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: app-of-apps
  namespace: argocd
spec:
  project: default
  revisionHistoryLimit: 5
  source:
    repoURL: ${REPO_NAME}
    path: ${CLUSTER_ENV}
    targetRevision: HEAD
  destination:
    server: 'https://kubernetes.default.svc'
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
EOF

## Add a cluster

"To deploy an application to its associated environment, just point your GitOps controller to the respective “env” folder and kustomize will create the complete hierarchy of settings and values."

```
# TODO: auto-add cluster(s) with a config.json entry

```

## Remove argo

```
# kustomize build ./argocd-install/non-ha/ | kubectl delete -f - -n argocd
kustomize build ./argocd-install/ha/ | kubectl delete -f - -n argocd
```