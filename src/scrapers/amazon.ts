import * as cheerio from "cheerio";
import { PartResult } from "../types.js";
import { extractSpecs, specsToAttributes } from "../specExtractor.js";
import { fetchWithTimeout } from "../http.js";
import { renderPage } from "../headless.js";

const headers = {
  "User-Agent": "Mozilla/5.0",
  Accept: "text/html,application/xhtml+xml",
};

export const scrapeAmazonSearch = async (query: string, limit = 6): Promise<PartResult[]> => {
  const url = `https://www.amazon.com/s?k=${encodeURIComponent(query)}`;
  let html: string;
  try {
    html = await renderPage(url, 12000);
  } catch {
    const res = await fetchWithTimeout(url, { headers }, 12000);
    if (!res.ok) throw new Error(`Amazon search failed ${res.status}`);
    html = await res.text();
  }
  const $ = cheerio.load(html);
  const items: PartResult[] = [];
  const productLinks: string[] = [];
  $("div[data-component-type='s-search-result']").each((_i, el) => {
    if (items.length >= limit) return false;
    const title = $(el).find("h2 a span").first().text().trim();
    const urlPath = $(el).find("h2 a").attr("href");
    const price = $(el).find(".a-price-whole").first().text().replace(/[^\d.]/g, "");
    if (!title || !urlPath) return;
    const fullUrl = new URL(urlPath, "https://www.amazon.com").toString();
    if (fullUrl.includes("/dp/")) productLinks.push(fullUrl);
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
  if (items.length && productLinks.length) {
    items[0].attributes = { ...(items[0].attributes || {}), productLinks: productLinks.join(",") };
  }
  return items;
};
