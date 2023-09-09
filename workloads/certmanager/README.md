Creates the base cert manager install, you are left with configuring the provider...

TODO: Create descoped IAM

Create GCP service account to use (if local) otherwise use workload ID:

```
PROJECT_ID=myproject-id
gcloud iam service-accounts create cloudydemo-dns01-solver --display-name "cloudydemo-dns01-solver"

# grant dns admin
gcloud projects add-iam-policy-binding $PROJECT_ID \
   --member serviceAccount:cloudydemo-dns01-solver@$PROJECT_ID.iam.gserviceaccount.com \
   --role roles/dns.admin

# get service account
gcloud iam service-accounts keys create ~/key.json \
   --iam-account cloudydemo-dns01-solver@$PROJECT_ID.iam.gserviceaccount.com

# create secret
kubectl -n cert-manager create secret generic clouddns-dns01-solver-svc-acct \
   --from-file=$HOME/key.json
```

```
export EMAIL="emailaddress@example.com"
export PROJECT_ID=myproject-id

cat <<EOF | kubectl apply -f -
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