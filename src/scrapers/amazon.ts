import * as cheerio from "cheerio";
import { PartResult } from "../types.js";
import { extractSpecs, specsToAttributes } from "../specExtractor.js";

const headers = {
  "User-Agent": "Mozilla/5.0",
  Accept: "text/html,application/xhtml+xml",
};

export const scrapeAmazonSearch = async (query: string, limit = 6): Promise<PartResult[]> => {
  const url = `https://www.amazon.com/s?k=${encodeURIComponent(query)}`;
  const res = await fetch(url, { headers });
  if (!res.ok) throw new Error(`Amazon search failed ${res.status}`);
  const html = await res.text();
  const $ = cheerio.load(html);
  const items: PartResult[] = [];
  $("div[data-component-type='s-search-result']").each((_i, el) => {
    if (items.length >= limit) return false;
    const title = $(el).find("h2 a span").first().text().trim();
    const urlPath = $(el).find("h2 a").attr("href");
    const price = $(el).find(".a-price-whole").first().text().replace(/[^\d.]/g, "");
    if (!title || !urlPath) return;
    const fullUrl = new URL(urlPath, "https://www.amazon.com").toString();
    const mpnGuess = title.split(" ")[0];
    const item: PartResult = {
      manufacturer: "Amazon",
      manufacturerPartNumber: mpnGuess,
      description: title,
      url: fullUrl,
      unitPrice: price ? Number(price) : undefined,
      attributes: { sourceTitle: title, vendor: "amazon" },
      provider: "web",
    };
    const specs = specsToAttributes(extractSpecs(item));
    item.attributes = { ...item.attributes, ...specs };
    items.push(item);
  });
  return items;
};
