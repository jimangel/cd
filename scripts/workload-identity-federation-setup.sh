#!/bin/bash

# Variables
PROVIDER_NAME="argocd-cluster-provider"
POOL_ID="custom-baremetal-pool"
WIF_NAMESPACES=("external-secrets" "cert-manager" "argocd")

# Function to confirm the Kubernetes context
confirm_context() {
    local context_name=$(kubectl config view --minify --flatten -o=jsonpath='{.contexts[0].name}')
    local cluster_name=$(kubectl config view --minify --flatten -o=jsonpath='{.contexts[0].context.cluster}')
    local user_name=$(kubectl config view --minify --flatten -o=jsonpath='{.contexts[0].context.user}')

    echo "Current Context: $context_name"
    echo "Cluster Name: $cluster_name"
    echo "User: $user_name"
    read -p "Is this the correct context? (y/n) " confirmation

    if [[ $confirmation != "y" ]]; then
        echo "Incorrect context. Exiting..."
        exit 1
    fi
}

# Combined function to confirm gcloud settings
confirm_gcloud() {
    local current_project=$(gcloud config get-value project 2>/dev/null)
    local current_user=$(gcloud config get-value account 2>/dev/null)

    echo "Current GCP Project: $current_project"
    echo "Current gcloud user: $current_user"
    echo "Using pool ID: $POOL_ID"
    read -p "Are you sure you want to execute the command? (y/n) " confirmation

    if [[ $confirmation == "y" ]]; then
        if check_provider_exists; then
            update_provider
        else
            # Create the OIDC provider if it does not exist
            create_provider
        fi
    else
        echo "Command execution cancelled."
        exit 0
    fi
}


# Function to check if the OIDC provider exists
check_provider_exists() {
    gcloud iam workload-identity-pools providers list \
    --location="global" \
    --workload-identity-pool="${POOL_ID}" \
    --format="value(name)" | grep -q "${PROVIDER_NAME}"
    return $?
}


# Function to construct the attribute-condition string
construct_attribute_condition() {
    local condition="assertion['kubernetes.io']['namespace'] in ["

    for i in "${!WIF_NAMESPACES[@]}"; do
        condition+="'${WIF_NAMESPACES[i]}'"
        if [ $i -lt $((${#WIF_NAMESPACES[@]} - 1)) ]; then
            condition+=", "
        fi
    done

    condition+="]"
    echo "$condition"
}

# Function to prompt for confirmation and update the provider
update_provider() {
    read -p "The OIDC provider '${PROVIDER_NAME}' already exists. Do you want to overwrite it? (y/n) " confirmation
    if [[ $confirmation == "y" ]]; then
        # should be "https://kubernetes.default.svc.cluster.local" if local
        ISSUER_URI=$(kubectl get --raw /.well-known/openid-configuration | grep '"issuer"' | awk -F '"' '{print $4}')
    
        # Create a temporary file for JWKS
        TEMP_JWKS_FILE=$(mktemp)
    
        # Set up a trap to call the cleanup function on script exit
        trap cleanup EXIT
    
        # Fetch JWKS data and write to the temporary file
        kubectl get --raw /openid/v1/jwks > "$TEMP_JWKS_FILE"
    
        ATTRIBUTE_CONDITION=$(construct_attribute_condition)
        gcloud iam workload-identity-pools providers update-oidc "${PROVIDER_NAME}" --location="global" --workload-identity-pool="${POOL_ID}" \
        --issuer-uri="${ISSUER_URI}" \
        --attribute-mapping="google.subject=assertion.sub,attribute.namespace=assertion['kubernetes.io']['namespace'],attribute.service_account_name=assertion['kubernetes.io']['serviceaccount']['name'],attribute.pod=assertion['kubernetes.io']['pod']['name']" \
        --attribute-condition="${ATTRIBUTE_CONDITION}" \
        --jwk-json-path="${TEMP_JWKS_FILE}"
    else
        echo "Provider update cancelled."
    fi
}

# Function to execute the gcloud command
create_provider() {
    # should be "https://kubernetes.default.svc.cluster.local" if local
    ISSUER_URI=$(kubectl get --raw /.well-known/openid-configuration | grep '"issuer"' | awk -F '"' '{print $4}')

    # Create a temporary file for JWKS
    TEMP_JWKS_FILE=$(mktemp)

    # Set up a trap to call the cleanup function on script exit
    trap cleanup EXIT

    # Fetch JWKS data and write to the temporary file
    kubectl get --raw /openid/v1/jwks > "$TEMP_JWKS_FILE"

    ATTRIBUTE_CONDITION=$(construct_attribute_condition)

    gcloud iam workload-identity-pools providers create-oidc ${PROVIDER_NAME} \
    --location="global" \
    --workload-identity-pool="${POOL_ID}" \
    --issuer-uri="${ISSUER_URI}" \
    --attribute-mapping="google.subject=assertion.sub,attribute.namespace=assertion['kubernetes.io']['namespace'],attribute.service_account_name=assertion['kubernetes.io']['serviceaccount']['name'],attribute.pod=assertion['kubernetes.io']['pod']['name']" \
    --attribute-condition="${ATTRIBUTE_CONDITION}" \
    --jwk-json-path="${TEMP_JWKS_FILE}"
}

# Cleanup function to remove the temporary file
cleanup() {
    echo "Cleaning up..."
    rm -f "$TEMP_JWKS_FILE"
}

# Main script execution
confirm_context
confirm_gcloud