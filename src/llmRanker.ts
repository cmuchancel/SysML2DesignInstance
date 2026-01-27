import OpenAI from "openai";
import { PartResult, PartSearchInput } from "./types.js";
import { extractSpecs } from "./specExtractor.js";

const apiKey = process.env.OPENAI_API_KEY;
const model = process.env.OPENAI_MODEL || "gpt-4o-mini";

export const llmRankerAvailable = Boolean(apiKey) && process.env.DISABLE_LLM_RERANK !== "1";

export const rerankWithLLM = async (
  query: string,
  input: PartSearchInput,
  results: PartResult[],
  limit: number,
): Promise<PartResult[]> => {
  if (!llmRankerAvailable) return results;
  const client = new OpenAI({ apiKey: apiKey! });

  const itemsForModel = results.map((r, idx) => ({
    id: idx,
    mpn: r.manufacturerPartNumber,
    mfr: r.manufacturer,
    desc: r.description,
    provider: r.provider,
    specs: extractSpecs(r),
  }));

  const prompt = `You are ranking electronic or mechanical parts for best fit to a user query.
User query: ${query}
Structured request: ${JSON.stringify(input)}
Return the item ids in best-to-worst order, top ${limit}. Respond as JSON array of ids only.`;

  const completion = await client.chat.completions.create({
    model,
    messages: [
      { role: "system", content: "Return concise JSON only." },
      { role: "user", content: prompt },
    ],
    response_format: { type: "json_object" },
  });

  const raw = completion.choices[0]?.message?.content;
  if (!raw) return results;
  try {
    const parsed = JSON.parse(raw);
    const idOrder: number[] = Array.isArray(parsed)
      ? parsed
      : Array.isArray(parsed.ids)
        ? parsed.ids
        : Array.isArray(parsed.order)
          ? parsed.order
          : [];
    if (!idOrder.length) return results;
    const map = new Map(results.map((r, i) => [i, r]));
    const reordered: PartResult[] = [];
    idOrder.forEach((id) => {
      const hit = map.get(id);
      if (hit) reordered.push(hit);
    });
    if (reordered.length) return reordered.slice(0, limit);
  } catch {
    return results;
  }
  return results;
};
