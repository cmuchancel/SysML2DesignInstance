import { renderPageAndGetLinks } from "../headless.js";
import { scrapeMcMasterDetail } from "./mcmasterDetail.js";
import { PartResult } from "../types.js";

export const clickAndScrapeMcMaster = async (
  url: string,
  limit = 1,
): Promise<PartResult[]> => {
  try {
    const links = await renderPageAndGetLinks(url, ".ps-item a.ps-link", limit, 12000);
    for (const link of links.slice(0, limit)) {
      const detail = await scrapeMcMasterDetail(link, limit);
      if (detail.length) return detail.slice(0, limit);
    }
  } catch {
    return [];
  }
  return [];
};
