# Issue 249 research — 2026-11-22

- [Skills documentation](https://skills.sh/docs) shows `npx skills add owner/repo` as the install pattern. Keep the existing repository and skill paths intact.
- The [public catalog](https://agentready-tools.com/tools.json) was fetched live with the internal probe user agent. It is an object with a `tools` array; records include `slug`, `name`, `category`, and `description`. Generate links to catalog pages from slugs with `?ref=github` rather than copying the JSON channel's tracking parameters.
- The repository's [Claude Code MCP example](../examples/mcp/claude-code.md) documents the HTTP connection command. The public [MCP documentation](https://agentready-tools.com/docs/mcp) describes the server.
- Python's [unittest](https://docs.python.org/3/library/unittest.html) supports fixture-based tests without dependencies. A separate GitHub-hosted workflow can run them without changing the existing catalog refresh workflow.
- The existing [plugin allowlist](../docs/allowlist.md) excludes Python files from a directory submission. Keep marketplace and skill manifests intact, but the repository-wide allowlist check will need a packaging decision before submitting this repository to a directory with those restrictions.
