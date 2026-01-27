import * as cheerio from "cheerio";
import { PartResult } from "../types.js";
import { extractSpecs, specsToAttributes } from "../specExtractor.js";

export const scrapeMcMasterSearch = async (query: string, limit = 6): Promise<PartResult[]> => {
  const url = `https://www.mcmaster.com/catalog/psearch/?searchText=${encodeURIComponent(query)}`;
  const res = await fetch(url, {
    headers: {
      "User-Agent": "Mozilla/5.0",
    },
  });
  if (!res.ok) throw new Error(`McMaster search failed ${res.status}`);
  const html = await res.text();
  const $ = cheerio.load(html);
  const results: PartResult[] = [];
  $(".ps-list .ps-item").each((_i, el) => {
    if (results.length >= limit) return false;
    const title = $(el).find(".ps-item-name").text().trim();
    const desc = $(el).find(".ps-item-desc").text().trim();
    const link = $(el).find("a.ps-link").attr("href");
    const mpn = title.split("—")[0]?.trim() || title;
    const url = link ? new URL(link, "https://www.mcmaster.com").toString() : undefined;
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
  return results;
};
