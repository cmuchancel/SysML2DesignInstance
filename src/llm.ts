import OpenAI from "openai";
import { z } from "zod";
import { PartSearchInput } from "./types.js";

const model = process.env.OPENAI_MODEL || "gpt-4o-mini";
const apiKey = process.env.OPENAI_API_KEY;

const schema = z
  .object({
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
  })
  .passthrough();

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
    const lengthMatch = lower.match(/(\d+(?:\.\d+)?\s*(?:mm|cm|in|inch|ft|foot|feet))/);
    if (packageMatch || voltageMatch || currentMatch || valueMatch || partNumberMatch || categoryMatch || lengthMatch) {
      return {
        value: valueMatch?.[1]?.replace(/\s+/g, "") || undefined,
        voltage: voltageMatch?.[1]?.replace(/\s+/g, "") || undefined,
        current: currentMatch?.[1]?.replace(/\s+/g, "") || undefined,
        package: packageMatch?.[1],
        partNumber: partNumberMatch?.[0],
        category: categoryMatch?.[1],
        specs: lengthMatch ? { length: lengthMatch[1] } : undefined,
      };
    }
    return null;
  };

  if (!apiKey) {
    return fallbackHeuristic(text);
  }
  const client = new OpenAI({ apiKey });

  const systemPrompt = `Extract whatever attributes are relevant for the user's part request and return JSON.
Use these top-level keys when applicable: category, manufacturer, partNumber, value, tolerance, power, voltage, current, package, temperatureCoefficient, material, features (array), keywords (array), specs (object).
Put any other attributes you detect into the specs object as key/value strings (e.g., length, thread, diameter, finish, force, pitch, size).
Return ONLY minified JSON.`;

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
    const data = parsed.data as Record<string, any>;
    const knownKeys = new Set([
      "category",
      "manufacturer",
      "partNumber",
      "value",
      "tolerance",
      "power",
      "voltage",
      "current",
      "package",
      "temperatureCoefficient",
      "material",
      "features",
      "keywords",
      "specs",
    ]);
    const extras: Record<string, string> = {};
    Object.entries(data).forEach(([k, v]) => {
      if (knownKeys.has(k)) return;
      if (typeof v === "string") extras[k] = v;
    });
    const mergedSpecs = { ...(data.specs || {}), ...extras };
    const result: PartSearchInput = {
      category: data.category,
      manufacturer: data.manufacturer,
      partNumber: data.partNumber,
      value: data.value,
      tolerance: data.tolerance,
      power: data.power,
      voltage: data.voltage,
      current: data.current,
      package: data.package,
      temperatureCoefficient: data.temperatureCoefficient,
      material: data.material,
      features: data.features,
      keywords: data.keywords,
      specs: Object.keys(mergedSpecs).length ? mergedSpecs : undefined,
    };
    return result;
  } catch {
    return fallbackHeuristic(text);
  }
};
