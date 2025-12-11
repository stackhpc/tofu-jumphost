#!/usr/bin/env bash
# Returns current git remote, branch, and commit as JSON
remote=$(git remote get-url origin 2>/dev/null || echo "unknown")
branch=$(git rev-parse --abbrev-ref HEAD 2>/dev/null || echo "unknown")
commit=$(git rev-parse HEAD 2>/dev/null || echo "unknown")

# Output JSON
jq -n --arg remote "$remote" --arg branch "$branch" --arg commit "$commit" \
    '{remote: $remote, branch: $branch, commit: $commit}'
