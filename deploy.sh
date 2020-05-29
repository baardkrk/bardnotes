#!/bin/sh

# If a command fails, then stop the deploy:
set -e

# Setting commit message
msg="rebuilding site $(date)"
if [ -n "$*" ]; then
        msg="$*"
fi

printf "\033[0;32mDeploying updates to GitHub...\033[0m\nCommit message: \"$msg\"\n"

# Build the project
hugo # if using a theme, add `-t <YOUR THEME>`

# Add changes to GitHub
cd public
git add .
git commit -m "$msg"

# Push source and build repos
git push origin master

# Push changes to main repo:
printf "\033[0;32mPushing updates to main repository...\033[0m\n"
cd ..
git add .
git commit -m "$msg"
git push
