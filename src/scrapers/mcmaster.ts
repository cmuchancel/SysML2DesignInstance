import * as cheerio from "cheerio";
import { PartResult } from "../types.js";
import { extractSpecs, specsToAttributes } from "../specExtractor.js";
import { fetchWithTimeout } from "../http.js";
import { renderPage, renderPageAndGetLinks } from "../headless.js";

export const scrapeMcMasterSearch = async (query: string, limit = 6): Promise<PartResult[]> => {
  const url = `https://www.mcmaster.com/catalog/psearch/?searchText=${encodeURIComponent(query)}`;
  let html: string;
  try {
    html = await renderPage(url, 12000);
  } catch {
    const res = await fetchWithTimeout(
      url,
      {
        headers: {
          "User-Agent": "Mozilla/5.0",
        },
      },
      12000,
    );
    if (!res.ok) throw new Error(`McMaster search failed ${res.status}`);
    html = await res.text();
  }
  const $ = cheerio.load(html);
  const results: PartResult[] = [];
  const productLinks: string[] = [];
  $(".ps-list .ps-item").each((_i, el) => {
    if (results.length >= limit) return false;
    const title = $(el).find(".ps-item-name").text().trim();
    const desc = $(el).find(".ps-item-desc").text().trim();
    const link = $(el).find("a.ps-link").attr("href");
    const mpn = title.split("—")[0]?.trim() || title;
    const url = link ? new URL(link, "https://www.mcmaster.com").toString() : undefined;
    if (url) productLinks.push(url);
    const item: PartResult = {
      manufacturer: "McMaster-Carr",
      manufacturerPartNumber: mpn,
      description: desc || title,
      url,
      attributes: { sourceTitle: title, vendor: "mcmaster" },
      provider: "web",
    };
    const specs = specsToAttributes(extractSpecs(item));
    item.attributes = { ...item.attributes, ...specs };
    results.push(item);
  });
  // Keep category results and note product links for callers
  if (productLinks.length) {
    results[0] = { ...results[0], attributes: { ...(results[0]?.attributes || {}), productLinks: productLinks.join(",") } };
    return results;
  }

  // Fallback: try headless grab of links when none parsed
  try {
    const links = await renderPageAndGetLinks(url, ".ps-item a.ps-link", limit, 12000);
    if (links.length) {
      return [
        {
          manufacturer: "McMaster-Carr",
          manufacturerPartNumber: "Category",
          description: "Category page",
          url,
          attributes: { productLinks: links.join(","), vendor: "mcmaster" },
          provider: "web",
        },
      ];
    }
  } catch {
    // ignore
  }

  return results;
};
