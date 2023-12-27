#!/usr/bin/env bash

# Script to replace repoURL in files across a git repository
# By default, it performs a dry run. Use '--no-dryrun' to apply changes.

# Determine the root directory of the git repository
ROOT_DIR=$(git rev-parse --show-toplevel)

# Exit if not inside a git repository
if [ $? -ne 0 ]; then
    echo "Error: This script must be run within a git repository."
    exit 1
fi

# Warning and instructions
echo -e "\nThe default behavior makes NO CHANGES. If you wish to apply changes, use: \"--no-dryrun\""
read -p $'\nAre you sure you want to proceed with the default "--dryrun"? (y/n) ' confirm
if [[ "$confirm" != "y" ]]; then
    echo "Operation cancelled."
    exit 0
fi

# Prompt for the new repository URL
read -p $'\nEnter the new repository URL (including "https://"): ' new_repo_url

# Strip any surrounding quotes from the input
new_repo_url=$(echo "$new_repo_url" | sed 's/^"\(.*\)"$/\1/')

# Function to perform the actual URL replacement
replace_repo_url() {
    find "$ROOT_DIR" -type f -exec sed -i 's|repoURL: "https://github.com/jimangel/cd.git"|repoURL: "'"$new_repo_url"'"|g' {} +
}

# Perform a dry run to show proposed changes
echo "Performing a dry run (no changes will be applied):"
find "$ROOT_DIR" -type f -exec grep -H 'repoURL: "https://github.com/jimangel/cd.git"' {} \; | sed 's|repoURL: "https://github.com/jimangel/cd.git"|repoURL: "'"$new_repo_url"'"|'



# Confirmation before applying changes
if [[ "$1" == "--no-dryrun" ]]; then
    echo "You are about to replace all instances of 'https://github.com/jimangel/cd.git' with '$new_repo_url'."
    read -p "Are you sure you want to proceed? (y/n) " confirm
    if [[ "$confirm" == "y" ]]; then
        echo "Applying changes..."
        replace_repo_url
        echo "Changes applied successfully."
        echo "To revert this, run 'git checkout HEAD^' before making any further changes."
    else
        echo "Operation cancelled."
    fi
else
    echo "Dry run completed. To apply changes, rerun with '--no-dryrun'."
fi
