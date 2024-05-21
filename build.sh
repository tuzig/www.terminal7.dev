#!/usr/bin/env bash

# Set the GitHub organization name
ORG_NAME='tuzig'
AUTHORS_FILE='./layouts/shortcodes/authors.html'

# Get a list of repositories for the organization
REPOS=$(curl -s -H "Authorization: token $GH_TOKEN" "https://api.github.com/orgs/$ORG_NAME/repos?type=sources" | jq -r '.[].full_name')
if [[ $? -ne 0 ]]; then
  echo "Failed to fetch repositories. Is GH_TOKEN valid?"
  exit 1
fi
if [[ -z $REPOS ]]; then
  echo "No repositories found."
  exit 2
fi

# Initialize an empty array to store unique contributors
declare -A CONTRIBUTORS

for REPO in $REPOS; do
  # Get the list of contributors for the repository
  REPO_CONTRIBUTORS=$(curl -s -H "Authorization: token $GH_TOKEN" "https://api.github.com/repos/$REPO/contributors" | jq -r '.[].login')

  # Add each contributor to the array if not already present
  for CONTRIBUTOR in $REPO_CONTRIBUTORS; do
    # Check if the contributor is a bot
    if [[ $CONTRIBUTOR == *"[bot]" ]]; then
      # Strip the '[bot]' suffix from the username
      CONTRIBUTOR=${CONTRIBUTOR%"[bot]"}
    fi
    
    CONTRIBUTORS[$CONTRIBUTOR]=1
  done
done

#  create the AUTHORS_FILE directory
mkdir -p $(dirname $AUTHORS_FILE)
# Generate the HTML snippet
echo "<ul class='authors'>" > $AUTHORS_FILE
for CONTRIBUTOR in "${!CONTRIBUTORS[@]}"; do
  # Get the contributor's avatar URL and profile URL
  AVATAR_URL=$(curl -s -H "Authorization: token $GH_TOKEN" "https://api.github.com/users/$CONTRIBUTOR" | jq -r '.avatar_url')
  PROFILE_URL="https://github.com/$CONTRIBUTOR"

  # Generate the HTML list item
  echo "<li><a href=\"$PROFILE_URL\"><img src=\"$AVATAR_URL\" width=\"50\" height=\"50\" alt=\"$CONTRIBUTOR\"></a></li>" >> $AUTHORS_FILE
done
echo "</ul>" >> $AUTHORS_FILE
hugo --gc --minify
