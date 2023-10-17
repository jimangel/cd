## setup

Creates the base cert manager install, you are left with configuring the provider...

TODO: Create descoped IAM

--- 

## GCP side

Create GCP service account to use (if local) otherwise use workload ID:

```
# gcloud config configurations activate gitops-secrets
PROJECT_ID=myproject-id

gcloud iam service-accounts create cloudydemo-secret-admin --display-name "cloudydemo-secret-admin"

# grant permissions per secret
gcloud secrets add-iam-policy-binding mysecret --member "serviceAccount:cloudydemo-secret-admin@$PROJECT_ID.iam.gserviceaccount.com" --role "roles/secretmanager.secretAccessor"
# OR
# grant permissions per all
gcloud projects add-iam-policy-binding $PROJECT_ID --member "serviceAccount:cloudydemo-secret-admin@$PROJECT_ID.iam.gserviceaccount.com" --role "roles/secretmanager.secretAccessor"


# download service account
gcloud iam service-accounts keys create ~/key-2.json --iam-account cloudydemo-secret-admin@$PROJECT_ID.iam.gserviceaccount.com

# create secret
kubectl -n external-secrets create secret generic cloudydemo-secret-admin --from-file=secret-access-credentials=$HOME/key2.json
```

echo -ne '{"password":"itsasecret"}' | gcloud secrets create mysecret --data-file=-


```
export EMAIL="emailaddress@example.com"
export PROJECT_ID=myproject-id



cat <<EOF | kubectl apply -f -
apiVersion: external-secrets.io/v1beta1
kind: ClusterSecretStore
metadata:
  name: gcp-backend
spec:
  provider:
      gcpsm:
        auth:
          secretRef:
            secretAccessKeySecretRef:
              name: cloudydemo-secret-admin
              key: secret-access-credentials
        projectID: $PROJECT_ID
---
apiVersion: external-secrets.io/v1beta1
kind: ExternalSecret
metadata:
  name: gcp-external-secret
  namespace: external-secrets
spec:
  secretStoreRef:
    kind: ClusterSecretStore
    name: gcp-backend          
  target:
    name: secret-to-be-created 
  data:
  - secretKey: yolo.org
    remoteRef:
      key: mysecret
EOF

# test / validate
kubectl -n external-secrets get secret secret-to-be-created -o jsonpath='{.data.yolo\.org}' | base64 -d
```