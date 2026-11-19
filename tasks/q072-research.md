# Q072 research — 2026-11-19

The task reports that the Claude directory rejects executables and SVGs from this unverified organization; the requested remedy is an allow-listed package. The existing repository examples use the public catalog and MCP. On 2026-11-19, live requests using `AgentReadyPipelineProbe/1.0` returned HTTP 200 for [search with q=sam.gov](https://agentready-tools.com/api/search?q=sam.gov), [tools.json](https://agentready-tools.com/tools.json), and an MCP `initialize` POST to [the public MCP](https://agentready-tools.com/mcp). Search returned matching catalog entries; MCP returned a JSON-RPC initialize result. The [MCP documentation](https://agentready-tools.com/docs/mcp) describes the service.

The local `origin/main` contains changes absent from the task branch, including search-first guidance and a skill-local icon. Preserve those changes while preparing the patch. The branch cannot be advanced in this sandbox: `git rebase origin/main` fails because the worktree Git metadata is read-only. The runner must rebase or recreate the branch before committing.

Check: endpoint behavior tested live. Independent Claude review remains for the runner. Development is authorized now by the task's explicit small-change instruction.
