#!/usr/bin/env node
import { readFile } from "node:fs/promises";

const path = process.argv[2] || "catalog/catalog.json";
const minRows = Number(process.argv[3] || 1);
const catalogKeys = ["data_license", "name", "source", "source_count", "source_updated", "tools"];
const toolKeys = ["agent_readiness_checks", "agentready_url", "category", "mcp", "name", "openapi", "slug"];
const checkIds = ["agent_controls", "auth_type", "liveness", "machine_readable", "pay_per_use", "tool_annotations"];
const keys = (value) => Object.keys(value).sort();
function assert(condition, message) {
  if (!condition) throw new Error(message);
}

try {
  const catalog = JSON.parse(await readFile(path, "utf8"));
  assert(keys(catalog).join("\0") === catalogKeys.join("\0"), "Unexpected catalog-level field");
  assert(catalog.data_license === "CC-BY-4.0", "Unexpected data license");
  assert(catalog.source === "https://agentready-tools.com/tools.json", "Unexpected source URL");
  assert(Array.isArray(catalog.tools) && catalog.tools.length >= minRows, `Expected at least ${minRows} rows`);
  assert(catalog.source_count === catalog.tools.length, "source_count does not match generated row count");
  const slugs = new Set();
  for (const tool of catalog.tools) {
    assert(keys(tool).join("\0") === toolKeys.join("\0"), `Unexpected field on ${tool.slug || "tool"}`);
    assert(/^[a-z0-9]+(?:-[a-z0-9]+)*$/.test(tool.slug), `Invalid slug: ${tool.slug}`);
    assert(!slugs.has(tool.slug), `Duplicate slug: ${tool.slug}`);
    slugs.add(tool.slug);
    assert(typeof tool.name === "string" && tool.name.trim(), `Missing name on ${tool.slug}`);
    assert(typeof tool.category === "string" && tool.category.trim(), `Missing category on ${tool.slug}`);
    assert(typeof tool.mcp === "boolean", `Missing MCP flag on ${tool.slug}`);
    assert(tool.openapi === null || typeof tool.openapi === "boolean", `Invalid OpenAPI flag on ${tool.slug}`);
    assert(tool.agentready_url === `https://agentready-tools.com/tools/${tool.slug}?ref=github`, `Invalid AgentReady URL on ${tool.slug}`);
    assert(keys(tool.agent_readiness_checks).join("\0") === checkIds.join("\0"), `Unexpected checks on ${tool.slug}`);
    for (const [id, value] of Object.entries(tool.agent_readiness_checks)) {
      assert(["yes", "no", "unknown"].includes(value), `Invalid ${id} value on ${tool.slug}`);
    }
  }
  console.log(`Catalog validation passed: ${catalog.tools.length} rows, allowlisted AgentReady fields only`);
} catch (error) {
  console.error(`Catalog validation failed: ${error.message}`);
  process.exitCode = 1;
}
