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
kubectl -n external-secrets delete secret generic cloudydemo-external-secrets-admin --from-file=secret-access-credentials=$HOME/key2.json
```

```
export PROJECT_ID=myproject-id

cat <<EOF | kubectl apply -f -
apiVersion: external-secrets.io/v1alpha1
kind: ClusterSecretStore
metadata:
  name: gcp-backend
spec:
  provider:
      gcpsm:
        auth:
          secretRef:
            secretAccessKeySecretRef:
              name: cloudydemo-external-secrets-admin
              key: secret-access-credentials
        projectID: $project
EOF



apiVersion: cert-manager.io/v1
kind: ClusterIssuer
metadata:
  name: cloudydemo-googledns-issuer
spec:
  acme:
    email: $EMAIL
    server: https://acme-v02.api.letsencrypt.org/directory
    privateKeySecretRef:
      # Secret resource that will be used to store the account's private key.
      name: letsencrypt-privkey-prod
    solvers:
    - dns01:
        cloudDNS:
          # The ID of the GCP project
          project: $PROJECT_ID
          # This is the secret used to access the service account
          serviceAccountSecretRef:
            name: clouddns-dns01-solver-svc-acct
            key: key.json
EOF
```

Validate status:

```
kubectl describe clusterissuer cloudydemo-googledns-issuer
```

Test:

```
cat <<EOF | kubectl apply -f -
apiVersion: cert-manager.io/v1
kind: Certificate
metadata:
  name: argocd-ui-cert-resource
  namespace: istio-gateway
spec:
  secretName: argocd-ui-cert
  issuerRef:
    name: cloudydemo-googledns-issuer
    kind: ClusterIssuer
  dnsNames:
  - argocd.cloudydemo.com
EOF

cat <<EOF | kubectl apply -f -
apiVersion: cert-manager.io/v1
kind: Certificate
metadata:
  name: gateway-http-https-wildcard-cert
  namespace: istio-gateway
spec:
  secretName: gateway-http-https-wildcard-cert
  issuerRef:
    name: cloudydemo-googledns-issuer
    kind: ClusterIssuer
  dnsNames:
  - gpu-local.cloudydemo.com
  - "*.gpu-local.cloudydemo.com"
EOF
```