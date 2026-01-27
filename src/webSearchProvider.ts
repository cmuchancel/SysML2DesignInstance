import * as cheerio from "cheerio";
import { buildKeywordQuery } from "./queryBuilder.js";
import { PartResult, PartSearchInput } from "./types.js";
import { scrapeAmazonSearch, scrapeAmazonDetail, scrapeMcMasterSearch, scrapeMcMasterDetail } from "./scrapers/index.js";
import { fetchWithTimeout } from "./http.js";
import { extractMultiplePages } from "./llmExtractor.js";

const defaultUserAgent =
  process.env.WEB_SEARCH_USER_AGENT ||
  "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36";

const isDisabled = () => process.env.DISABLE_WEB_SEARCH === "1";

export const webSearchAvailable = !isDisabled();

const decodeDuckDuckGoRedirect = (href: string | undefined): string | null => {
  if (!href) return null;
  try {
    const url = new URL(href, "https://duckduckgo.com");
    const uddg = url.searchParams.get("uddg");
    if (uddg) return decodeURIComponent(uddg);
  } catch {
    // fall through
  }
  return href;
};

const guessPartNumber = (text: string): string | null => {
  const token = text
    .split(/[\s|,/]+/)
    .map((t) => t.trim())
    .find((t) => /[A-Z0-9]{4,}/.test(t) && /[0-9]/.test(t));
  return token || null;
};

const domainLabel = (urlStr: string): string => {
  try {
    const host = new URL(urlStr).hostname;
    return host.replace(/^www\./, "");
  } catch {
    return "unknown";
  }
};

const parseResults = (html: string, limit: number): PartResult[] => {
  const $ = cheerio.load(html);
  const items: PartResult[] = [];
  $(".result").each((_idx, el) => {
    if (items.length >= limit) return false;
    const link = $(el).find("a.result__a");
    const title = link.text().trim();
    const rawHref = link.attr("href");
    const url = decodeDuckDuckGoRedirect(rawHref) || undefined;
    const snippet =
      $(el).find(".result__snippet").text().trim() ||
      $(el).find(".result__extras__url").text().trim();

    if (!title || !url) return;
    // Skip obvious DDG ad/redirects
    if (url.includes("duckduckgo.com/y.js") || url.includes("ad_domain=")) return;

    const mpn = guessPartNumber(title) || guessPartNumber(snippet) || title;
    items.push({
      manufacturer: domainLabel(url),
      manufacturerPartNumber: mpn,
      description: snippet || title,
      url,
      attributes: { sourceTitle: title },
      provider: "web" as const,
    });
  });
  return items;
};

const parseLiteResults = (html: string, limit: number): PartResult[] => {
  const $ = cheerio.load(html);
  const items: PartResult[] = [];
  $("a.result-link").each((_i, el) => {
    if (items.length >= limit) return false;
    const title = $(el).text().trim();
    const rawHref = $(el).attr("href");
    const url = decodeDuckDuckGoRedirect(rawHref) || rawHref || undefined;
    if (!title || !url) return;
    const mpn = guessPartNumber(title) || title;
    items.push({
      manufacturer: domainLabel(url),
      manufacturerPartNumber: mpn,
      description: title,
      url,
      attributes: { sourceTitle: title },
      provider: "web" as const,
    });
  });
  return items;
};

export const webSearch = async (
  input: PartSearchInput,
  limit = 8,
): Promise<PartResult[]> => {
  if (isDisabled()) return [];
  const query = buildKeywordQuery(input);
  if (!query) return [];

  const refined = input.category ? `${query} ${input.category}` : query;

  // Prefer site-specific scrapes when a vendor is implied
  if ((input.category || "").includes("spring") || query.includes("spring") || query.includes("mcmaster")) {
    try {
      const mcm = await scrapeMcMasterSearch(refined, limit);
      if (mcm.length) {
        // if we got product links, try detail scrape on first
        const linksAttr = mcm[0]?.attributes?.productLinks;
        const linkArr = linksAttr ? linksAttr.split(",").filter(Boolean) : [];
        if (linkArr.length) {
          const detailResults: PartResult[] = [];
          for (const l of linkArr.slice(0, limit)) {
            const detail = await scrapeMcMasterDetail(l, limit);
            detailResults.push(...detail);
            if (detailResults.length >= limit) break;
          }
          if (detailResults.length) return detailResults.slice(0, limit);
        }
        return mcm;
      }
    } catch {
      // fall back
    }
  }
  if (query.includes("amazon")) {
    try {
      const az = await scrapeAmazonSearch(refined, limit);
      if (az.length) {
        const linksAttr = az[0]?.attributes?.productLinks;
        const linkArr = linksAttr ? linksAttr.split(",").filter(Boolean) : [];
        for (const l of linkArr.slice(0, limit)) {
          const detail = await scrapeAmazonDetail(l);
          if (detail) return [detail, ...az].slice(0, limit);
        }
        return az;
      }
    } catch {
      // fall back
    }
  }

  const searchUrls = [
    `https://duckduckgo.com/html/?q=${encodeURIComponent(refined)}`,
    `https://lite.duckduckgo.com/lite/?q=${encodeURIComponent(refined)}`,
  ];

  let basic: PartResult[] = [];
  for (const u of searchUrls) {
    try {
      const res = await fetchWithTimeout(u, {
        headers: {
          "User-Agent": defaultUserAgent,
          "Accept-Language": "en-US,en;q=0.9",
        },
      });
      if (!res.ok) continue;
      const html = await res.text();
      basic = u.includes("lite") ? parseLiteResults(html, limit * 2) : parseResults(html, limit * 2);
      if (basic.length) break;
    } catch {
      continue;
    }
  }

  // If we have no direct results yet, try LLM extraction on the first few product-like URLs
  const urls = basic.map((b) => b.url).filter(Boolean) as string[];

  // Special-case: if a McMaster product page appears, try detail scrape
  const mcmUrl = urls.find((u) => u.includes("mcmaster.com"));
  if (mcmUrl) {
    const detail = await scrapeMcMasterDetail(mcmUrl, limit);
    if (detail.length) return detail.slice(0, limit);
  }

  const enriched = await extractMultiplePages(urls);
  if (enriched.length) return enriched.slice(0, limit);

  return basic.slice(0, limit);
};
