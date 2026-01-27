import { digikeyAvailable, digikeyKeywordSearch } from "./digikeyApi.js";
import { octopartAvailable, octopartSearch } from "./octopartApi.js";
import { mockParts } from "./mockData.js";
import { mouserAvailable, mouserSearch } from "./mouserApi.js";
import { getCachedResults, setCachedResults } from "./cache.js";
import { buildKeywordQuery } from "./queryBuilder.js";
import { Provider, PartResult, PartSearchInput, SearchOutcome } from "./types.js";
import { webSearch, webSearchAvailable } from "./webSearchProvider.js";
import { rerankWithLLM, llmRankerAvailable } from "./llmRanker.js";
import { enrichResults } from "./enrich.js";

const preferMock = () => process.env.USE_MOCK === "1";

const validProviders: Provider[] = ["web", "mouser", "octopart", "digikey", "mock"];

const tokensFromInput = (input: PartSearchInput): string[] =>
  [
    input.partNumber,
    input.manufacturer,
    input.category,
    input.value,
    input.package,
    input.voltage,
    input.current,
    ...(input.keywords || []),
    ...(input.features || []),
  ]
    .filter(Boolean)
    .map((t) => t!.toLowerCase());

const resolveProviders = (requested?: Provider[]): Provider[] => {
  const disableOctopart = process.env.DISABLE_OCTOPART === "1";
  const list = (requested && requested.length ? requested : null) || [];
  const unique = (arr: Provider[]) =>
    Array.from(new Set(arr.filter((p) => validProviders.includes(p))));

  if (list.length) return unique(list);

  // default order (web first) honoring availability and mock preference
  const order: Provider[] = [];
  if (webSearchAvailable && !preferMock()) order.push("web");
  if (mouserAvailable && !preferMock()) order.push("mouser");
  if (octopartAvailable && !preferMock() && !disableOctopart) order.push("octopart");
  if (digikeyAvailable && !preferMock()) order.push("digikey");
  if (preferMock() || order.length === 0) order.push("mock");
  return order;
};

const mergePart = (base: PartResult, incoming: PartResult): PartResult => {
  const merged: PartResult = { ...base };
  const fill = <K extends keyof PartResult>(key: K) => {
    if (merged[key] === undefined || merged[key] === null || merged[key] === "") {
      merged[key] = incoming[key];
    }
  };
  fill("manufacturer");
  fill("manufacturerPartNumber");
  fill("digiKeyPartNumber");
  fill("description");
  fill("stock");
  fill("unitPrice");
  fill("url");
  merged.attributes = { ...(base.attributes || {}), ...(incoming.attributes || {}) };
  merged.provider = merged.provider || incoming.provider;
  return merged;
};

const dedupeResults = (items: PartResult[]): PartResult[] => {
  const byKey = new Map<string, PartResult>();
  for (const item of items) {
    const mpn = item.manufacturerPartNumber?.toLowerCase().replace(/\s+/g, "").trim();
    const url = item.url?.split("?")[0].toLowerCase();
    const key = mpn || url || `${item.manufacturer}-${Math.random()}`;
    if (byKey.has(key)) {
      const merged = mergePart(byKey.get(key)!, item);
      byKey.set(key, merged);
    } else {
      byKey.set(key, item);
    }
  }
  return Array.from(byKey.values());
};

const providerWeight: Record<Provider, number> = {
  digikey: 4,
  mouser: 3,
  octopart: 3,
  web: 2,
  mock: 1,
};

const scorePart = (item: PartResult, tokens: string[]): number => {
  let score = providerWeight[item.provider || "web"] || 1;
  if (item.stock && item.stock > 0) score += 1;
  if (item.unitPrice && item.unitPrice > 0) score += 0.5;
  const hay = [
    item.manufacturerPartNumber,
    item.description,
    ...Object.values(item.attributes || {}),
  ]
    .filter(Boolean)
    .join(" ")
    .toLowerCase();
  tokens.forEach((t) => {
    if (hay.includes(t)) score += 0.5;
  });
  return score;
};

const filterMock = (
  items: PartResult[],
  input: PartSearchInput,
): PartResult[] => {
  const haystackFor = (item: PartResult) =>
    [
      item.manufacturer,
      item.manufacturerPartNumber,
      item.description,
      ...Object.values(item.attributes || {}),
    ]
      .filter(Boolean)
      .join(" ")
      .toLowerCase();

  const matchesField = (value: string | undefined, haystack: string) =>
    !value || haystack.includes(value.trim().toLowerCase());

  const matchesArray = (values: string[] | undefined, haystack: string) =>
    !values || values.every((v) => matchesField(v, haystack));

  const matchesSpecs = (specs: Record<string, string> | undefined, haystack: string) =>
    !specs ||
    Object.entries(specs).every(
      ([k, v]) =>
        matchesField(k, haystack) ||
        matchesField(v, haystack) ||
        matchesField(`${k} ${v}`, haystack),
    );

  return items.filter((item) => {
    const hay = haystackFor(item);
    return (
      matchesField(input.category, hay) &&
      matchesField(input.manufacturer, hay) &&
      matchesField(input.partNumber, hay) &&
      matchesField(input.value, hay) &&
      matchesField(input.tolerance, hay) &&
      matchesField(input.power, hay) &&
      matchesField(input.voltage, hay) &&
      matchesField(input.current, hay) &&
      matchesField(input.package, hay) &&
      matchesField(input.temperatureCoefficient, hay) &&
      matchesField(input.material, hay) &&
      matchesArray(input.features, hay) &&
      matchesArray(input.keywords, hay) &&
      matchesSpecs(input.specs, hay)
    );
  });
};

export const searchParts = async (
  input: PartSearchInput,
  limit = 8,
  providersOverride?: Provider[],
): Promise<SearchOutcome> => {
  const query = buildKeywordQuery(input);
  if (!query) {
    throw new Error("Provide at least one search term or keyword.");
  }

  const providerPreference = resolveProviders(providersOverride);
  const aggregated: PartResult[] = [];
  const tried: Provider[] = [];

  for (const provider of providerPreference) {
    tried.push(provider);
    const cached = getCachedResults(provider, query);
    if (cached) {
      aggregated.push(...cached);
      if (aggregated.length >= limit) break;
      continue;
    }

    try {
      if (provider === "octopart") {
        const results = await octopartSearch(input, limit);
        setCachedResults(provider, query, results);
        aggregated.push(...results);
      } else if (provider === "mouser") {
        const results = await mouserSearch(input, limit);
        setCachedResults(provider, query, results);
        aggregated.push(...results);
      } else if (provider === "digikey") {
        const results = await digikeyKeywordSearch(input, limit);
        setCachedResults(provider, query, results);
        aggregated.push(...results);
      } else if (provider === "web") {
        const results = await webSearch(input, limit);
        setCachedResults(provider, query, results);
        aggregated.push(...results);
      } else if (provider === "mock") {
        const filtered = filterMock(mockParts, input).slice(0, limit);
        setCachedResults(provider, query, filtered);
        aggregated.push(...filtered);
      }
    } catch {
      continue;
    }

    if (aggregated.length >= limit) break;
  }

  const deduped = dedupeResults(aggregated);
  const tokens = tokensFromInput(input);
  const enriched = await enrichResults(deduped);
  const sorted = enriched
    .map((item) => ({ item, score: scorePart(item, tokens) }))
    .sort((a, b) => b.score - a.score || (b.item.stock || 0) - (a.item.stock || 0))
    .slice(0, limit)
    .map((x) => x.item);
  const reranked = await rerankWithLLM(query, input, sorted, limit);
  const source = deduped.some((r) => r.provider && r.provider !== "mock")
    ? "live"
    : "mock";

  return { source, query, results: reranked, providersTried: tried };
};
