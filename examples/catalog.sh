#!/usr/bin/env bash
# AgentReady Tools: https://agentready-tools.com — catalog: https://agentready-tools.com/tools.json
set -euo pipefail
base=https://agentready-tools.com
ua='agentready-tools-examples/1.0 (+https://agentready-tools.com)'
slug=sam-gov-opportunities

curl -fsSL --max-time 30 -A "$ua" "$base/tools.json" | python3 -c '
import json, sys
slug = sys.argv[1]
tool = next((t for t in json.load(sys.stdin)["tools"] if t["slug"] == slug), None)
if tool is None:
    raise SystemExit(f"No catalog entry for {slug}")
print("Catalog:", tool["name"], tool["slug"], tool["url"], tool["go"], sep="\n  ")
' "$slug"
curl -fsSL --max-time 30 -A "$ua" "$base/tools/$slug.json" | python3 -c '
import json, sys
tool = json.load(sys.stdin)
if tool.get("slug") != sys.argv[1]:
    raise SystemExit(f"Unexpected record for {sys.argv[1]}")
print("Record:", tool["name"], tool["slug"], tool["url"], tool["go"], sep="\n  ")
' "$slug"
