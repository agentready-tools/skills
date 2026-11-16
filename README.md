# AgentReady Tools skill

An [Agent Skill](https://agentskills.io/specification) that teaches an AI agent how to search the [AgentReady Tools](https://agentready-tools.com) catalog and pick an API, scraper, official MCP server, or data source for a task.

The catalog is public. It lists more than 250 agent-ready tools in [tools.json](https://agentready-tools.com/tools.json). This repo is the skill, not the catalog itself. Some outbound `/go/<slug>` links on the site are affiliate links; the disclosure on [the directory](https://agentready-tools.com/directory) applies. Privacy policy: [https://agentready-tools.com/privacy](https://agentready-tools.com/privacy). Listings of financial data APIs are data and tools only, not investment advice.

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
Results: 1

SAM.gov Contract Opportunities API — Federal RFPs & Bids
  slug:     sam-gov-opportunities
  category: Lead generation
  Export SAM.gov RFPs, solicitations, sources sought and award notices to JSON/CSV.
  official: https://apify.com/samgov-tools/samgov-opportunities
  go:       https://agentready-tools.com/go/sam-gov-opportunities
```

The same listing is available through the public MCP server, with no authentication. A runnable handshake is in [examples/mcp-curl.sh](examples/mcp-curl.sh):

```bash
bash examples/mcp-curl.sh
```

Registry name: `com.agentready-tools/catalog`. Server card: https://agentready-tools.com/mcp/server-card

## Examples

The [examples](examples/) folder has short, runnable snippets that query the live catalog and the public MCP server. From the repository root:

```bash
bash examples/catalog.sh
python3 examples/catalog.py
node examples/catalog.mjs
bash examples/mcp-curl.sh
```

MCP client configs for Claude Desktop, Cursor, and Claude Code are in [examples/mcp](examples/mcp/).

## Layout

```text
skills/agentready-tools/
  SKILL.md                 # instructions the agent loads
  scripts/search.mjs       # Node helper, no npm dependencies
  scripts/search.sh        # curl + jq helper
  references/readiness.md  # the five agent-readiness checks
examples/                  # curl, Python, Node, and MCP client snippets
.claude-plugin/
  marketplace.json         # Claude Code plugin marketplace
  plugin.json
.mcp.json                  # Official Claude remote MCP pointer (https://agentready-tools.com/mcp)
```

## Tests

A live-catalog smoke test (HTTP endpoints, `/go/` redirects, public MCP tools, helper scripts, and `SKILL.md` frontmatter) is maintained outside this repository so the published plugin bundle stays limited to the skill, manifests, and `assets/logo.svg`.


## Where to find us

- Website: [agentready-tools.com](https://agentready-tools.com)
- Catalog: [tools.json](https://agentready-tools.com/tools.json) · [llms.txt](https://agentready-tools.com/llms.txt)
- Public MCP server: [https://agentready-tools.com/mcp](https://agentready-tools.com/mcp) ([docs](https://agentready-tools.com/docs/mcp), [server card](https://agentready-tools.com/mcp/server-card))
- Official MCP Registry: [`com.agentready-tools/catalog`](https://registry.modelcontextprotocol.io/?q=com.agentready-tools/catalog)
- Glama: [AgentReady Tools connector](https://glama.ai/mcp/connectors/com.agentready-tools/catalog)
  [![Glama score](https://glama.ai/mcp/connectors/com.agentready-tools/catalog/badges/score.svg)](https://glama.ai/mcp/connectors/com.agentready-tools/catalog)
- Apify Store, under [`samgov-tools`](https://apify.com/samgov-tools): [SAM.gov Contract Opportunities](https://apify.com/samgov-tools/samgov-opportunities), [Website Screenshot](https://apify.com/samgov-tools/url-screenshot), [ATS Jobs](https://apify.com/samgov-tools/ats-jobs), [USAspending Awards](https://apify.com/samgov-tools/usaspending-awards), [Agent Payment Checker](https://apify.com/samgov-tools/agentpay-checker), [Agent Wallet Spend Report](https://apify.com/samgov-tools/agent-spend)
- GitHub: [agentready-tools](https://github.com/agentready-tools) (this skill: [agentready-tools/skills](https://github.com/agentready-tools/skills))
- X: [@AgentReadyTools](https://x.com/AgentReadyTools)
- Reddit: [u/AgentReadyTools](https://www.reddit.com/user/AgentReadyTools)
- dev.to: [agentreadytools](https://dev.to/agentreadytools)
- Substack: [agentreadytools.substack.com](https://agentreadytools.substack.com)

The Claude Code install commands are in [Install](#install) above.

### Not listed yet

<!-- UPDATE-WHEN-LIVE: claude-directory
     Replace the line below with a markdown link to the official Anthropic / Claude plugin directory listing once it is public. Do not link a guessed URL. -->
- Claude plugin directory: under review. We'll add the official listing link here once it's public.

<!-- UPDATE-WHEN-LIVE: chatgpt-directory
     Replace the line below with a markdown link to the official ChatGPT / OpenAI apps or plugin directory listing once it is submitted and approved. Do not link a guessed URL. -->
- ChatGPT apps / plugin directory: not submitted yet (waiting on identity verification). The listing link goes here when it exists.

<!-- UPDATE-WHEN-LIVE: awesome-claude-skills
     If https://github.com/karanb192/awesome-claude-skills/pull/723 is merged, replace this with a link to the merged list entry. -->
- [awesome-claude-skills](https://github.com/karanb192/awesome-claude-skills/pull/723): pull request is open, not in the list yet.

## License

MIT. See [LICENSE](LICENSE).
