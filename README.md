# AgentReady Tools skill

An [Agent Skill](https://agentskills.io/specification) that teaches an AI agent how to search the [AgentReady Tools](https://agentready-tools.com) catalog and pick an API, scraper, official MCP server, or data source for a task.

The catalog is public. As of 16 November 2026 it lists 173 tools in [tools.json](https://agentready-tools.com/tools.json). This repo is the skill, not the catalog itself. Some outbound `/go/<slug>` links on the site are affiliate links; the disclosure on [the directory](https://agentready-tools.com/directory) applies. Privacy policy: [https://agentready-tools.com/privacy](https://agentready-tools.com/privacy). Listings of financial data APIs are data and tools only, not investment advice.

## Install

With the [skills CLI](https://www.npmjs.com/package/skills) (Node.js 22.20 or later):

```bash
npx skills add agentready-tools/skills
```

That command is the usual path for Claude Code, Codex, Cursor, OpenCode, and the other agents the CLI supports. To install only this skill, pass `--skill agentready-tools`. Add `-g` to install it for your user account instead of the current project.

Claude Code can also load it as a plugin marketplace:

```text
/plugin marketplace add agentready-tools/skills
/plugin install agentready-tools@agentready-tools
```

Or copy `skills/agentready-tools` into the skills folder your agent already reads, for example `.agents/skills/agentready-tools` or `~/.claude/skills/agentready-tools`.

The skill needs network access to `https://agentready-tools.com`. The helper scripts need Node.js 18+ (`scripts/search.mjs`) or curl and jq (`scripts/search.sh`).

## What it does

Once it is installed, the agent should reach for this skill when you ask it to find an API, a scraper, an MCP server, or a data source. It will:

1. Query [tools.json](https://agentready-tools.com/tools.json) or the public MCP server at [https://agentready-tools.com/mcp](https://agentready-tools.com/mcp) (`search_tools`, `get_tool`, `list_categories`).
2. Compare listings on the checks in `skills/agentready-tools/references/readiness.md`: clean callable data, a source and freshness you can state, auth an agent can complete, pay-per-use pricing with a cap, and gaps written down.
3. Use `https://agentready-tools.com/go/<slug>` when it sends a person to a vendor page. That is how we measure the traffic a listing actually delivers. Machine-to-machine calls should still go to the vendor's own API or MCP server.

A listing in the catalog is a starting point, not a certificate that the vendor passes every check.

## Short demo

```bash
# From this repository, after a clone:
node skills/agentready-tools/scripts/search.mjs "sam.gov opportunities"
```

You should see the SAM.gov contract-opportunities listing, with its official URL and the tracked `go` link:

```text
Source: https://agentready-tools.com/tools.json
Catalog updated: 2026-11-15
Results: 1 of 173 listed

SAM.gov Contract Opportunities API — Federal RFPs & Bids
  slug:     sam-gov-opportunities
  category: Lead generation
  Export SAM.gov RFPs, solicitations, sources sought and award notices to JSON/CSV.
  official: https://apify.com/samgov-tools/samgov-opportunities
  go:       https://agentready-tools.com/go/sam-gov-opportunities
```

Same search through the public MCP server, no authentication:

```bash
# search_tools, after an MCP initialize handshake with
# https://agentready-tools.com/mcp
# returns the same slug, official url, and go link.
```

Registry name: `com.agentready-tools/catalog`. Server card: https://agentready-tools.com/mcp/server-card

## Layout

```text
skills/agentready-tools/
  SKILL.md                 # instructions the agent loads
  scripts/search.mjs       # Node helper, no npm dependencies
  scripts/search.sh        # curl + jq helper
  references/readiness.md  # the five agent-readiness checks
.claude-plugin/
  marketplace.json         # Claude Code plugin marketplace
  plugin.json
.mcp.json                  # Official Claude remote MCP pointer (https://agentready-tools.com/mcp)
```

## Tests

`tests/run.sh` hits the live catalog, the `/go/` redirect, the public MCP tools, and both helper scripts. It also checks the `SKILL.md` frontmatter against the Agent Skills naming rules.

## License

MIT. See [LICENSE](LICENSE).
