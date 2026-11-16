#!/usr/bin/env bash
# Live checks for the AgentReady Tools skill against production endpoints.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
SCRIPT="$ROOT/skills/agentready-tools/scripts/search.mjs"
SHELL_SCRIPT="$ROOT/skills/agentready-tools/scripts/search.sh"
FAIL=0
pass() { echo "PASS  $*"; }
fail() { echo "FAIL  $*" >&2; FAIL=$((FAIL+1)); }

echo "== HTTP endpoints =="
check_http() {
  local url="$1" expect="${2:-200}" typ="${3:-}"
  local hdr status ctype
  hdr="$(mktemp)"
  status="$(curl -sS -o /dev/null -D "$hdr" -w '%{http_code}' -A 'agentready-tools-skill-test/1.0' "$url" || true)"
  ctype="$(tr -d '\r' <"$hdr" | awk -F': ' 'tolower($1)=="content-type"{print $2}')"
  rm -f "$hdr"
  if [[ "$status" != "$expect" ]]; then
    fail "$url status $status (expected $expect)"
    return
  fi
  if [[ -n "$typ" && "$ctype" != *"$typ"* ]]; then
    fail "$url content-type $ctype (expected $typ)"
    return
  fi
  pass "$url  $status  $ctype"
}

check_http "https://agentready-tools.com/llms.txt" 200 "text/markdown"
check_http "https://agentready-tools.com/llms-full.txt" 200 "text/markdown"
check_http "https://agentready-tools.com/tools.json" 200 "application/json"
check_http "https://agentready-tools.com/tools/sam-gov-opportunities.json" 200 "json"
check_http "https://agentready-tools.com/index.md" 200 "text/markdown"
check_http "https://agentready-tools.com/directory.md" 200 "text/markdown"
check_http "https://agentready-tools.com/about.md" 200 "text/markdown"
check_http "https://agentready-tools.com/mcp/server-card" 200 "json"
check_http "https://agentready-tools.com/.well-known/ai-catalog.json" 200 "json"

loc="$(curl -sSI -A 'agentready-tools-skill-test/1.0' https://agentready-tools.com/go/sam-gov-opportunities | tr -d '\r' | awk 'tolower($1)=="location:"{print $2}')"
if [[ "$loc" == https://apify.com/samgov-tools/samgov-opportunities ]]; then
  pass "/go/sam-gov-opportunities -> $loc"
else
  fail "/go/sam-gov-opportunities redirect was '$loc'"
fi

python3 - <<'PY'
import json, urllib.request, sys
raw = urllib.request.urlopen("https://agentready-tools.com/tools.json").read()
d = json.loads(raw)
tools = d.get("tools") or []
assert isinstance(tools, list) and len(tools) >= 1, "empty catalog"
required = {"slug","name","category","description","url","go","affiliate","mcp"}
missing = [t.get("slug") for t in tools if not required.issubset(t)]
if missing:
    raise SystemExit(f"tools missing fields: {missing[:5]}")
bad_go = [t["slug"] for t in tools if t.get("go") != f"https://agentready-tools.com/go/{t['slug']}"]
if bad_go:
    raise SystemExit(f"go URL mismatch: {bad_go[:5]}")
print(f"PASS  tools.json  {len(tools)} tools, updated {d.get('updated')}")
PY

echo
echo "== MCP tools =="
python3 - <<'PY'
import json, urllib.request, urllib.error, sys

url = "https://agentready-tools.com/mcp"

def post(payload, session=None):
    data = json.dumps(payload).encode()
    headers = {
        "Content-Type": "application/json",
        "Accept": "application/json, text/event-stream",
        "MCP-Protocol-Version": "2025-03-26",
        "User-Agent": "agentready-tools-skill-test/1.0",
    }
    if session:
        headers["Mcp-Session-Id"] = session
    req = urllib.request.Request(url, data=data, headers=headers, method="POST")
    with urllib.request.urlopen(req, timeout=30) as resp:
        raw = resp.read()
        ctype = resp.headers.get("Content-Type", "")
        session_id = resp.headers.get("Mcp-Session-Id")
        return resp.status, dict(resp.headers), ctype, raw, session_id

def parse(ctype, raw):
    text = raw.decode("utf-8", "replace")
    if "text/event-stream" in ctype:
        for line in reversed(text.splitlines()):
            if line.startswith("data:"):
                return json.loads(line[5:].strip())
        raise SystemExit("no SSE data")
    return json.loads(text)

status, hdrs, ctype, raw, session = post({
    "jsonrpc": "2.0",
    "id": 1,
    "method": "initialize",
    "params": {
        "protocolVersion": "2025-03-26",
        "capabilities": {},
        "clientInfo": {"name": "agentready-tools-skill-test", "version": "1.0.0"},
    },
})
body = parse(ctype, raw)
assert status == 200, status
assert "result" in body, body
print("PASS  MCP initialize")

post({"jsonrpc": "2.0", "method": "notifications/initialized"}, session=session)

def call(i, name, arguments):
    st, _, ct, raw, _ = post({
        "jsonrpc": "2.0",
        "id": i,
        "method": "tools/call",
        "params": {"name": name, "arguments": arguments},
    }, session=session)
    parsed = parse(ct, raw)
    if st != 200 or "error" in parsed:
        raise SystemExit(f"{name} failed: {st} {parsed}")
    text = parsed["result"]["content"][0]["text"]
    return json.loads(text)

cats = call(3, "list_categories", {})
assert cats.get("count") and "Lead generation" in cats.get("categories", []), cats
print(f"PASS  MCP list_categories  {cats['count']} categories")

found = call(4, "search_tools", {"query": "sam.gov"})
slugs = [t["slug"] for t in found.get("tools", [])]
assert "sam-gov-opportunities" in slugs, found
assert found["tools"][0]["go"].endswith("/go/sam-gov-opportunities"), found
print(f"PASS  MCP search_tools sam.gov  count={found['count']}")

jobs = call(5, "search_tools", {"query": "linkedin", "category": "Jobs"})
assert all(t["category"] == "Jobs" for t in jobs.get("tools", [])), jobs
print(f"PASS  MCP search_tools linkedin category=Jobs  count={jobs['count']}")

one = call(6, "get_tool", {"slug": "sam-gov-opportunities"})
assert one["tool"]["slug"] == "sam-gov-opportunities", one
print("PASS  MCP get_tool sam-gov-opportunities")
PY

echo
echo "== helper scripts =="
out="$(node "$SCRIPT" --slug sam-gov-opportunities)"
echo "$out" | grep -q 'sam-gov-opportunities' && pass "search.mjs --slug" || fail "search.mjs --slug"
echo "$out" | grep -q 'https://agentready-tools.com/go/sam-gov-opportunities' && pass "search.mjs prints go link" || fail "search.mjs go link"

json="$(node "$SCRIPT" --json "sam.gov opportunities")"
echo "$json" | python3 -c 'import json,sys; d=json.load(sys.stdin); assert d["tools"][0]["slug"]=="sam-gov-opportunities", d; print("PASS  search.mjs query sam.gov opportunities")'

json="$(node "$SCRIPT" --json --category Jobs linkedin)"
echo "$json" | python3 -c 'import json,sys; d=json.load(sys.stdin); assert d["tools"] and all(t["category"]=="Jobs" for t in d["tools"]), d; print("PASS  search.mjs --category Jobs linkedin  count", d["count"])'

node "$SCRIPT" --json --categories | python3 -c 'import json,sys; d=json.load(sys.stdin); assert len(d["categories"])>=10, d; print("PASS  search.mjs --categories", len(d["categories"]))'

if node "$SCRIPT" --json --slug definitely-not-a-tool >/tmp/skill-missing.json 2>/tmp/skill-missing.err; then
  fail "search.mjs missing slug should exit non-zero"
else
  pass "search.mjs missing slug exits non-zero"
fi

chmod +x "$SHELL_SCRIPT"
sh_out="$("$SHELL_SCRIPT" --slug sam-gov-opportunities)"
echo "$sh_out" | grep -q 'sam-gov-opportunities' && pass "search.sh --slug" || fail "search.sh --slug: $sh_out"

sh_json="$("$SHELL_SCRIPT" --json "sam.gov")"
echo "$sh_json" | python3 -c 'import json,sys; d=json.load(sys.stdin); slugs=[t["slug"] for t in d["tools"]]; assert "sam-gov-opportunities" in slugs, d; print("PASS  search.sh query sam.gov")' || fail "search.sh query"

echo
echo "== SKILL.md frontmatter =="
python3 - <<PY
from pathlib import Path
import re, sys
p = Path("$ROOT/skills/agentready-tools/SKILL.md")
text = p.read_text()
if not text.startswith("---\n"):
    raise SystemExit("missing frontmatter")
end = text.find("\n---\n", 4)
if end < 0:
    raise SystemExit("unterminated frontmatter")
fm = text[4:end]
# very small YAML-ish extract for required fields
def get(key):
    lines = fm.splitlines()
    for i, line in enumerate(lines):
        if line.startswith(key + ":"):
            rest = line[len(key)+1:].strip()
            if rest in (">", "|", ">-", "|-"):
                block = []
                for nxt in lines[i+1:]:
                    if nxt.startswith(" ") or nxt.startswith("\t"):
                        block.append(nxt.strip())
                    elif nxt.strip() == "":
                        block.append("")
                    else:
                        break
                return " ".join(x for x in block if x)
            return rest.strip().strip('"')
    return None
name = get("name")
desc = get("description")
if name != "agentready-tools":
    raise SystemExit(f"name is {name!r}")
if not desc:
    raise SystemExit("empty description")
if len(name) > 64 or not re.fullmatch(r"[a-z0-9]+(?:-[a-z0-9]+)*", name):
    raise SystemExit(f"bad name: {name}")
if len(desc) > 1024:
    raise SystemExit(f"description too long: {len(desc)}")
body_lines = text[end+5:].splitlines()
if len(body_lines) > 500:
    raise SystemExit(f"body too long: {len(body_lines)} lines")
print(f"PASS  SKILL.md  name={name} description={len(desc)} chars body={len(body_lines)} lines")
PY

if [[ "$FAIL" -ne 0 ]]; then
  echo
  echo "FAILED $FAIL check(s)"
  exit 1
fi
echo
echo "All checks passed."
