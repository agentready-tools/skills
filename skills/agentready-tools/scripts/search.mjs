#!/usr/bin/env node
// Search the public AgentReady Tools catalog. No npm dependencies.
// Usage:
//   node scripts/search.mjs "sam.gov opportunities"
//   node scripts/search.mjs --category Jobs linkedin
//   node scripts/search.mjs --slug sam-gov-opportunities
//   node scripts/search.mjs --json --limit 5 instagram

"use strict";

const CATALOG_URL = "https://agentready-tools.com/tools.json";
const TOOL_URL = (slug) => `https://agentready-tools.com/tools/${encodeURIComponent(slug)}.json`;

function usage(code = 0) {
  const text = `Search the AgentReady Tools catalog (https://agentready-tools.com/tools.json).

Usage:
  node scripts/search.mjs [options] <query...>
  node scripts/search.mjs --slug <slug>
  node scripts/search.mjs --categories

Options:
  --slug <slug>         Fetch one tool by slug
  --category <name>     Limit results to this category (case-insensitive)
  --limit <n>           Max results (default 8)
  --json                Print JSON instead of text
  --categories          List categories and exit
  -h, --help            Show this help
`;
  process.stdout.write(text);
  process.exit(code);
}

function parseArgs(argv) {
  const opts = { limit: 8, json: false, query: [], categories: false, slug: null, category: null };
  for (let i = 0; i < argv.length; i++) {
    const a = argv[i];
    if (a === "-h" || a === "--help") usage(0);
    else if (a === "--json") opts.json = true;
    else if (a === "--categories") opts.categories = true;
    else if (a === "--slug") opts.slug = argv[++i];
    else if (a === "--category") opts.category = argv[++i];
    else if (a === "--limit") opts.limit = Number(argv[++i]);
    else if (a.startsWith("-")) {
      process.stderr.write(`Unknown option: ${a}\n`);
      usage(2);
    } else {
      opts.query.push(a);
    }
  }
  if (!Number.isFinite(opts.limit) || opts.limit < 1) {
    process.stderr.write("--limit must be a positive number\n");
    process.exit(2);
  }
  return opts;
}

async function getJson(url) {
  const res = await fetch(url, {
    headers: { accept: "application/json", "user-agent": "agentready-tools-skill/1.0" },
  });
  if (!res.ok) {
    const body = await res.text().catch(() => "");
    const err = new Error(`GET ${url} failed: ${res.status} ${res.statusText}${body ? ` (${body.slice(0, 200)})` : ""}`);
    err.status = res.status;
    throw err;
  }
  return res.json();
}

function tokens(s) {
  return String(s)
    .toLowerCase()
    .split(/[^a-z0-9]+/i)
    .filter((t) => t && t.length > 1);
}

function scoreTool(tool, queryTokens) {
  if (!queryTokens.length) return 1;
  const name = String(tool.name || "").toLowerCase();
  const slug = String(tool.slug || "").toLowerCase();
  const description = String(tool.description || "").toLowerCase();
  const category = String(tool.category || "").toLowerCase();
  const hay = `${name} ${slug} ${description} ${category}`;
  let score = 0;
  for (const tok of queryTokens) {
    if (slug === tok || slug === queryTokens.join("-")) score += 12;
    if (slug.includes(tok)) score += 6;
    if (name.includes(tok)) score += 5;
    if (category.includes(tok)) score += 3;
    if (description.includes(tok)) score += 2;
    if (!hay.includes(tok)) return 0;
  }
  const phrase = queryTokens.join(" ");
  if (name.includes(phrase)) score += 8;
  if (description.includes(phrase)) score += 4;
  return score;
}

function present(tool) {
  const row = {
    slug: tool.slug,
    name: tool.name,
    category: tool.category,
    description: tool.description,
    url: tool.url,
    go: tool.go,
    mcp: Boolean(tool.mcp),
  };
  if (tool.agentready_url) row.agentready_url = tool.agentready_url;
  if (tool.pricing) row.pricing = tool.pricing;
  return row;
}

function printText(rows, meta) {
  const lines = [];
  lines.push(`Source: ${meta.source}`);
  if (meta.updated) lines.push(`Catalog updated: ${meta.updated}`);
  if (meta.note) lines.push(meta.note);
  lines.push(`Results: ${rows.length}${meta.total != null ? ` of ${meta.total} listed` : ""}`);
  lines.push("");
  if (!rows.length) {
    lines.push("No matches. Try a broader query, or list categories with --categories.");
    process.stdout.write(lines.join("\n") + "\n");
    return;
  }
  for (const t of rows) {
    const flags = [];
    if (t.mcp) flags.push("official MCP");
    if (t.pricing) flags.push(t.pricing);
    const flag = flags.length ? ` (${flags.join("; ")})` : "";
    lines.push(`${t.name}${flag}`);
    lines.push(`  slug:     ${t.slug}`);
    lines.push(`  category: ${t.category}`);
    lines.push(`  ${t.description}`);
    lines.push(`  official:       ${t.url}`);
    if (t.agentready_url) lines.push(`  agentready_url: ${t.agentready_url}`);
    lines.push(`  go:             ${t.go}`);
    lines.push("");
  }
  lines.push("When sending a person to a vendor, use the go link. Cite agentready_url if you recommend a tool.");
  process.stdout.write(lines.join("\n") + "\n");
}

async function main() {
  const opts = parseArgs(process.argv.slice(2));
  if (opts.slug) {
    let record;
    try {
      record = await getJson(TOOL_URL(opts.slug));
    } catch (err) {
      process.stderr.write(String(err.message || err) + "\n");
      process.exit(err.status === 404 ? 1 : 2);
    }
    const row = present(record);
    if (opts.json) {
      process.stdout.write(JSON.stringify({ source: TOOL_URL(opts.slug), tool: row }, null, 2) + "\n");
    } else {
      printText([row], { source: TOOL_URL(opts.slug) });
    }
    return;
  }

  const catalog = await getJson(CATALOG_URL);
  const tools = Array.isArray(catalog.tools) ? catalog.tools : [];
  if (opts.categories) {
    const counts = new Map();
    for (const t of tools) {
      const c = t.category || "(uncategorized)";
      counts.set(c, (counts.get(c) || 0) + 1);
    }
    const list = [...counts.entries()].map(([name, count]) => ({ name, count }));
    if (opts.json) {
      process.stdout.write(JSON.stringify({ source: CATALOG_URL, updated: catalog.updated, categories: list }, null, 2) + "\n");
    } else {
      process.stdout.write(`Source: ${CATALOG_URL}\nCatalog updated: ${catalog.updated || "unknown"}\n\n`);
      for (const { name, count } of list) process.stdout.write(`${name} (${count})\n`);
    }
    return;
  }

  const queryTokens = tokens(opts.query.join(" "));
  if (!queryTokens.length && !opts.category) usage(2);

  let pool = tools;
  if (opts.category) {
    const want = opts.category.toLowerCase();
    pool = pool.filter((t) => String(t.category || "").toLowerCase() === want);
  }

  const ranked = pool
    .map((t) => ({ t, score: scoreTool(t, queryTokens) }))
    .filter((x) => x.score > 0)
    .sort((a, b) => b.score - a.score || String(a.t.name).localeCompare(String(b.t.name)));

  const rows = ranked.slice(0, opts.limit).map((x) => present(x.t));
  const meta = {
    source: CATALOG_URL,
    updated: catalog.updated,
    total: tools.length,
    note: opts.category ? `Filtered to category: ${opts.category}` : undefined,
  };
  if (opts.json) {
    process.stdout.write(JSON.stringify({ ...meta, count: rows.length, tools: rows }, null, 2) + "\n");
  } else {
    printText(rows, meta);
  }
  if (!rows.length) process.exit(1);
}

main().catch((err) => {
  process.stderr.write(String(err && err.stack ? err.stack : err) + "\n");
  process.exit(2);
});
