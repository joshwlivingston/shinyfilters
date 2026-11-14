#!/usr/bin/env bash
# Combines the release sites and the dev site into site/, with redirects and
# a version menu listing every release.
set -euo pipefail

# redirect <site> <url> <dir>: for each page of <site>, writes a page to <dir>
# that redirects to the same page under <url>.
redirect() {
  (cd "$1" && find . -name '*.html' -printf '%P\n') | while read -r page; do
    target="$2/$page"
    case "$target" in */index.html) target="${target%index.html}" ;; esac
    mkdir -p "$3/$(dirname "$page")"
    printf '%s\n' \
      '<!DOCTYPE html>' \
      '<meta charset="utf-8">' \
      '<title>Redirecting</title>' \
      '<meta name="robots" content="noindex">' \
      "<link rel=\"canonical\" href=\"$target\">" \
      "<script>location.replace(\"$target\" + location.search + location.hash)</script>" \
      "<meta http-equiv=\"refresh\" content=\"0; url=$target\">" \
      > "$3/$page"
  done
}

if [ -n "$LATEST" ]; then
  cp -r "releases/${LATEST#v}" site
else
  cp -r docs/dev site
fi
for tag in $TAGS; do
  if [ "$tag" = "$LATEST" ]; then
    redirect "releases/${tag#v}" "$SITE_URL" "site/${tag#v}"
  else
    cp -r "releases/${tag#v}" "site/${tag#v}"
  fi
done
cp -r docs/dev site/dev
dev=$(sed -n 's/^Version: *//p' DESCRIPTION)
[ -e "site/$dev" ] || redirect docs/dev "$SITE_URL/dev" "site/$dev"

# The version menu lists the latest release, dev, then each earlier release.
# The list replaces the menu's fallback item in every page on each deploy, so
# cached sites also list releases published after they were built.
item='<li><a class="dropdown-item" href="%s">%s</a></li>'
items=$(
  if [ -n "$LATEST" ]; then
    printf "$item" "$SITE_URL/" "${LATEST#v} (latest)"
  fi
  printf "$item" "$SITE_URL/dev/" dev
  for tag in $TAGS; do
    if [ "$tag" != "$LATEST" ]; then
      printf "$item" "$SITE_URL/${tag#v}/" "${tag#v}"
    fi
  done
)
find site -name '*.html' -exec sed -i "s|<li class=\"version-menu\"><a [^>]*>[^<]*</a></li>|$items|" {} +

# Every page with a navbar must now hold the list. If the pattern above stops
# matching what pkgdown writes, the deploy fails instead of publishing menus
# that list one version.
pages=$(grep -rl --include='*.html' '<nav' site || true)
unfilled=$(for page in $pages; do grep -qF -- "$items" "$page" || echo "$page"; done)
if [ -z "$pages" ] || [ -n "$unfilled" ]; then
  echo "::error::The version menu wasn't filled in on these pages:"
  echo "${unfilled:-(no page has a navbar)}"
  exit 1
fi
