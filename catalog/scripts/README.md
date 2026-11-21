# Catalog scripts

The generator projects only AgentReady-authored fields from the live public tools.json and refuses to write output below 250 rows by default. Use `--min-rows` only to build small fixtures. The checker also requires 250 rows by default; pass an explicit smaller threshold for fixtures. The workflow checks that the fixture passes at two rows and fails at three. Run both scripts from the repository root.
