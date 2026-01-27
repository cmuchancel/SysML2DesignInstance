import OpenAI from "openai";
import { z } from "zod";
import { ResistorSearchInput } from "./types.js";

const model = process.env.OPENAI_MODEL || "gpt-4o-mini";
const apiKey = process.env.OPENAI_API_KEY;

const schema = z.object({
  resistance: z.string().optional(),
  tolerance: z.string().optional(),
  power: z.string().optional(),
  package: z.string().optional(),
  temperatureCoefficient: z.string().optional(),
  composition: z.string().optional(),
  keywords: z.array(z.string()).optional(),
});

export const llmAvailable = Boolean(apiKey);

export const naturalLanguageToSearch = async (
  text: string,
): Promise<ResistorSearchInput | null> => {
  const fallbackHeuristic = (raw: string): ResistorSearchInput | null => {
    const lower = raw.toLowerCase();
    const resistanceMatch =
      lower.match(/(\d+(?:\.\d+)?\s*(?:k|m)?\s*ohm)/) ||
      lower.match(/(\d+(?:\.\d+)?\s*(?:k|m))/);
    const toleranceMatch = lower.match(/(\d+(?:\.\d+)?\s*%)/);
    const packageMatch = lower.match(/\b(0201|0402|0603|0805|1206|1210|2512)\b/);
    const powerMatch = lower.match(/(\d+(?:\.\d+)?\s*w)/);

    if (resistanceMatch || toleranceMatch || packageMatch || powerMatch) {
      return {
        resistance: resistanceMatch?.[1]?.replace(/\s+/g, "") || undefined,
        tolerance: toleranceMatch?.[1]?.replace(/\s+/g, "") || undefined,
        power: powerMatch?.[1]?.replace(/\s+/g, "") || undefined,
        package: packageMatch?.[1],
      };
    }
    return null;
  };

  if (!apiKey) {
    return fallbackHeuristic(text);
  }
  const client = new OpenAI({ apiKey });

  const systemPrompt = `You extract structured resistor search parameters from a short user request.
Return ONLY minified JSON matching:
{
  "resistance": string?,
  "tolerance": string?,
  "power": string?,
  "package": string?,
  "temperatureCoefficient": string?,
  "composition": string?,
  "keywords": string[]?
}`;

  const userPrompt = `Request: "${text}"`;

  const completion = await client.chat.completions.create({
    model,
    messages: [
      { role: "system", content: systemPrompt },
      { role: "user", content: userPrompt },
    ],
    response_format: { type: "json_object" },
  });

  const raw = completion.choices[0]?.message?.content;
  if (!raw) return fallbackHeuristic(text);

  try {
    const parsed = schema.safeParse(JSON.parse(raw));
    if (!parsed.success) return fallbackHeuristic(text);
    return parsed.data;
  } catch {
    return fallbackHeuristic(text);
  }
};
