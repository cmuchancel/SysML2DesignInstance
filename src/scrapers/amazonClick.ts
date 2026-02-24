import { renderPageAndGetLinks } from "../headless.js";
import { scrapeAmazonDetail } from "./amazonDetail.js";
import { PartResult } from "../types.js";

export const clickAndScrapeAmazon = async (
  url: string,
  limit = 1,
): Promise<PartResult[]> => {
  try {
    const links = await renderPageAndGetLinks(url, "div[data-component-type='s-search-result'] h2 a", limit, 12000);
    for (const l of links.slice(0, limit)) {
      const detail = await scrapeAmazonDetail(l);
      if (detail) return [detail];
    }
  } catch {
    return [];
  }
  return [];
};
