# Claude Desktop

AgentReady Tools: https://agentready-tools.com · [MCP docs](https://agentready-tools.com/docs/mcp)

Add this server to Claude Desktop's `mcpServers` configuration if your version accepts a remote HTTP `url`. If it rejects that shape, add the same URL under Settings → Connectors.

```json
{
  "mcpServers": {
    "agentready-tools": {
      "url": "https://agentready-tools.com/mcp"
    }
  }
}
```
