import OpenAI from "openai";
import { PartResult } from "./types.js";

const apiKey = process.env.OPENAI_API_KEY;
const model = process.env.OPENAI_MODEL || "gpt-4o-mini";
const timeoutMs = Number(process.env.LLM_PICKER_TIMEOUT_MS || "5000");
export const llmUrlPickerAvailable = Boolean(apiKey) && process.env.DISABLE_LLM_PICKER !== "1";

export const pickUrlsWithLLM = async (
  query: string,
  candidates: PartResult[],
  max = 5,
): Promise<PartResult[]> => {
  if (!llmUrlPickerAvailable || candidates.length === 0) return candidates.slice(0, max);
  const prompt = `You are selecting the best product links for: "${query}". Candidates (JSON array): ${JSON.stringify(
    candidates.map((c, i) => ({ id: i, title: c.description || c.manufacturerPartNumber, url: c.url })),
  )}\nReturn a JSON array of ids (highest relevance first), length <= ${max}.`;
  const client = new OpenAI({ apiKey: apiKey! });
  const completion = await Promise.race([
    client.chat.completions.create({
      model,
      messages: [
        { role: "system", content: "Return concise JSON only." },
        { role: "user", content: prompt },
      ],
      response_format: { type: "json_object" },
    }),
    new Promise<null>((resolve) => setTimeout(() => resolve(null), timeoutMs)),
  ]);
  if (!completion) return candidates.slice(0, max);
  const raw = completion.choices[0]?.message?.content;
  if (!raw) return candidates.slice(0, max);
  try {
    const parsed = JSON.parse(raw);
    const ids: number[] = Array.isArray(parsed)
      ? parsed
      : Array.isArray(parsed.ids)
        ? parsed.ids
        : Array.isArray(parsed.order)
          ? parsed.order
          : [];
    const byId = new Map(candidates.map((c, i) => [i, c]));
    const ordered: PartResult[] = [];
    ids.forEach((id) => {
      const hit = byId.get(id);
      if (hit) ordered.push(hit);
    });
    if (ordered.length) return ordered.slice(0, max);
  } catch {
    return candidates.slice(0, max);
  }
  return candidates.slice(0, max);
};
