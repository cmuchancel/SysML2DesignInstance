import * as cheerio from "cheerio";
import { PartResult } from "../types.js";
import { fetchWithTimeout } from "../http.js";
import { renderPage } from "../headless.js";

const timeoutMs = Number(process.env.AMAZON_TIMEOUT_MS || "10000");

export const scrapeAmazonDetail = async (url: string): Promise<PartResult | null> => {
  let html: string;
  try {
    html = await renderPage(url, timeoutMs);
  } catch {
    const res = await fetchWithTimeout(url, { headers: { "User-Agent": "Mozilla/5.0" } }, timeoutMs);
    if (!res.ok) return null;
    html = await res.text();
  }
  const $ = cheerio.load(html);

  const title = $("#productTitle").text().trim() || $("title").text().trim();
  const price = $("#corePrice_feature_div .a-price .a-price-whole").first().text().replace(/[^\d.]/g, "");
  const stockText = $("#availability").text().trim();
  const asin =
    $("#detailBullets_feature_div li:contains('ASIN') span").last().text().trim() ||
    $("#ASIN").attr("value") ||
    $("th:contains('ASIN')").next("td").text().trim() ||
    url.split("/dp/")[1]?.split("/")[0];

  if (!title) return null;
  const attrs: Record<string, string> = {};
  if (asin) attrs.asin = asin;
  if (stockText) attrs.availability = stockText;

  const result: PartResult = {
    manufacturer: "Amazon",
    manufacturerPartNumber: asin || title,
    description: title,
    unitPrice: price ? Number(price) : undefined,
    url,
    attributes: attrs,
    provider: "web",
  };
  return result;
};
