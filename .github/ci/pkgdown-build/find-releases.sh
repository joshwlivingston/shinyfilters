#!/usr/bin/env bash
# Writes the published releases' tags, the latest release's tag, and a cache
# key for them to $GITHUB_OUTPUT. A failed lookup fails the step, so `latest`
# is only empty when there are no releases.
set -euo pipefail

tags=$(gh release list --exclude-drafts --exclude-pre-releases --json tagName --jq '[.[].tagName] | join(" ")')
latest=
if [ -n "$tags" ]; then
  latest=$(gh release view --json tagName --jq .tagName)
fi
echo "tags=$tags" >> "$GITHUB_OUTPUT"
echo "latest=$latest" >> "$GITHUB_OUTPUT"
echo "key=$(echo "$tags $latest" | sha256sum | cut -c1-16)" >> "$GITHUB_OUTPUT"
