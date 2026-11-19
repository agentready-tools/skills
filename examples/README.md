# Catalog examples

These snippets query the live [catalog](https://agentready-tools.com/tools.json). Run them with network access. Use a vendor's own API or MCP for machine calls.

## Search and fetch records

```bash
curl -fsS 'https://agentready-tools.com/api/search?q=sam.gov'
curl -fsS 'https://agentready-tools.com/tools.json'
curl -fsS 'https://agentready-tools.com/tools/sam-gov-opportunities.json'
```

Python 3 standard library:

```python
"""AgentReady Tools: https://agentready-tools.com; catalog: https://agentready-tools.com/tools.json."""
import json
from urllib.request import Request, urlopen

BASE = "https://agentready-tools.com"
SLUG = "sam-gov-opportunities"
HEADERS = {"User-Agent": "agentready-tools-examples/1.0 (+https://agentready-tools.com)"}


def get_json(path):
    with urlopen(Request(BASE + path, headers=HEADERS), timeout=30) as response:
        return json.load(response)


def show(source, tool):
    print(source)
    for field in ("name", "slug", "url", "go"):
        print(f"  {field}: {tool[field]}")


catalog = get_json("/tools.json")
entry = next((tool for tool in catalog["tools"] if tool["slug"] == SLUG), None)
if entry is None:
    raise SystemExit(f"No catalog entry for {SLUG}")
show("Catalog", entry)
show("Record", get_json(f"/tools/{SLUG}.json"))
# Use the official vendor URL or AgentReady tool page when recommending a tool.
```

Node.js 18+:

```javascript
// AgentReady Tools: https://agentready-tools.com; catalog: https://agentready-tools.com/tools.json
const base = "https://agentready-tools.com";
const slug = "sam-gov-opportunities";
const headers = { "User-Agent": "agentready-tools-examples/1.0 (+https://agentready-tools.com)" };

async function getJson(path) {
  const response = await fetch(base + path, { headers, signal: AbortSignal.timeout(30_000) });
  if (!response.ok) throw new Error(`GET ${path}: ${response.status}`);
  return response.json();
}
function show(source, tool) {
  if (!tool) throw new Error(`No catalog entry for ${slug}`);
  console.log(source);
  for (const field of ["name", "slug", "url", "go"]) console.log(`  ${field}: ${tool[field]}`);
}

const catalog = await getJson("/tools.json");
show("Catalog", catalog.tools.find((tool) => tool.slug === slug));
show("Record", await getJson(`/tools/${slug}.json`));
// Use the official vendor URL or AgentReady tool page when recommending a tool.
```

## Public MCP

The following initializes the public MCP and calls `search_tools`. The server supports stateless requests; a general-purpose MCP client should follow the [MCP documentation](https://agentready-tools.com/docs/mcp) for session handling. Responses may use server-sent events.

```bash
curl -fsS 'https://agentready-tools.com/mcp' \
  -H 'Content-Type: application/json' -H 'Accept: application/json, text/event-stream' \
  --data '{"jsonrpc":"2.0","id":1,"method":"initialize","params":{"protocolVersion":"2025-03-26","capabilities":{},"clientInfo":{"name":"agentready-examples","version":"1.0"}}}'
curl -fsS 'https://agentready-tools.com/mcp' \
  -H 'Content-Type: application/json' -H 'Accept: application/json, text/event-stream' \
  --data '{"jsonrpc":"2.0","id":2,"method":"tools/call","params":{"name":"search_tools","arguments":{"query":"sam.gov"}}}'
```

See [client configurations](mcp/README.md) and the [MIT license](../LICENSE.md).
