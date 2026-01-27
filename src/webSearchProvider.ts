import * as cheerio from "cheerio";
import { buildKeywordQuery } from "./queryBuilder.js";
import { PartResult, PartSearchInput } from "./types.js";

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

    const mpn = guessPartNumber(title) || guessPartNumber(snippet) || title;
    items.push({
      manufacturer: domainLabel(url),
      manufacturerPartNumber: mpn,
      description: snippet || title,
      url,
      attributes: { sourceTitle: title },
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
  const searchUrl = `https://duckduckgo.com/html/?q=${encodeURIComponent(refined)}`;
  const res = await fetch(searchUrl, {
    headers: { "User-Agent": defaultUserAgent },
  });
  if (!res.ok) {
    throw new Error(`Web search failed with status ${res.status}`);
  }
  const html = await res.text();
  return parseResults(html, limit);
};
