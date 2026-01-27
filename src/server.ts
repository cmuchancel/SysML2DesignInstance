import "dotenv/config";
import express, { type Request, type Response } from "express";
import path from "path";
import { fileURLToPath } from "url";
import { z } from "zod";
import { naturalLanguageToSearch, llmAvailable } from "./llm.js";
import { searchParts } from "./searchService.js";

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

const app = express();
app.use(express.json());
app.use(express.static(path.join(__dirname, "..", "public")));

const searchSchema = z.object({
  nl: z.string().optional(),
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
  quantity: z.number().optional(),
  keywords: z.array(z.string()).optional(),
  specs: z.record(z.string(), z.string()).optional(),
  limit: z.number().min(1).max(30).optional(),
  providers: z.array(z.enum(["web", "mouser", "octopart", "digikey", "mock"])).optional(),
});

app.get("/health", (_req, res) =>
  res.json({
    ok: true,
    mode: process.env.USE_MOCK === "1" ? "mock" : "live-ready",
    providers: {
      octopart: Boolean(process.env.OCTOPART_API_KEY || process.env.NEXAR_TOKEN),
      digikey: Boolean(process.env.DIGIKEY_CLIENT_ID && process.env.DIGIKEY_REFRESH_TOKEN),
      mouser: Boolean(process.env.MOUSER_API_KEY),
      web: process.env.DISABLE_WEB_SEARCH === "1" ? false : true,
    },
  }),
);

const handleSearch = async (req: Request, res: Response) => {
  const parse = searchSchema.safeParse(req.body);
  if (!parse.success) {
    return res.status(400).json({ error: parse.error.flatten() });
  }

  try {
    let input = { ...parse.data };
    if (parse.data.nl) {
      if (!llmAvailable) {
        return res.status(400).json({ error: "OPENAI_API_KEY not set for NL parsing" });
      }
      const parsed = await naturalLanguageToSearch(parse.data.nl);
      if (parsed) {
        input = { ...input, ...parsed };
      }
    }
    // remove nl before search
    const { nl: _nl, limit, providers, ...structured } = input;

    const outcome = await searchParts(structured, limit || 12, providers);
    res.json({
      query: outcome.query,
      source: outcome.source,
      providersTried: outcome.providersTried,
      count: outcome.results.length,
      results: outcome.results,
    });
  } catch (error) {
    res.status(500).json({ error: (error as Error).message });
  }
};

app.post("/api/search/resistor", handleSearch); // backward compatibility
app.post("/api/search/parts", handleSearch);

const port = Number(process.env.PORT || 3000);
app.listen(port, () => {
  console.log(`Component finder listening on http://localhost:${port}`);
});
