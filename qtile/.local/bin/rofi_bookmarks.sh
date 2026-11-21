#!/usr/bin/env bash
set -euo pipefail

# ── CONFIGURATION ──────────────────────────────────────────────────────────────
# For a different endpoint, override this env‐var before calling the script:
#    export KARAKEEP_API_URL="https://karakeep.your.domain/api/bookmarks"
API_URL="${KARAKEEP_API_URL:-https://hoarder.coder.cam/api/v1/bookmarks?limit=100}"
# ── END CONFIGURATION ──────────────────────────────────────────────────────────

# 1) pull your API key from the keyvault named “Hoarder API Key”:
API_KEY=$(secret-tool lookup service "Hoarder API Key") \
  || { echo "❌ failed to read API key from secret-tool" >&2; exit 1; }

# Define cache file path for both manual and script mode
CACHE_FILE="${TMPDIR:-/tmp}/bookmarks_cache_${USER}"

# Fetch all bookmark pages and output as title – url lines
fetch_lines() {
  local cursor="" raw nextCursor url
  while :; do
    url="$API_URL"
    if [ -n "$cursor" ] && [ "$cursor" != "null" ]; then
      url="${url}&cursor=${cursor}"
    fi
    raw=$(curl -sSf \
      -H "Authorization: Bearer $API_KEY" \
      -H "Accept: application/json" \
      "$url") || { echo "❌ failed to fetch bookmarks from $url" >&2; return 1; }
    nextCursor=$(jq -r '.nextCursor' <<< "$raw")
    jq -r '.bookmarks[] | [(.title // ""), .content.title, .content.url] | map(select(. != "")) | join(" - ")' <<< "$raw"
    if [ -z "$nextCursor" ] || [ "$nextCursor" = "null" ]; then
      break
    fi
    cursor="$nextCursor"
  done
}

# Update the cache file atomically
update_cache() {
  local tmpfile
  tmpfile=$(mktemp) || return 1
  if fetch_lines > "$tmpfile"; then
    mv "$tmpfile" "$CACHE_FILE"
  else
    rm -f "$tmpfile"
    return 1
  fi
}

# Detect rofi script mode invocation (plugin mode) and output cached bookmarks list
for arg in "$@"; do
  if [ "$arg" = "-dmenu" ]; then
    # Ensure cache exists
    if [ ! -f "$CACHE_FILE" ]; then
      update_cache || exit 1
    fi
    # Load and output entries
    readarray -t lines < "$CACHE_FILE"
    # Refresh cache in background
    update_cache &>/dev/null &
    [ "${#lines[@]}" -gt 0 ] || exit 1
    printf '%s\n' "${lines[@]}"
    exit 0
  fi
done

# Optional cursor parameter (for pagination)
CURSOR="${1:-}"
# If no cursor parameter is provided, use cached bookmarks for faster rofi launch
if [ "$#" -eq 0 ]; then
  # Ensure cache exists, then load lines
  if [ ! -f "$CACHE_FILE" ]; then
    echo "Fetching bookmarks..." >&2
    update_cache || exit 1
  fi
  readarray -t lines < "$CACHE_FILE"

  # Refresh cache in background
  update_cache &>/dev/null &

  # Exit if no bookmarks
  if [ "${#lines[@]}" -eq 0 ]; then
    echo "No bookmarks found." >&2
    exit 1
  fi

  # Prompt user with cached bookmarks
  choice=$(printf '%s\n' "${lines[@]}" | rofi -dmenu -i -p "Bookmarks") || exit 0
  url=${choice##* - }
  xdg-open "$url" &>/dev/null & disown
  exit 0
fi

# 2) fetch all pages of bookmarks using cursor pagination
lines=()
while :; do
  url="$API_URL"
  if [ -n "$CURSOR" ] && [ "$CURSOR" != "null" ]; then
    url="${url}&cursor=${CURSOR}"
  fi
  raw=$(curl -sSf \
        -H "Authorization: Bearer $API_KEY" \
        -H "Accept: application/json" \
        "$url") \
    || { echo "❌ failed to fetch bookmarks from $url" >&2; exit 1; }
  nextCursor=$(jq -r '.nextCursor' <<< "$raw")
  # collect bookmark entries
  while IFS= read -r line; do
    lines+=("$line")
  done < <(jq -r '.bookmarks[] | [(.title // ""), .content.title, .content.url] | map(select(. != "")) | join(" - ")' <<< "$raw")
  # break if no further pages
  if [ -z "$nextCursor" ] || [ "$nextCursor" = "null" ]; then
    break
  fi
  CURSOR="$nextCursor"
done
if [ "${#lines[@]}" -eq 0 ]; then
  echo "No bookmarks found." >&2
  exit 1
fi

# 3) let the user pick one
choice=$(printf '%s\n' "${lines[@]}" \
          | rofi -dmenu -i -p "Bookmarks") \
      || exit 0

# 4) extract the URL portion and open it
url=${choice##* - }
xdg-open "$url" &>/dev/null & disown
