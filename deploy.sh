#!/bin/sh

# If a command fails, then stop the deploy:
set -e
printf "\033[0;32mDeploying updates to GitHub...\033[0m\n"

# Build the project
hugo -t m10c # if using a theme, add `-t <YOUR THEME>`

# Add changes to GitHub
cd public
git add .
msg="rebuilding site $(date)"
if [ -n "$*" ]; then
	msg="$*"
fi
git commit -m "$msg"

# Push source and build repos
git push origin master
