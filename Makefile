
# lint the clusters list for duplicate values
lint:
    # specifically the "name" "friendlyName" and "subdomain" keys (with support for appending more fields) in ./clusters/*.yaml
	./scripts/lint_cluster_yaml.py "./clusters/*.yaml" name friendlyName subdomain