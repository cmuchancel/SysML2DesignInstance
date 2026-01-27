import OpenAI from "openai";
import { z } from "zod";
import { PartSearchInput } from "./types.js";

const model = process.env.OPENAI_MODEL || "gpt-4o-mini";
const apiKey = process.env.OPENAI_API_KEY;

const schema = z.object({
  category: z.string().optional(),
  manufacturer: z.string().optional(),
  partNumber: z.string().optional(),
  value: z.string().optional(),
  tolerance: z.string().optional(),
  power: z.string().optional(),
  voltage: z.string().optional(),
  current: z.string().optional(),
  package: z.string().optional(),
  temperatureCoefficient: z.string().optional(),
  material: z.string().optional(),
  features: z.array(z.string()).optional(),
  keywords: z.array(z.string()).optional(),
  specs: z.record(z.string(), z.string()).optional(),
});

export const llmAvailable = Boolean(apiKey);

export const naturalLanguageToSearch = async (
  text: string,
): Promise<PartSearchInput | null> => {
  const fallbackHeuristic = (raw: string): PartSearchInput | null => {
    const lower = raw.toLowerCase();
    const packageMatch = lower.match(/\b(0201|0402|0603|0805|1206|1210|2512|qfn|tssop|soic|sot\-23)\b/);
    const voltageMatch = lower.match(/(\d+(?:\.\d+)?\s*v)/);
    const currentMatch = lower.match(/(\d+(?:\.\d+)?\s*a)/);
    const valueMatch =
      lower.match(/(\d+(?:\.\d+)?\s*(?:k|m)?\s*ohm)/) ||
      lower.match(/(\d+(?:\.\d+)?\s*u?f)/);
    const partNumberMatch = raw.match(/[A-Z0-9][A-Z0-9\-\._]{4,}/);
    const categoryMatch = lower.match(
      /\b(resistor|res|cap|capacitor|inductor|connector|op-amp|regulator|mcu|ic|sensor)\b/,
    );
    if (packageMatch || voltageMatch || currentMatch || valueMatch || partNumberMatch || categoryMatch) {
      return {
        value: valueMatch?.[1]?.replace(/\s+/g, "") || undefined,
        voltage: voltageMatch?.[1]?.replace(/\s+/g, "") || undefined,
        current: currentMatch?.[1]?.replace(/\s+/g, "") || undefined,
        package: packageMatch?.[1],
        partNumber: partNumberMatch?.[0],
        category: categoryMatch?.[1],
      };
    }
    return null;
  };

  if (!apiKey) {
    return fallbackHeuristic(text);
  }
  const client = new OpenAI({ apiKey });

  const systemPrompt = `You extract structured electronic component search parameters from a short user request.
Return ONLY minified JSON matching:
{
  "category": string?,
  "manufacturer": string?,
  "partNumber": string?,
  "value": string?,
  "tolerance": string?,
  "power": string?,
  "voltage": string?,
  "current": string?,
  "package": string?,
  "temperatureCoefficient": string?,
  "material": string?,
  "features": string[]?,
  "keywords": string[]?,
  "specs": { [key: string]: string }?
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
