#!/bin/bash

# Variables
BRANCH_NAME="feature/OPS-7701-code-ql-version-update"  
COMMIT_MESSAGE="code ql version update to v3"
PR_TITLE="Code QL version update v3"
REPOSITORIES=("carrier-transport-message-listener-service" "carrier-transport-service" "cha-offer-service" "charity-message-listener-service")

TARGET_FILE=".github/workflows/codeql.yml"
GITHUB_ORG="peddleon"

# Function to commit and create PR for each repository
commit_and_create_pr() {
    local repo=$1
    
    echo "Processing repository: $repo"
    cd "$repo" || exit
    
    # Echo the current path
    echo "Current path: $(pwd)"
    
    git checkout -b "$BRANCH_NAME"
    #git pull origin "$BRANCH_NAME"
    # Ensure the target file exists
    if [ -f "$TARGET_FILE" ]; then
        echo "File $TARGET_FILE found."
        
        # Replace specific lines based on their content

        sed -i 's|github/codeql-action/init@v2|github/codeql-action/init@v3|g' "$TARGET_FILE"
        sed -i 's|github/codeql-action/autobuild@v2|github/codeql-action/autobuild@v3|g' "$TARGET_FILE"
        sed -i 's|github/codeql-action/analyze@v2|github/codeql-action/analyze@v3|g' "$TARGET_FILE"
        sed -i 's|github/codeql-action/upload-sarif@v2|github/codeql-action/upload-sarif@v3|g' "$TARGET_FILE"

        # Stage the changes
        git add "$TARGET_FILE"
        
        # Commit the changes
        git commit -S -m "$COMMIT_MESSAGE"
        
        # Push the branch
        git push -u origin "$BRANCH_NAME"
        
        # Create a pull request using GitHub CLI
        gh pr create --title "$PR_TITLE" --body "$PR_BODY" --base development --head "$BRANCH_NAME"
    else
        echo "File $TARGET_FILE not found in $(pwd), skipping."
    fi

    # Go back to the root directory
    cd - || exit
}

# Function to clone repository if it doesn't exist
clone_repo_if_needed() {
    local repo_name=$1
    local repo_dir=$2
    
    if [ ! -d "$repo_dir" ]; then
        echo "Directory $repo_dir does not exist, cloning repository."
        echo "https://github.com/$GITHUB_ORG/$repo_name.git" "$repo_dir"
        #git clone "https://github.com/$GITHUB_ORG/$repo_name.git" "$repo_dir"
	git clone "git@github.com:$GITHUB_ORG/$repo_name.git" "$repo_dir"
    fi
}

# Function to remove the repository directory
remove_repo_directory() {
    local repo_dir=$1
    echo "$repo_dir"
    if [ -d "$repo_dir" ]; then
        echo "Removing directory: $repo_dir"
        rm -rf "$repo_dir"
    else
        echo "Directory $repo_dir does not exist or $REMOVE_REPO_AFTER_USE is not set to true."
    fi
}

# Iterate over the list of repositories
for repo in "${REPOSITORIES[@]}"; do
    repo_name=$(basename "$repo")  # Extract the repository name
    clone_repo_if_needed "$repo_name" "$repo"
    
    if [ -d "$repo" ]; then
        commit_and_create_pr "$repo"
        # Ensure we return to the original directory before removing
        cd "$initial_dir"
        remove_repo_directory "$OLDPWD/$repo"
    else
        echo "Failed to clone or find the directory $repo, skipping."
    fi
done

echo "Script completed."
