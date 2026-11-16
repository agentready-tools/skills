# Claude directory submission

Ready for Moshe to submit at https://claude.ai/directory/manage. Nothing in this file has been submitted yet. Do not open a pull request on `anthropics/claude-plugins-official`; third-party listings go through the portal.

## Prerequisites

- A paid Claude plan (Moshe is on Pro as `mosheuzi@gmail.com`).
- For the plugin bundle: connect the GitHub account on claude.ai first, with push access to `agentready-tools/skills`. The repo is already public.
- Before you click submit on the MCP connector, add it as a custom connector and run every tool yourself (portal Test & launch step). Custom-connector link (not a directory listing):

  https://claude.ai/customize/connectors?modal=add-custom-connector&connectorName=AgentReady%20Tools&connectorUrl=https%3A%2F%2Fagentready-tools.com%2Fmcp

- Push the pending plugin updates (`.mcp.json`, `displayName`, `privacyPolicyUrl`, README catalog count) to `agentready-tools/skills` before you run Validate on the plugin bundle, so the portal sees the same files we already validated locally.
- Read the [directory policy](https://support.claude.com/en/articles/13145358-anthropic-software-directory-policy) and [terms](https://support.claude.com/en/articles/13145338-anthropic-software-directory-terms) before the seven acknowledgments.

Submit the MCP connector first, then the plugin bundle, and pair them if the portal offers that.

Docs: https://claude.com/docs/directory/publish · https://claude.com/docs/connectors/building/submission · https://claude.com/docs/plugins/submit

## A. MCP connector

**1. Connection**

- Server URL: `https://agentready-tools.com/mcp`
- Single public URL (not “users connect to different URLs”)

**2. Tools** (synced from the live server; all read-only, each has a `title` plus `readOnlyHint` / `destructiveHint`)

- `search_tools` — Search tools
- `get_tool` — Get tool
- `list_categories` — List categories
- `related_tools` — Related tools

**3. Listing**

- Server name: AgentReady Tools
- One-liner: Search a public catalog of APIs, scrapers, and official MCP servers that agents can actually call.
- Description:

  AgentReady Tools is a public catalog of APIs, scrapers, official MCP servers, and data sources we review for agent use. This connector is read-only. It can search the catalog, fetch one listing by its slug, list the categories, and show related listings. It does not call the vendor's own API for you.

  You do not need an account or an API key.

  When you send a person to a vendor page, use the catalog's /go/<slug> link. Some of those links are affiliate links; we disclose that on https://agentready-tools.com/directory. Listings of financial data APIs are data and tools only, not investment advice.

  The official MCP Registry name is com.agentready-tools/catalog. Docs: https://agentready-tools.com/docs/mcp

- Categories: pick 1–5 from the portal's own list (likely Developer Tools; do not invent names)
- Documentation URL: https://agentready-tools.com/docs/mcp
- Privacy policy URL: https://agentready-tools.com/privacy
- Support contact: mosheuzi+ar-plugins@gmail.com
- Icon: `assets/logo.png` in this repo
- URL slug: `agentready-tools` (permanent once published — confirm the portal still has it)

**4. Use cases**

- Primary: find an API, scraper, official MCP server, or data source for a task, or compare catalog listings.
- What users need first: nothing. No account, plan, or API key.
- Reads data only.

**5. Company**

- Company name: AgentReady Tools
- Website: https://agentready-tools.com
- Primary contact for review: mosheuzi+ar-plugins@gmail.com

**6. Authentication**

- No authentication (public catalog). Do not enter an OAuth client.

**7. Data handling**

- The underlying API is our own catalog, not a proxied third-party API.
- Does not handle personal health data.
- Some `/go/<slug>` destinations are affiliate links; already disclosed in the description and on the directory page.

**8. Test & launch**

- Confirm you called every tool as a custom connector or in MCP Inspector. Do not put credentials in the portal.

**9. Compliance**

- All seven acknowledgments in the portal are required. Read them before checking them.

## B. Plugin bundle

- GitHub repository: `agentready-tools/skills` (https://github.com/agentready-tools/skills)
- Plugin path: leave empty (the plugin is at the repo root)
- Branch: `main`
- Plugin name (immutable slug): `agentready-tools`
- Display name: AgentReady Tools

After the connector is in, pair this plugin with it if the portal has that option. Run Validate in the portal; local `claude plugin validate --profile directory --strict` does not cover every directory check.

## C. Already live, no portal

```text
/plugin marketplace add agentready-tools/skills
/plugin install agentready-tools@agentready-tools
```

This is our own Claude Code marketplace. It does not list the connector inside claude.ai or Claude Desktop.

Community lists such as ClaudePluginHub are not Anthropic's directory.
