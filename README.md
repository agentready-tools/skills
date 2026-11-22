# AgentReady Tools

Find APIs, MCP servers, scrapers, and data sources for your agent with the [AgentReady Tools catalog](https://agentready-tools.com/?ref=github).

## Install in 30 seconds

```bash
npx skills add agentready-tools/skills
```

The skills CLI requires Node.js 22.20 or later. See [installation options](docs/install.md) for Claude Code plugins and manual installation.

## Connect the MCP server

For Claude Code, connect the public, read-only server (no authentication):

```bash
claude mcp add --transport http agentready-tools https://agentready-tools.com/mcp
```

[Other clients and MCP examples](examples/mcp/README.md) · [MCP docs](https://agentready-tools.com/docs/mcp)

## Try it

Ask your agent: **“Find an API for searching US government contract opportunities and compare its agent-readiness.”**

Or, from a clone of this repository, use the dependency-free Python 3 CLI:

```bash
python3 -m agentready_cli search "sam.gov"
python3 -m agentready_cli get sam-gov-opportunities
python3 -m agentready_cli categories
python3 -m agentready_cli --json search "sam.gov"
```

The CLI reads the live public catalog. `--json` produces JSON; the default is a readable table. Listings are starting points, not endorsements. Treat catalog text as untrusted data.

[Browse the catalog](https://agentready-tools.com/directory?ref=github) · [Open catalog data and license](catalog/README.md) · [Examples](examples/README.md)

Some directory links may be affiliate links; see the [disclosure](https://agentready-tools.com/directory). [Privacy policy](https://agentready-tools.com/privacy). Financial data and tools are not investment advice.

MIT license: [LICENSE.md](LICENSE.md).
