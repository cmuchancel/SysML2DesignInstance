import * as cheerio from "cheerio";
import { buildKeywordQuery } from "./queryBuilder.js";
import { PartResult, PartSearchInput } from "./types.js";
import {
  scrapeAmazonSearch,
  amazonHeadlessSearch,
  scrapeSimpleProduct,
} from "./scrapers/index.js";
import { fetchWithTimeout } from "./http.js";
import { extractMultiplePages } from "./llmExtractor.js";
import { pickUrlsWithLLM } from "./llmUrlPicker.js";

const defaultUserAgent =
  process.env.WEB_SEARCH_USER_AGENT ||
  "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36";

const isDisabled = () => process.env.DISABLE_WEB_SEARCH === "1";

export const webSearchAvailable = !isDisabled();
const disableHeadless = process.env.DISABLE_HEADLESS === "1";
const fastMode = process.env.FAST_MODE === "1";

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

  // FAST MODE: single-path, single-item, minimal LLM
  if (fastMode) {
    if (!disableHeadless) {
      try {
        const azHead = await amazonHeadlessSearch(refined, 1);
        if (azHead.length) return azHead.slice(0, limit);
      } catch {}
    }
    try {
      const searchUrl = `https://duckduckgo.com/html/?q=${encodeURIComponent(
        `site:thespringstore.com ${refined}`,
      )}`;
      const res = await fetchWithTimeout(searchUrl, { headers: { "User-Agent": defaultUserAgent } });
      if (res.ok) {
        const html = await res.text();
        const basic = parseResults(html, 3);
        const first = basic.find((b) => b.url && b.url.includes("springstore"));
        if (first?.url) {
          const prod = await scrapeSimpleProduct(first.url);
          if (prod) return [prod];
        }
      }
    } catch {}
    return [];
  }

  // Amazon headless first
  if (!disableHeadless) {
    try {
      const azHead = await amazonHeadlessSearch(refined, 1);
      if (azHead.length) return azHead.slice(0, limit);
    } catch {}
  }

  // Amazon HTML (non-headless)
  try {
    const az = await scrapeAmazonSearch(refined, Math.max(1, limit));
    if (az.length) return az.slice(0, limit);
  } catch {}

  // Simple suppliers (dynamic by keywords)
  const isResistor = refined.toLowerCase().includes("resistor") || refined.toLowerCase().includes("ohm");
  const preferSimple = isResistor
    ? [
        `site:digikey.com ${refined}`,
        `site:lcsc.com ${refined}`,
        `site:arrow.com ${refined}`,
        refined,
      ]
    : [
        "site:thespringstore.com stainless compression spring",
        "site:centuryspring.com stainless compression spring",
        refined,
      ];
  for (const q of preferSimple) {
    try {
      const searchUrl = `https://duckduckgo.com/html/?q=${encodeURIComponent(q)}`;
      const res = await fetchWithTimeout(searchUrl, { headers: { "User-Agent": defaultUserAgent } });
      if (!res.ok) continue;
      const html = await res.text();
      const basic = parseResults(html, 5);
      const first = basic.find((b) =>
        b.url
          ? isResistor
            ? b.url.includes("digikey.com") || b.url.includes("lcsc.com") || b.url.includes("arrow.com")
            : b.url.includes("springstore") || b.url.includes("centuryspring")
          : false,
      );
      if (first?.url) {
        const prod = await scrapeSimpleProduct(first.url);
        if (prod) return [prod];
      }
    } catch {}
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
      if (isResistor) {
        basic = basic.filter(
          (b) =>
            b.url &&
            !b.url.includes("springstore") &&
            !b.url.includes("centuryspring") &&
            !b.url.includes("springs"),
        );
      }
      if (basic.length) break;
    } catch {
      continue;
    }
  }

  // If we have no direct results yet, try LLM extraction on the first few product-like URLs
  let ordered = basic;
  // Let LLM pick most relevant URLs if enabled (but cap to small set)
  ordered = await pickUrlsWithLLM(refined, ordered, Math.max(2, limit));
  const urls = ordered.map((b) => b.url).filter(Boolean) as string[];

  // Special-case: if a McMaster product page appears, try detail scrape
  const mcmUrl = urls.find((u) => u.includes("mcmaster.com"));
  // McMaster detail removed in fast/general flow (API planned), so skip

  const enriched = disableHeadless ? [] : await extractMultiplePages(urls);
  if (!disableHeadless && enriched.length) return enriched.slice(0, limit);

  return ordered.slice(0, limit);
};
