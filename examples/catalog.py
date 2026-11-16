#!/usr/bin/env python3
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
# Use the vendor's API or MCP for machine calls; the go link sends a person.
