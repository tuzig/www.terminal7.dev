#!/usr/bin/env bash
set -uo pipefail

ORG='tuzig'
AUTHORS_FILE='layouts/shortcodes/authors.html'
API='https://api.github.com'

tmp=$(mktemp)
trap 'rm -f "$tmp"' EXIT

{
  echo "<ul class='authors'>"
  curl -sf "$API/orgs/$ORG/repos?type=sources&per_page=100" \
    | jq -r '.[].name' \
    | while read -r repo; do
        curl -sf "$API/repos/$ORG/$repo/contributors?per_page=100"
      done \
    | jq -sr '
        [.[] | select(type=="array") | .[] | select(.type != "Bot")]
        | unique_by(.login) | sort_by(.login)
        | .[] | "<li><a href=\"\(.html_url)\"><img src=\"\(.avatar_url)\" width=\"50\" height=\"50\" alt=\"\(.login)\"></a></li>"
      '
  echo "</ul>"
} > "$tmp"

if grep -q '<li' "$tmp"; then
  mv "$tmp" "$AUTHORS_FILE"
else
  echo "WARNING: contributor fetch yielded no entries — keeping existing $AUTHORS_FILE and continuing build" >&2
fi

hugo --gc --minify
