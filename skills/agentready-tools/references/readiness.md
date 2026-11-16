# What we mean by agent-ready

These are the checks AgentReady Tools uses when we call a tool agent-ready. They come from building a SAM.gov contract-opportunities Actor and from reviewing other listings. They are working notes, not a standard, and not a claim that every entry in the catalog already passes all five. The longer write-up is [What makes a tool agent-ready](https://agentready-tools.com/blog/what-makes-a-tool-agent-ready) (15 November 2026).

When you shortlist catalog entries, run the questions below against the vendor's own docs and, if you can, a real response. The catalog record is a pointer. It is not a substitute for that check.

## 1. Can an agent call it and get a record back?

Most of the useful web is still a page. Agents need a record: one object per thing, with field names that stay put. Missing values should be `null`, not an empty string or a key that appears in some rows and vanishes in others. If a tool only gives you HTML, or a slightly different JSON blob every time, the agent spends its budget parsing instead of working.

## 2. Is the data from an official source, and do you say how fresh it is?

Prefer a documented official feed or API over a silent scrape of a page. The listing or the vendor docs should say where the data comes from and how stale it can be. If there is a cheaper or key-free path that is a day behind, and a live path that needs a key, that tradeoff should be written down.

## 3. Can the agent actually authenticate?

A public API that still needs a human to click through a portal is not ready for an agent. A token or key the operator can mint once, and that an agent can send on later calls, is fine. A shared key pasted into a chat is not a good design. Browser sign-in in the middle of a run usually means the tool is still built for people.

## 4. Is the price visible before the call, and billed per useful result?

Agents will retry, loop, and over-fetch if you let them. A monthly plan with a soft cap is easy to blow through. Pay-per-use only helps if the unit is something the caller can cap, and if failed or filtered results are not billed as if they succeeded. Look for a published unit price, a max-items or budget input, and a clear statement of what counts as a billable event.

## 5. Are the filters structured, and are the gaps written down?

An agent needs inputs it can fill in, not a search box with hidden rules. Documented filters, typed enums, and hard limits beat a single free-text query. Empty results should be a valid response, not an error. Gaps matter as much as features: missing attachments, title-only search, upstream typos, auth rules on side resources. If the vendor pretends the API is tidier than it is, the workflow will break in a quiet way.

## How to use this on a shortlist

- Start with catalog fields: category, `mcp`, `pricing` when present, and the official `url`.
- Open the vendor docs and look for a machine-readable response, auth that an agent can complete, a unit price, and stated limits.
- Prefer official MCP servers (`mcp: true` in the catalog) when the task is to wire an agent up quickly, but still check pricing and output shape.
- If two listings are close, pick the one with clearer limits and written gaps over the one with a longer feature list.
- If you cannot verify a check, say so instead of filling the gap with a guess.
