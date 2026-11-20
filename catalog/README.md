# Open catalog data

This directory contains generated JSON and CSV snapshots from the public AgentReady Tools catalog. The projection includes only the allowlisted fields documented in the repository README. It omits vendor descriptions, vendor URLs, pricing text, tracked links, affiliate data, and internal metrics.

The generator reads https://agentready-tools.com/tools.json. The daily GitHub Actions workflow validates the live result and commits changed snapshots directly to the default branch with GITHUB_TOKEN.

See [LICENSE-DATA](LICENSE-DATA) for the data license and attribution.
