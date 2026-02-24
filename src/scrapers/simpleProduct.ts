import * as cheerio from "cheerio";
import { renderSinglePage } from "./playwrightSingle.js";
import { PartResult } from "../types.js";

export const scrapeSimpleProduct = async (url: string): Promise<PartResult | null> => {
  const rendered = await renderSinglePage(url, undefined);
  if (!rendered.html) return null;
  const $ = cheerio.load(rendered.html);
  const title = $("h1").first().text().trim() || $("title").text().trim();
  if (!title) return null;
  const price = $("meta[itemprop='price']").attr("content") || $(".price").first().text().replace(/[^\d.]/g, "");
  const attrs: Record<string, string> = {};
  const specs: string[] = [];
  $("table tr").each((_i, row) => {
    const cells = $(row).find("td,th");
    if (cells.length >= 2) {
      const k = $(cells[0]).text().trim();
      const v = $(cells[1]).text().trim();
      if (k && v) attrs[k] = v;
    }
  });
  $(".spec, .attribute, li").each((_i, el) => {
    const t = $(el).text().trim();
    if (t) specs.push(t);
  });
  if (specs.length) attrs["specs"] = specs.join(" | ");
  return {
    manufacturer: new URL(url).hostname.replace(/^www\./, ""),
    manufacturerPartNumber: title,
    description: title,
    unitPrice: price ? Number(price) : undefined,
    url,
    attributes: attrs,
    provider: "web",
  };
};
