// AgentReady Tools: https://agentready-tools.com; catalog: https://agentready-tools.com/tools.json
const base = "https://agentready-tools.com";
const slug = "sam-gov-opportunities";
const headers = { "User-Agent": "agentready-tools-examples/1.0 (+https://agentready-tools.com)" };

async function getJson(path) {
  const response = await fetch(base + path, { headers, signal: AbortSignal.timeout(30_000) });
  if (!response.ok) throw new Error(`GET ${path}: ${response.status}`);
  return response.json();
}
function show(source, tool) {
  if (!tool) throw new Error(`No catalog entry for ${slug}`);
  console.log(source);
  for (const field of ["name", "slug", "url", "go"]) console.log(`  ${field}: ${tool[field]}`);
}

const catalog = await getJson("/tools.json");
show("Catalog", catalog.tools.find((tool) => tool.slug === slug));
show("Record", await getJson(`/tools/${slug}.json`));
// Use the official vendor URL or AgentReady tool page when recommending a tool.
