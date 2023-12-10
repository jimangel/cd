This is meta-argocd managing argocd. The original attempt was in helm (moved to WIP), now trying this way:

https://argo-cd.readthedocs.io/en/stable/operator-manual/declarative-setup/#manage-argo-cd-using-argo-cd


https://argo-cd.readthedocs.io/en/stable/operator-manual/declarative-setup/

https://github.com/argoproj/argoproj-deployments/tree/master/argocd

## Run locally

```
kubectl kustomize workloads/01-argocd/config/base
```


## GKE connect setup

https://cloud.google.com/blog/products/containers-kubernetes/connect-gateway-with-argocd


```
export PROJECT_ID=gke-labz
gcloud iam service-accounts create argocd-fleet-admin --project $PROJECT_ID

gcloud iam service-accounts keys create ${HOME}/service_account.json --iam-account=argocd-fleet-admin@${PROJECT_ID}.iam.gserviceaccount.com

# gcloud auth activate-service-account --key-file sa_key.json

gcloud projects add-iam-policy-binding $PROJECT_ID --member "serviceAccount:argocd-fleet-admin@${PROJECT_ID}.iam.gserviceaccount.com" --role roles/gkehub.gatewayEditor

# enable APIs
gcloud services enable --project=$PROJECT_ID gkeconnect.googleapis.com gkehub.googleapis.com cloudresourcemanager.googleapis.com iam.googleapis.com connectgateway.googleapis.com 

# other test
gcloud container fleet memberships list --project $PROJECT_ID




# MORE: https://cloud.google.com/sdk/gcloud/reference/container/fleet/memberships/generate-gateway-rbac



# GRANT GKE CONNECT IAM SA CONTAINER ADMIN ON THE PROJECT (SHOULD BE DESCOPED)
gcloud projects add-iam-policy-binding $PROJECT_ID --member=serviceAccount:argocd-fleet-admin@${PROJECT_ID}.iam.gserviceaccount.com --role=roles/container.admin




# cluster you wish to grant X_ROLE on:
export DEST_CLUSTER_FLEET_MEMBERSHIP_NAME=is-this-free





# Grant ArgoCD permissions to access and manage the application-cluster.

# gcloud container fleet memberships generate-gateway-rbac --membership=my-cluster --users=argocd-fleet-admin@$PROJECT_ID.iam.gserviceaccount.com --role=clusterrole/cluster-admin
# add --apply + --kubeconfig to auto apply
```

## google app creds

https://github.com/argoproj/argo-helm/commit/458221674e44d080f6fabb3b1cfdadee4f28fe6f

```
kubectl -n argocd create secret generic gke-connect-gateway-service-account --from-file=key.json=${HOME}/service_account.json -o yaml 

# --dry-run=client > secret.yaml

# validate with
# kubectl -n argocd get secret gke-connect-gateway-service-account -o=jsonpath='{.data.key\.json}' | base64 -d

# switch to external secrets for this (create the secret before deploying)
apiVersion: v1
kind: Secret
metadata:
  name: gke-connect-gateway-service-account
  namespace: argocd
data:
  key.json: "Your service acount key.json"
```

## create gateway rbac on app cluster for connect gateway

```
# gcloud container fleet memberships list --project $PROJECT_ID

# GET APP CLUSTER CREDENTIALS (active kubeconfig)

gcloud container fleet memberships generate-gateway-rbac --membership=dev --users=argocd-fleet-admin@$PROJECT_ID.iam.gserviceaccount.com --role=clusterrole/cluster-admin --apply --kubeconfig=$KUBECONFIG --context=$(kubectl config current-context)
```

## add cluster to argo and test:

```
export PROJECT_NUMBER=$(gcloud projects describe $PROJECT_ID --format='value(projectNumber)')

# gcloud container fleet memberships list --project $PROJECT_ID
export GKE_FLEET_MEMBER_NAME=dev

# could also be "global"
export LOCATION=us-central1

cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Secret
metadata:
  name: dev-gke-connect-app
  namespace: argocd
  labels:
    argocd.argoproj.io/secret-type: cluster
type: Opaque
stringData:
  name: cluster-app
  server: https://connectgateway.googleapis.com/v1/projects/${PROJECT_NUMBER}/locations/${LOCATION}/gkeMemberships/${GKE_FLEET_MEMBER_NAME}
  config: |
    {
      "execProviderConfig": {
        "command": "argocd-k8s-auth",
        "args": ["gcp"],
        "apiVersion": "client.authentication.k8s.io/v1beta1"
      },
      "tlsClientConfig": {
        "insecure": false,
        "caData": ""
      }
    }
EOF
```

```
cat <<EOF > clusters/test.yaml
cluster:
  # try to match name in ArgoCD or planned name
  name: cluster-app
  # for applicationset names generally
  friendlyName: "gpu-box"
  # use https://kubernetes.default.svc for local argo
  server: https://connectgateway.googleapis.com/v1/projects/${PROJECT_NUMBER}/locations/global/gkeMemberships/${GKE_FLEET_MEMBER_NAME}
  domain: cloudydemo.com
  # could be used for common ingress settings per cluster domain
  subdomain: gpu-local
# themes for common and shared values
themes:
  environment: staging
  #role: ci
  #provider: baremetal|gke|aws
  provider: gke
# workloads opt-in as inventory
workloads:
  certmanager: deployed
  gatekeeper: deployed
EOF
```

## Quota issues

> check page for quota current usage...
> https://console.cloud.google.com/apis/api/connectgateway.googleapis.com/quotas?project=