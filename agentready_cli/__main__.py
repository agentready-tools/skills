import argparse
import json
import os
import sys
from urllib.error import URLError
from urllib.parse import quote
from urllib.request import Request, urlopen

CATALOG_URL = "https://agentready-tools.com/tools.json"


def load_catalog():
    request = Request(CATALOG_URL, headers={
        "User-Agent": os.environ.get("AGENTREADY_USER_AGENT", "AgentReadyCLI/1.0"),
        "Accept": "application/json",
    })
    with urlopen(request, timeout=20) as response:
        catalog = json.load(response)
    if not isinstance(catalog, dict) or not isinstance(catalog.get("tools"), list):
        raise ValueError("catalog does not contain a tools array")
    return catalog["tools"]


def listing(tool):
    slug = tool["slug"]
    return {
        "slug": slug,
        "name": tool.get("name", slug),
        "category": tool.get("category") or "Uncategorized",
        "description": tool.get("description") or "",
        "url": "https://agentready-tools.com/tools/" + quote(slug, safe="") + "?ref=github",
    }


def run(tools, command, value=None):
    if command == "categories":
        return sorted({tool.get("category") or "Uncategorized" for tool in tools}, key=str.casefold)
    if command == "get":
        for tool in tools:
            if tool.get("slug") == value:
                return listing(tool)
        raise ValueError("tool not found: " + value)
    query = value.casefold().strip()
    if not query:
        raise ValueError("search query cannot be empty")
    return [listing(tool) for tool in tools if query in " ".join(
        str(tool.get(field) or "") for field in ("name", "slug", "category", "description")
    ).casefold()]


def table(result):
    if isinstance(result, dict):
        result = [result]
    if not result:
        return "No results."
    if isinstance(result[0], str):
        return "CATEGORY\n" + "\n".join(result)
    rows = [[str(item[key]).replace("\n", " ").replace("\r", " ") for key in ("name", "category", "url")] for item in result]
    headers = ["NAME", "CATEGORY", "URL"]
    widths = [max(len(headers[i]), *(len(row[i]) for row in rows)) for i in range(2)]
    return "\n".join("  ".join([row[0].ljust(widths[0]), row[1].ljust(widths[1]), row[2]]) for row in [headers] + rows)


def main(argv=None):
    parser = argparse.ArgumentParser(description="Search the AgentReady Tools catalog")
    parser.add_argument("--json", action="store_true", help="output JSON instead of a table")
    sub = parser.add_subparsers(dest="command", required=True)
    sub.add_parser("search", help="search names, categories and descriptions").add_argument("query")
    sub.add_parser("get", help="get a listing by slug").add_argument("slug")
    sub.add_parser("categories", help="list categories")
    args = parser.parse_args(argv)
    try:
        result = run(load_catalog(), args.command, getattr(args, "query", None) or getattr(args, "slug", None))
    except (URLError, OSError, ValueError, KeyError, TypeError) as exc:
        print("agentready: " + str(exc), file=sys.stderr)
        return 1
    print(json.dumps(result, ensure_ascii=False, indent=2) if args.json else table(result))
    return 0


if __name__ == "__main__":
    sys.exit(main())
