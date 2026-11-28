# Issue 249 evidence — 2026-11-22

## Tests

`python3 -m unittest discover -s tests -v`

```text
test_categories_and_table (test_cli.CliTest.test_categories_and_table) ... ok
test_cli_json_and_error (test_cli.CliTest.test_cli_json_and_error) ... ok
test_get_and_link (test_cli.CliTest.test_get_and_link) ... ok
test_reject_empty_query (test_cli.CliTest.test_reject_empty_query) ... ok
test_search_is_case_insensitive_and_uses_description (test_cli.CliTest.test_search_is_case_insensitive_and_uses_description) ... ok

----------------------------------------------------------------------
Ran 5 tests in 0.002s

OK
```

`node catalog/scripts/build-catalog.mjs --input catalog/fixtures/tools.json --output /tmp/issue249-catalog.json --csv /tmp/issue249-catalog.csv --min-rows 2 && node catalog/scripts/check-catalog.mjs /tmp/issue249-catalog.json 2`

```text
Wrote 2 listings to /tmp/issue249-catalog.json and /tmp/issue249-catalog.csv
Catalog validation passed: 2 rows, allowlisted AgentReady fields only
```

## Live CLI smoke test

`AGENTREADY_USER_AGENT=AgentReadyPipelineProbe/1.0 python3 -m agentready_cli search 'sam.gov'`

```text
NAME                                                      CATEGORY         URL
SAM.gov Contract Opportunities API — Federal RFPs & Bids  Lead generation  https://agentready-tools.com/tools/sam-gov-opportunities?ref=github
```

## README excerpt for PR

Before:

> An Agent Skill that teaches an AI agent how to search the AgentReady Tools catalog and pick an API, scraper, official MCP server, or data source for a task.

After:

> Find APIs, MCP servers, scrapers, and data sources for your agent with the AgentReady Tools catalog.
>
> Install: `npx skills add agentready-tools/skills`
