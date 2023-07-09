# Step 1: Prompt the user if they want to do a release
read -p "Do you want to do a release? (y/n): " release_prompt
if [[ $release_prompt != "y" ]]; then
    echo "Release canceled."
    exit 0
fi

# Step 2: List all branches and ask the user to select one for the release
echo "Available branches:"
git branch -r --no-abbrev | awk -F/ '{print $NF}'
read -p "Enter the branch name for the release: " release_branch_name

# Step 3: List all remotes and have the user select one
echo "Available remotes:"
git remote --verbose
read -p "Enter the remote name for the release: " remote_name

# Step 4: Ask the user if they want to create a backup branch
read -p "Do you want to create a backup branch? (y/n): " backup_prompt
if [[ $backup_prompt == "y" ]]; then
    # Step 5: Ask for the name of the backup branch
    read -p "Enter the name of the backup branch: " backup_branch_name
    git branch $backup_branch_name
    git push $remote_name $backup_branch_name
    echo "Created and published backup branch: $backup_branch_name"
fi

# Step 6: Perform a git pull on the selected origin and branch name
git pull $remote_name $release_branch_name

if [[ $? -eq 0 ]]; then
    echo "Git pull successful.Release completed."

    # Step 7: Prompt the user if they want to roll back
    read -p "Would you like to roll back? (y/n): " rollback_prompt
    if [[ $rollback_prompt == "y" ]]; then
        # Step 8: Perform a git checkout and git pull on the selected remote and branch
        git checkout $backup_branch_name
        git pull $remote_name $backup_branch_name
        echo "Rollback completed."
    else
        echo "Release completed."
    fi
else
    echo "Error occurred during git pull."
fi
