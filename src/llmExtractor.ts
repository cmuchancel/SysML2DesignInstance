import OpenAI from "openai";
import { PartResult } from "./types.js";
import { fetchWithTimeout } from "./http.js";
import * as cheerio from "cheerio";

const apiKey = process.env.OPENAI_API_KEY;
const model = process.env.OPENAI_MODEL || "gpt-4o-mini";
const maxHtmlChars = Number(process.env.LLM_EXTRACT_MAX_HTML || "12000");
const timeoutMs = Number(process.env.LLM_EXTRACT_TIMEOUT_MS || "8000");
const maxPages = Number(process.env.LLM_EXTRACT_MAX_PAGES || "3");

export const llmExtractorAvailable = Boolean(apiKey) && process.env.DISABLE_LLM_EXTRACT !== "1";

const cleanHtml = (html: string) => {
  // strip scripts/styles and compress whitespace
  return html
    .replace(/<script[\s\S]*?<\/script>/gi, " ")
    .replace(/<style[\s\S]*?<\/style>/gi, " ")
    .replace(/\s+/g, " ")
    .slice(0, maxHtmlChars);
};

const systemPrompt =
  "Extract a single product from the given HTML snippet. Return JSON with keys: manufacturer, manufacturerPartNumber, description, price (number or null), stock (integer or null), url, attributes (object of spec name -> value). If unclear, leave fields null. Do not invent values.";

export const extractPageWithLLM = async (url: string): Promise<PartResult | null> => {
  if (!llmExtractorAvailable) return null;
  try {
    const res = await fetchWithTimeout(url, { headers: { "User-Agent": "Mozilla/5.0" } }, timeoutMs);
    if (!res.ok) return null;
    const htmlRaw = await res.text();
    const $ = cheerio.load(htmlRaw);
    const title = $("title").first().text().trim();
    const body = cleanHtml(htmlRaw);
    const snippet = `${title}\n${body}`;

    const client = new OpenAI({ apiKey: apiKey! });
    const completion = await Promise.race([
      client.chat.completions.create({
        model,
        messages: [
          { role: "system", content: systemPrompt },
          { role: "user", content: snippet },
        ],
        response_format: { type: "json_object" },
      }),
      new Promise<null>((resolve) => setTimeout(() => resolve(null), timeoutMs)),
    ]);
    if (!completion) return null;
    const raw = completion.choices[0]?.message?.content;
    if (!raw) return null;
    const parsed = JSON.parse(raw);
    const result: PartResult = {
      manufacturer: parsed.manufacturer || "Unknown",
      manufacturerPartNumber: parsed.manufacturerPartNumber || title || "Unknown",
      description: parsed.description || title,
      unitPrice: parsed.price ?? undefined,
      stock: parsed.stock ?? undefined,
      url,
      attributes: parsed.attributes || {},
      provider: "web",
    };
    return result;
  } catch {
    return null;
  }
};

export const extractMultiplePages = async (urls: string[]): Promise<PartResult[]> => {
  const limited = urls.slice(0, maxPages);
  const out: PartResult[] = [];
  for (const u of limited) {
    const r = await extractPageWithLLM(u);
    if (r) out.push(r);
  }
  return out;
};
