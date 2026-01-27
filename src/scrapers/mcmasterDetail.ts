import * as cheerio from "cheerio";
import { PartResult } from "../types.js";
import { fetchWithTimeout } from "../http.js";
import { renderPage } from "../headless.js";

const timeoutMs = Number(process.env.MCMASTER_TIMEOUT_MS || "10000");

export const scrapeMcMasterDetail = async (url: string, limit = 10): Promise<PartResult[]> => {
  // Try headless render first (their tables are JS-rendered)
  let html: string | null = null;
  try {
    html = await renderPage(url, timeoutMs);
  } catch {
    const res = await fetchWithTimeout(url, { headers: { "User-Agent": "Mozilla/5.0" } }, timeoutMs);
    if (!res.ok) return [];
    html = await res.text();
  }
  const $ = cheerio.load(html);
  const items: PartResult[] = [];

  $(".pdp-product-table tr").each((_i, row) => {
    if (items.length >= limit) return false;
    const cells = $(row).find("td");
    if (cells.length < 2) return;
    const sku = $(cells[0]).text().trim();
    if (!sku) return;
    const desc = $(cells[1]).text().trim();
    const attrs: Record<string, string> = {};
    $(cells)
      .slice(2)
      .each((idx, td) => {
        const header = $(`.pdp-product-table thead th`).eq(idx + 2).text().trim();
        const val = $(td).text().trim();
        if (header && val) attrs[header] = val;
      });
    items.push({
      manufacturer: "McMaster-Carr",
      manufacturerPartNumber: sku,
      description: desc,
      url,
      attributes: { ...attrs, vendor: "mcmaster" },
      provider: "web",
    });
  });

  return items;
};
