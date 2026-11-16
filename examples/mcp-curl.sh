#!/usr/bin/env bash
# AgentReady Tools: https://agentready-tools.com — MCP docs: https://agentready-tools.com/docs/mcp
set -euo pipefail
url=https://agentready-tools.com/mcp
ua='agentready-tools-examples/1.0 (+https://agentready-tools.com)'
tmp=$(mktemp -d)
trap 'rm -r "$tmp"' EXIT

curl -fsS --max-time 30 -A "$ua" -D "$tmp/headers" -o "$tmp/init" "$url" \
  -H 'Content-Type: application/json' -H 'Accept: application/json, text/event-stream' \
  --data '{"jsonrpc":"2.0","id":1,"method":"initialize","params":{"protocolVersion":"2025-03-26","capabilities":{},"clientInfo":{"name":"agentready-examples","version":"1.0"}}}'

parse_rpc() {
  # Parse JSON or SSE; keep the JSON-RPC message with the given id.
  python3 - "$1" "$2" <<'PY'
import json, sys
path, want_id = sys.argv[1], int(sys.argv[2])
text = open(path, encoding="utf-8").read()
messages = []
if "data:" in text:
    for line in text.splitlines():
        if line.startswith("data:"):
            payload = line[5:].lstrip()
            if payload and payload != "[DONE]":
                messages.append(json.loads(payload))
else:
    messages.append(json.loads(text))
message = next((m for m in messages if m.get("id") == want_id), None)
if message is None or "error" in message or "result" not in message:
    raise SystemExit(f"JSON-RPC id={want_id} failed: {messages or text}")
if message["result"].get("isError"):
    raise SystemExit(f"Tool call failed: {message}")
print(json.dumps(message["result"], indent=2))
PY
}

parse_rpc "$tmp/init" 1 >/dev/null

session=$(awk 'tolower($0) ~ /^mcp-session-id:/ {sub(/^[^:]*:[[:space:]]*/, ""); sub(/\r$/, ""); print; exit}' "$tmp/headers")
headers=(-H 'Content-Type: application/json' -H 'Accept: application/json, text/event-stream')
if [[ -n "$session" ]]; then headers+=(-H "mcp-session-id: $session"); fi

# Notification has no id. Some servers answer 200 or 202; curl -f accepts both.
curl -fsS --max-time 30 -A "$ua" "${headers[@]}" -o /dev/null "$url" \
  --data '{"jsonrpc":"2.0","method":"notifications/initialized"}'
curl -fsS --max-time 30 -A "$ua" "${headers[@]}" -o "$tmp/result" "$url" \
  --data '{"jsonrpc":"2.0","id":2,"method":"tools/call","params":{"name":"get_tool","arguments":{"slug":"sam-gov-opportunities"}}}'
# The useful payload is usually in result.content[].text and/or result.structuredContent.
parse_rpc "$tmp/result" 2
