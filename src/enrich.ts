import * as cheerio from "cheerio";
import { fetchWithTimeout } from "./http.js";
import { PartResult } from "./types.js";

const maxEnrich = Number(process.env.ENRICH_MAX_ITEMS || "5");
const perPageTimeout = Number(process.env.ENRICH_TIMEOUT_MS || "6000");

const first = <T>(arr: T[] | undefined) => (arr && arr.length ? arr[0] : undefined);

const guessFromTitle = (title: string): string | undefined => {
  const token = title
    .split(/[\s\|,-]+/)
    .map((t) => t.trim())
    .find((t) => /[A-Z0-9].*[0-9]/.test(t) && t.length >= 4);
  return token;
};

const extractMeta = ($: cheerio.CheerioAPI, names: string[]): string | undefined => {
  for (const n of names) {
    const v =
      $(`meta[name="${n}"]`).attr("content") ||
      $(`meta[property="${n}"]`).attr("content") ||
      $(`meta[itemprop="${n}"]`).attr("content");
    if (v) return v.trim();
  }
  return undefined;
};

const extractTableField = ($: cheerio.CheerioAPI, fieldNames: string[]): string | undefined => {
  const lowerFields = fieldNames.map((f) => f.toLowerCase());
  $("table").each((_i, table) => {
    const rows = $(table).find("tr");
    rows.each((_j, row) => {
      const cells = $(row).find("th,td");
      if (cells.length >= 2) {
        const key = $(cells[0]).text().trim().toLowerCase();
        const val = $(cells[1]).text().trim();
        if (lowerFields.includes(key) && val) {
          (extractTableField as any).found = val;
          return false;
        }
      }
    });
    if ((extractTableField as any).found) return false;
  });
  return (extractTableField as any).found;
};

const extractDescription = ($: cheerio.CheerioAPI): string | undefined => {
  return (
    extractMeta($, ["description", "og:description", "twitter:description"]) ||
    first(
      ["p", ".description", ".product-description", "[itemprop='description']"].flatMap((sel) =>
        $(sel)
          .map((_i, el) => $(el).text().trim())
          .toArray()
          .filter(Boolean),
      ),
    )
  );
};

const enrichOne = async (item: PartResult): Promise<PartResult> => {
  if (!item.url) return item;
  try {
    const res = await fetchWithTimeout(item.url, { headers: { "User-Agent": "Mozilla/5.0" } }, perPageTimeout);
    if (!res.ok) return item;
    const html = await res.text();
    const $ = cheerio.load(html);

    const mpn =
      extractMeta($, ["sku", "mpn", "product:retailer_item_id", "product:sku"]) ||
      extractTableField($, ["part number", "mpn", "sku"]) ||
      guessFromTitle($("title").text()) ||
      item.manufacturerPartNumber;

    const description = extractDescription($) || item.description;

    const attrs = { ...(item.attributes || {}) };
    const sku = extractMeta($, ["sku", "product:sku"]);
    if (sku) attrs.sku = sku;
    const upc = extractMeta($, ["upc", "gtin", "gtin13", "gtin14"]);
    if (upc) attrs.upc = upc;

    return {
      ...item,
      manufacturerPartNumber: mpn || item.manufacturerPartNumber,
      description,
      attributes: attrs,
    };
  } catch {
    return item;
  }
};

export const enrichResults = async (items: PartResult[]): Promise<PartResult[]> => {
  const toEnrich = items.slice(0, maxEnrich);
  const enriched: PartResult[] = [];
  for (const it of toEnrich) {
    enriched.push(await enrichOne(it));
  }
  // keep rest unchanged
  return [...enriched, ...items.slice(maxEnrich)];
};
