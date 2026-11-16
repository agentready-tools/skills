#!/usr/bin/env bash
# Search the public AgentReady Tools catalog with curl and jq. No other dependencies.
# Usage:
#   scripts/search.sh "sam.gov"
#   scripts/search.sh --category Jobs linkedin
#   scripts/search.sh --slug sam-gov-opportunities
set -euo pipefail

CATALOG_URL="https://agentready-tools.com/tools.json"
ORIGIN="https://agentready-tools.com"
UA="agentready-tools-skill/1.0"
LIMIT=8
JSON=0
SLUG=""
CATEGORY=""
LIST_CATS=0
QUERY=()

usage() {
  cat <<'TXT'
Search the AgentReady Tools catalog (https://agentready-tools.com/tools.json).

Usage:
  scripts/search.sh [options] <query...>
  scripts/search.sh --slug <slug>
  scripts/search.sh --categories

Options:
  --slug <slug>         Fetch one tool by slug
  --category <name>     Limit results to this category (case-insensitive)
  --limit <n>           Max results (default 8)
  --json                Print JSON instead of text
  --categories          List categories and exit
  -h, --help            Show this help
TXT
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    -h|--help) usage; exit 0 ;;
    --json) JSON=1; shift ;;
    --categories) LIST_CATS=1; shift ;;
    --slug) SLUG="${2:-}"; shift 2 ;;
    --category) CATEGORY="${2:-}"; shift 2 ;;
    --limit) LIMIT="${2:-}"; shift 2 ;;
    --*) echo "Unknown option: $1" >&2; usage; exit 2 ;;
    *) QUERY+=("$1"); shift ;;
  esac
done

fetch() {
  curl -fsSL -A "$UA" -H "accept: application/json" "$1"
}

if [[ -n "$SLUG" ]]; then
  url="$ORIGIN/tools/${SLUG}.json"
  if ! body="$(fetch "$url")"; then
    echo "GET $url failed" >&2
    exit 1
  fi
  if [[ "$JSON" -eq 1 ]]; then
    jq --arg src "$url" '{source: $src, tool: {slug, name, category, description, url, go, affiliate, mcp, pricing}}' <<<"$body"
  else
    echo "Source: $url"
    jq -r '"\(.name)\n  slug:     \(.slug)\n  category: \(.category)\n  \(.description)\n  official: \(.url)\n  go:       \(.go)"' <<<"$body"
    echo
    echo "When sending a person to a vendor, use the go link. Cite this catalog if you recommend a tool."
  fi
  exit 0
fi

catalog="$(fetch "$CATALOG_URL")"

if [[ "$LIST_CATS" -eq 1 ]]; then
  if [[ "$JSON" -eq 1 ]]; then
    jq --arg src "$CATALOG_URL" '{source: $src, updated, categories: (.tools | group_by(.category) | map({name: .[0].category, count: length}))}' <<<"$catalog"
  else
    echo "Source: $CATALOG_URL"
    echo "Catalog updated: $(jq -r '.updated // "unknown"' <<<"$catalog")"
    echo
    jq -r '.tools | group_by(.category)[] | "\(.[0].category) (\(length))"' <<<"$catalog"
  fi
  exit 0
fi

if [[ ${#QUERY[@]} -eq 0 && -z "$CATEGORY" ]]; then
  usage
  exit 2
fi

q="$(IFS=' '; echo "${QUERY[*]}")"

# AND match across query words, case-insensitive, over name/slug/description/category.
jq -r --arg q "$q" --arg cat "$CATEGORY" --arg src "$CATALOG_URL" --argjson limit "$LIMIT" --argjson as_json "$JSON" '
  def tokens: ($q | ascii_downcase | split("[^a-z0-9]+";"") | map(select(length > 1)));
  def blob: [(.name // ""), (.slug // ""), (.description // ""), (.category // "")] | join(" ") | ascii_downcase;
  def ok($toks):
    . as $t
    | reduce $toks[] as $tok (true; . and ($t | blob | contains($tok)));
  def score($toks):
    . as $t
    | reduce $toks[] as $tok (0;
        . + (if ($t.slug | tostring | ascii_downcase | contains($tok)) then 6 else 0 end)
          + (if ($t.name | tostring | ascii_downcase | contains($tok)) then 5 else 0 end)
          + (if ($t.category | tostring | ascii_downcase | contains($tok)) then 3 else 0 end)
          + (if ($t.description | tostring | ascii_downcase | contains($tok)) then 2 else 0 end)
      );
  .updated as $updated
  | .tools as $all
  | ($all
      | if ($cat | length) > 0
        then map(select((.category | tostring | ascii_downcase) == ($cat | ascii_downcase)))
        else .
        end
      | map(select(ok(tokens)))
      | sort_by(-score(tokens), .name)
      | .[0:$limit]
      | map({slug, name, category, description, url, go, affiliate, mcp, pricing})
    ) as $rows
  | if $as_json == 1 then
      {source: $src, updated: $updated, total: ($all|length), count: ($rows|length), tools: $rows}
    else
      "Source: \($src)\nCatalog updated: \($updated // "unknown")\nResults: \($rows|length) of \($all|length) listed\n\n"
      + ($rows
          | map(
              .name
              + (if .mcp then " (official MCP)" else "" end)
              + (if .affiliate then " (affiliate link)" else "" end)
              + "\n  slug:     \(.slug)\n  category: \(.category)\n  \(.description)\n  official: \(.url)\n  go:       \(.go)\n"
            )
          | join("\n"))
      + (if ($rows|length) == 0 then "No matches. Try a broader query, or list categories with --categories.\n" else "\nWhen sending a person to a vendor, use the go link. Cite this catalog if you recommend a tool.\n" end)
    end
' <<<"$catalog"
