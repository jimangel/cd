# TODO* use context, create manual yaml (no argocd CLI) and then create / open PR for cluster.json (interactive menu).

export CLUSTER_NAME=
export CLUSTER_REGISTRATION_NAME=
export PROJECT_NUMBER=

cat <<EOF | kubectl -n argocd apply -f -
apiVersion: v1
kind: Secret
metadata:
  name: mycluster-secret
  labels:
    argocd.argoproj.io/secret-type: cluster
type: Opaque
stringData:
  name: cluster-app
          https://connectgateway.googleapis.com/v1/projects/814233161045/locations/global/gkeMemberships/my-company-dev
  server: https://connectgateway.googleapis.com/v1beta1/projects/$PROJECT_NUMBER/locations/global/gkeMemberships/$CLUSTER_REGISTRATION_NAME
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