import { buildKeywordQuery } from "./queryBuilder.js";
import { NexarPart, PartResult, PartSearchInput } from "./types.js";
import { fetchWithTimeout } from "./http.js";

const apiKey = process.env.OCTOPART_API_KEY;
const nexarToken = process.env.NEXAR_TOKEN;
const baseUrl =
  process.env.OCTOPART_BASE_URL || "https://octopart.com/api/v4/endpoint";
const nexarGraphql =
  process.env.NEXAR_GRAPHQL_URL || "https://api.nexar.com/graphql";

export const octopartAvailable = Boolean(apiKey || nexarToken);

const mapNexarParts = (parts: NexarPart[]): PartResult[] =>
  parts
    ?.map((p) => {
      const offers =
        p?.sellers?.flatMap((s) => s.offers || []).filter(Boolean) || [];
      const bestOffer = offers.find((o) => o.prices && o.prices.length);
      return {
        manufacturer: p?.manufacturer?.name || "Unknown",
        manufacturerPartNumber: p?.mpn || "",
        description: p?.shortDescription,
        url: p?.octopartUrl,
        stock: bestOffer?.inventoryLevel,
        unitPrice: bestOffer?.prices?.[0]?.price,
        attributes: Object.fromEntries(
          (p.specs || [])
            .filter((s) => s?.attribute?.name && s.displayValue)
            .map((s) => [
              s.attribute?.shortname || s.attribute?.name || "attr",
              s.displayValue || "",
            ]),
        ),
        provider: "octopart" as const,
      };
    })
    .filter((r) => r.manufacturerPartNumber);

const mapRestParts = (parts: any[]): PartResult[] =>
  parts
    ?.map((p) => {
      const offers = p?.offers ?? [];
      const bestOffer = offers.find((o: any) => o.seller?.name);
      return {
        manufacturer: p?.manufacturer?.name || "Unknown",
        manufacturerPartNumber: p?.mpn || "",
        digiKeyPartNumber: undefined,
        description: p?.short_description || p?.snippet,
        stock: bestOffer?.in_stock_quantity,
        unitPrice: bestOffer?.prices?.usd?.[0]?.[1],
        url: p?.octopart_url,
        attributes: {
          category: p?.category?.name,
        },
        provider: "octopart" as const,
      };
    })
    .filter((r: PartResult) => r.manufacturerPartNumber);

const searchViaNexar = async (
  input: PartSearchInput,
  limit: number,
): Promise<PartResult[]> => {
  if (!nexarToken) throw new Error("Nexar token missing.");
  const query = buildKeywordQuery(input);
  const gql = `
    query SearchParts($q: String!, $limit: Int!) {
      supSearch(q: $q, limit: $limit) {
        results {
          part {
              mpn
              manufacturer { name }
              shortDescription
              octopartUrl
              specs {
                attribute { name shortname }
                displayValue
              }
              sellers(authorizedOnly: false) {
                company { name }
                offers {
                  sku
                  inventoryLevel
                  prices { price quantity currency }
                }
              }
          }
        }
      }
    }
  `;

  const res = await fetchWithTimeout(nexarGraphql, {
    method: "POST",
    headers: {
      Authorization: `Bearer ${nexarToken}`,
      "Content-Type": "application/json",
    },
    body: JSON.stringify({
      query: gql,
      variables: { q: query, limit },
    }),
  });

  if (!res.ok) {
    const text = await res.text();
    throw new Error(`Nexar search failed (${res.status}): ${text.slice(0, 300)}`);
  }

  const data = (await res.json()) as {
    data?: { supSearch?: { results?: { part?: NexarPart }[] } };
  };
  const parts = data.data?.supSearch?.results
    ?.map((r) => r.part)
    .filter(Boolean) as NexarPart[];
  return mapNexarParts(parts || []);
};

const searchViaRest = async (
  input: PartSearchInput,
  limit: number,
): Promise<PartResult[]> => {
  if (!apiKey) throw new Error("Octopart API key missing.");
  const query = buildKeywordQuery(input);
  const url = new URL(baseUrl);
  url.searchParams.set("q", query);
  url.searchParams.set("apikey", apiKey);
  url.searchParams.set("limit", String(limit));

  const res = await fetchWithTimeout(url.toString(), {
    headers: { Accept: "application/json" },
  });

  if (!res.ok) {
    const text = await res.text();
    throw new Error(`Octopart search failed (${res.status}): ${text.slice(0, 300)}`);
  }

  const json = (await res.json()) as { results?: { items?: any[] }[] };
  const items = json.results?.flatMap((r) => r.items || []) || [];
  return mapRestParts(items);
};

export const octopartSearch = async (
  input: PartSearchInput,
  limit = 8,
): Promise<PartResult[]> => {
  const query = buildKeywordQuery(input);
  if (!query) throw new Error("Provide at least one search term or keyword for Octopart search.");

  if (nexarToken) {
    try {
      return await searchViaNexar(input, limit);
    } catch (e) {
      // fall through to REST if available
      if (!apiKey) throw e;
    }
  }

  if (apiKey) {
    return searchViaRest(input, limit);
  }

  throw new Error("No Octopart/Nexar credentials configured.");
};
