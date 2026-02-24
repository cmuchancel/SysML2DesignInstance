import * as cheerio from "cheerio";
import { PartResult } from "../types.js";
import { renderPageAndGetLinks, renderSinglePage } from "../headless.js";

const searchSelector = "div[data-component-type='s-search-result'] h2 a";
const pdpWaitSelector = "#productTitle";

const toAbsolute = (href: string | undefined): string | null => {
  if (!href) return null;
  if (href.startsWith("http")) return href;
  try {
    return new URL(href, "https://www.amazon.com").toString();
  } catch {
    return null;
  }
};

const parsePdp = (html: string, url: string): PartResult | null => {
  const $ = cheerio.load(html);
  const title = $("#productTitle").text().trim() || $("title").text().trim();
  if (!title) return null;
  const price = $("#corePrice_feature_div .a-price .a-price-whole").first().text().replace(/[^\d.]/g, "");
  const stock = $("#availability").text().trim();
  const asin =
    $("#ASIN").attr("value") ||
    $("#detailBullets_feature_div li:contains('ASIN') span").last().text().trim() ||
    $("th:contains('ASIN')").next("td").text().trim() ||
    url.split("/dp/")[1]?.split("/")[0];

  const attrs: Record<string, string> = {};
  if (asin) attrs.asin = asin;
  if (stock) attrs.availability = stock;

  // Gather bullet specs
  const bullets = $("#feature-bullets li span")
    .map((_i, el) => $(el).text().trim())
    .get()
    .filter(Boolean);
  if (bullets.length) attrs.bullets = bullets.join(" | ");

  return {
    manufacturer: "Amazon",
    manufacturerPartNumber: asin || title,
    description: title,
    unitPrice: price ? Number(price) : undefined,
    url,
    attributes: attrs,
    provider: "web",
  };
};

export const amazonHeadlessSearch = async (
  query: string,
  limit = 1,
): Promise<PartResult[]> => {
  try {
    const links = await renderPageAndGetLinks(
      `https://www.amazon.com/s?k=${encodeURIComponent(query)}`,
      searchSelector,
      Math.max(1, limit),
      12000,
    );
    const first = toAbsolute(links[0]);
    if (!first) return [];
    const rendered = await renderSinglePage(first, pdpWaitSelector);
    if (!rendered.html) return [];
    const parsed = parsePdp(rendered.html, first);
    return parsed ? [parsed] : [];
  } catch {
    return [];
  }
};
