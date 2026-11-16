# Claude Code

AgentReady Tools: https://agentready-tools.com · [MCP docs](https://agentready-tools.com/docs/mcp)

Add the Streamable HTTP server:

```bash
claude mcp add --transport http agentready-tools https://agentready-tools.com/mcp
```

Or add the following to a project `.mcp.json`, merging with existing servers if needed:

```json
{
  "mcpServers": {
    "agentready-tools": {
      "url": "https://agentready-tools.com/mcp"
    }
  }
}
```
