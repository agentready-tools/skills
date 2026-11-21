#!/usr/bin/env node
import { readFile, writeFile } from "node:fs/promises";

const SOURCE_URL = "https://agentready-tools.com/tools.json";
const SITE = "https://agentready-tools.com";
const CHECK_IDS = [
  "machine_readable",
  "auth_type",
  "pay_per_use",
  "agent_controls",
  "tool_annotations",
  "liveness",
];

function argValue(args, flag) {
  const index = args.indexOf(flag);
  if (index < 0) return undefined;
  const value = args[index + 1];
  if (!value || value.startsWith("--")) throw new Error(flag + " requires a value");
  return value;
}

function project(source, minRows) {
  if (!source || typeof source !== "object" || !Array.isArray(source.tools) || source.tools.length === 0) {
    throw new Error("Source must be a JSON object with a non-empty tools array");
  }
  if (source.tools.length < minRows) {
    throw new Error("Expected at least " + minRows + " tools, received " + source.tools.length);
  }

  const seen = new Set();
  const tools = source.tools.map((item) => {
    if (!item || typeof item !== "object" || Array.isArray(item)) throw new Error("Every tool must be an object");
    const { slug, name, category, mcp } = item;
    if (typeof slug !== "string" || !/^[a-z0-9]+(?:-[a-z0-9]+)*$/.test(slug)) throw new Error("Invalid slug: " + slug);
    if (seen.has(slug)) throw new Error("Duplicate slug: " + slug);
    seen.add(slug);
    if (typeof name !== "string" || !name.trim()) throw new Error("Missing name on " + slug);
    if (typeof category !== "string" || !category.trim()) throw new Error("Missing category on " + slug);
    if (typeof mcp !== "boolean") throw new Error("Missing MCP flag on " + slug);

    const checks = item.ratings?.agent_readiness?.checks;
    if (!Array.isArray(checks)) throw new Error("Missing AgentReady readiness checks on " + slug);
    const readiness = {};
    for (const id of CHECK_IDS) {
      const check = checks.find((entry) => entry?.id === id);
      if (!check || !["yes", "no", "unknown"].includes(check.value)) {
        throw new Error("Missing or invalid " + id + " check on " + slug);
      }
      readiness[id] = check.value;
    }

    return {
      slug,
      name: name.trim(),
      category: category.trim(),
      agent_readiness_checks: readiness,
      mcp,
      // The public source has no separate OpenAPI flag. Do not infer one from MCP or prose.
      openapi: typeof item.openapi === "boolean" ? item.openapi : null,
      agentready_url: SITE + "/tools/" + slug + "?ref=github",
    };
  }).sort((a, b) => a.slug.localeCompare(b.slug));

  return {
    name: "AgentReady Tools open catalog",
    source: SOURCE_URL,
    source_updated: typeof source.updated === "string" ? source.updated : null,
    source_count: tools.length,
    data_license: "CC-BY-4.0",
    tools,
  };
}

function toCsv(tools) {
  const columns = ["slug", "name", "category", "agent_readiness_checks", "mcp", "openapi", "agentready_url"];
  const cell = (value) => "\"" + String(typeof value === "object" && value !== null ? JSON.stringify(value) : value).replaceAll('"', '""') + "\"";
  return [columns.join(","), ...tools.map((tool) => columns.map((key) => cell(tool[key])).join(","))].join("\n") + "\n";
}

async function main() {
  const args = process.argv.slice(2);
  const inputPath = argValue(args, "--input");
  const outputPath = argValue(args, "--output") || "catalog/catalog.json";
  const csvPath = argValue(args, "--csv") || "catalog/catalog.csv";
  const minRows = Number(argValue(args, "--min-rows") ?? 250);
  if (!Number.isInteger(minRows) || minRows < 1) throw new Error("--min-rows must be a positive integer");
  const response = inputPath ? null : await fetch(SOURCE_URL, { headers: { accept: "application/json" } });
  if (response && !response.ok) throw new Error("Source returned HTTP " + response.status);
  const text = inputPath ? await readFile(inputPath, "utf8") : await response.text();
  let source;
  try {
    source = JSON.parse(text);
  } catch {
    throw new Error("Source did not return valid JSON");
  }
  const catalog = project(source, minRows);
  await writeFile(outputPath, JSON.stringify(catalog, null, 2) + "\n");
  await writeFile(csvPath, toCsv(catalog.tools));
  console.log("Wrote " + catalog.tools.length + " listings to " + outputPath + " and " + csvPath);
}

main().catch((error) => {
  console.error("Catalog generation failed: " + error.message);
  process.exitCode = 1;
});
