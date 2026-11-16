# Catalog examples

These examples query [AgentReady Tools](https://agentready-tools.com). Run them from the repository root with network access:

```bash
bash examples/catalog.sh       # curl and Python 3
python3 examples/catalog.py    # Python 3 standard library
node examples/catalog.mjs      # Node.js 18+
bash examples/mcp-curl.sh      # curl and Python 3
```

The first three find a slug in [tools.json](https://agentready-tools.com/tools.json) and fetch its individual JSON record. See the [SAM.gov listing](https://agentready-tools.com/tools/sam-gov-opportunities) for the human-readable page. Use the `go` link when sending a person to a vendor; machine-to-machine calls should use the vendor's own API or MCP.

The last script initializes the [public MCP server](https://agentready-tools.com/mcp) and calls `get_tool`. See the [MCP docs](https://agentready-tools.com/docs/mcp) and [client configurations](mcp/README.md). [llms.txt](https://agentready-tools.com/llms.txt) describes other public surfaces. Source: [GitHub repository](https://github.com/agentready-tools/skills). These examples are covered by the repository's [MIT license](../LICENSE).
