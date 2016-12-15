#!/bin/bash

echo -e "\033[0;32mDeploying updates to botmaster documentaition...\033[0m"

# Build the project.
hugo -t hugo-theme-learn

# Add changes to git.
git add -A

# Commit changes.
msg="rebuilding site `date`"
if [ $# -eq 1 ]
  then msg="$1"
fi
git commit -m "$msg"

# Push source and build repos.
git push origin hugo-code
git subtree push --prefix=public origin master