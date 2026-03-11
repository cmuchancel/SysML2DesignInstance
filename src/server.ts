import "dotenv/config";
import express, { type Request, type Response } from "express";
import path from "path";
import { fileURLToPath } from "url";
import { z } from "zod";
import fs from "fs";
import { execFile } from "child_process";
import { promisify } from "util";
import { naturalLanguageToSearch, llmAvailable } from "./llm.js";
import { startSimpleRun, subscribeSimpleRun, getSimpleRunState } from "./simplePipeline.js";
import { searchParts } from "./searchService.js";

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);
const execFileAsync = promisify(execFile);

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
      if (llmAvailable) {
        const parsed = await naturalLanguageToSearch(parse.data.nl);
        if (parsed) {
          input = { ...input, ...parsed };
        }
        if (!input.keywords || input.keywords.length === 0) {
          input.keywords = parse.data.nl.split(/\s+/).filter(Boolean);
        }
      } else {
        // fallback: use nl as keyword bag
        const words = parse.data.nl.split(/\s+/).filter(Boolean);
        input = { ...input, keywords: [...(input.keywords || []), ...words] };
      }
    }
    // remove nl before search
    const { nl: _nl, limit, providers, ...structured } = input;

    const searchTimeout = Number(process.env.SEARCH_TIMEOUT_MS || "15000");
    const outcome = (await Promise.race([
      searchParts(structured, limit || 12, providers),
      timeout(searchTimeout, "Search timed out"),
    ])) as Awaited<ReturnType<typeof searchParts>>;
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

// -------- Pipeline runner (NL -> SysML -> concepts -> parts) -----------

const runSchema = z.object({
  nl: z.string().min(4),
  maxIters: z.number().optional(),
  concepts: z.number().min(1).max(12).optional(),
  maxParallelConcepts: z.number().min(1).max(12).optional(),
  partsPerConcept: z.number().optional(),
  searchLimit: z.number().optional(),
  providers: z.array(z.enum(["web", "mouser", "octopart", "digikey", "mock"])).optional(),
  optimizerDecisionMode: z.enum(["auto", "agent", "human", "llm"]).optional(),
  optimizerDecisionModel: z.string().min(1).optional(),
});

const simpleRunSchema = z.object({
  nl: z.string().min(4),
  concepts: z.number().min(1).max(3).optional(),
});

const simpleRunsDir = path.join(__dirname, "..", "pipeline", "parallel_runs");

const listSimpleRuns = async (limit = 20): Promise<string[]> => {
  try {
    const names = await fs.promises.readdir(simpleRunsDir);
    return names
      .filter((n) => /^\d{14}_[a-z0-9]{4}$/i.test(n))
      .sort()
      .reverse()
      .slice(0, limit);
  } catch {
    return [];
  }
};

const runsDir = path.join(__dirname, "..", "pipeline", "runs");
const pythonPath = path.join(__dirname, "..", ".venv", "bin", "python");
const runAllPath = path.join(__dirname, "..", "pipeline", "run_all.py");

const listRuns = async (): Promise<string[]> => {
  try {
    return await fs.promises.readdir(runsDir);
  } catch {
    return [];
  }
};

const newestRun = (names: string[]): string | undefined =>
  names
    .filter((n) => /^\d{8}_\d{6}(?:_[a-f0-9]{4})?$/.test(n))
    .sort()
    .at(-1);

app.post("/api/pipeline/run", async (req: Request, res: Response) => {
  const parsed = runSchema.safeParse(req.body);
  if (!parsed.success) return res.status(400).json({ error: parsed.error.flatten() });
  const before = await listRuns();

  const cmd = fs.existsSync(pythonPath) ? pythonPath : "python";
  const args = [
    runAllPath,
    "--nl",
    parsed.data.nl,
    "--max-iters",
    String(parsed.data.maxIters ?? 1),
    "--max-total-tokens",
    "6000",
    "--model",
    process.env.OPENAI_MODEL || "gpt-5-mini",
    "--concepts",
    String(parsed.data.concepts ?? 3),
    "--max-parallel-concepts",
    String(parsed.data.maxParallelConcepts ?? parsed.data.concepts ?? 3),
    "--parts-per-concept",
    String(parsed.data.partsPerConcept ?? 3),
    "--search-limit",
    String(parsed.data.searchLimit ?? 3),
  ];
  if (parsed.data.providers?.length) {
    args.push("--providers", parsed.data.providers.join(","));
  }
  if (parsed.data.optimizerDecisionMode) {
    args.push("--optimizer-decision-mode", parsed.data.optimizerDecisionMode);
  }
  if (parsed.data.optimizerDecisionModel) {
    args.push("--optimizer-decision-model", parsed.data.optimizerDecisionModel);
  }

  try {
    const { stdout, stderr } = await execFileAsync(cmd, args, {
      cwd: path.join(__dirname, ".."),
      env: { ...process.env },
      timeout: Number(process.env.PIPELINE_TIMEOUT_MS || 1800000),
      maxBuffer: 10 * 1024 * 1024,
    });

    const after = await listRuns();
    const newRunName =
      after.filter((n) => !before.includes(n)).sort().at(-1) || newestRun(after) || "";
    const runPath = path.join(runsDir, newRunName);

    const collectSysmlFiles = async (): Promise<string[]> => {
      const sysmlDir = path.join(runPath, "sysml");
      const stack = [sysmlDir];
      const found: string[] = [];
      while (stack.length) {
        const dir = stack.pop()!;
        if (!fs.existsSync(dir)) continue;
        for (const entry of await fs.promises.readdir(dir, { withFileTypes: true })) {
          const full = path.join(dir, entry.name);
          if (entry.isDirectory()) stack.push(full);
          else if (entry.isFile() && entry.name.endsWith(".sysml")) found.push(full);
        }
      }
      return found.sort();
    };

    const deliverable = path.join(runPath, "deliverables", "final.sysml");
    let finalSysml = "";
    if (fs.existsSync(deliverable)) {
      finalSysml = await fs.promises.readFile(deliverable, "utf-8");
    }
    // design instances sysml if present
    const designInstancesPath = path.join(runPath, "deliverables", "design_instances.sysml");
    let designSysml = "";
    if (fs.existsSync(designInstancesPath)) {
      designSysml = await fs.promises.readFile(designInstancesPath, "utf-8");
    }

    let reqSysml = "";
    const sysmlFiles = await collectSysmlFiles();
    if (sysmlFiles.length) {
      reqSysml = await fs.promises.readFile(sysmlFiles[0], "utf-8");
      if (!finalSysml) {
        finalSysml = await fs.promises.readFile(sysmlFiles.at(-1)!, "utf-8");
      }
    }

    let concepts: unknown = null;
    const conceptsPath = path.join(runPath, "concepts", "auto_concepts.json");
    if (fs.existsSync(conceptsPath)) {
      try {
        concepts = JSON.parse(await fs.promises.readFile(conceptsPath, "utf-8"));
      } catch {
        concepts = null;
      }
    }

    let partsLog = "";
    try {
      const logs = (await fs.promises.readdir(path.join(runPath, "parts"))).filter((f) =>
        f.endsWith(".log"),
      );
      if (logs.length) {
        const logPath = path.join(runPath, "parts", logs.sort().at(-1)!);
        partsLog = await fs.promises.readFile(logPath, "utf-8");
      }
    } catch {
      partsLog = "";
    }

    const extractBom = (sysml: string): { item: string; url?: string }[] => {
      const bom: { item: string; url?: string }[] = [];
      const pnRe = /mouserPN\s*=\s*\"([^\"]+)\"/gi;
      const urlRe = /mouserURL\s*=\s*\"([^\"]+)\"/gi;
      const urls = [...sysml.matchAll(urlRe)].map((m) => m[1]);
      const pns = [...sysml.matchAll(pnRe)].map((m) => m[1]);
      const max = Math.max(pns.length, urls.length);
      for (let i = 0; i < max; i++) {
        bom.push({ item: pns[i] || `item-${i + 1}`, url: urls[i] });
      }
      return bom.filter((b) => b.item || b.url);
    };

    // Prefer BOM from JSON rows if present; otherwise extract from final sysml
    let bom: { item: string; url?: string; concept?: string; status?: string; stock?: string }[] = [];
    const bomJson = path.join(runPath, "deliverables", "bom.json");
    if (fs.existsSync(bomJson)) {
      try {
        bom = JSON.parse(await fs.promises.readFile(bomJson, "utf-8"));
      } catch {
        bom = [];
      }
    }
    if (!bom.length && finalSysml) {
      bom = extractBom(finalSysml);
    }

    // Stage log (if present)
    let stageLog: string | undefined;
    const stageLogPath = path.join(runPath, "stage_log.jsonl");
    if (fs.existsSync(stageLogPath)) {
      stageLog = await fs.promises.readFile(stageLogPath, "utf-8");
    }

    res.json({
      runDir: newRunName,
      stdout,
      stderr,
      requirementsSysml: reqSysml,
      finalSysml,
      designSysml,
      concepts,
      partsLog,
      bom,
      stageLog,
    });
  } catch (error) {
    const err = error as Error & { stdout?: string; stderr?: string };
    res.status(500).json({
      error: err.message,
      stdout: err.stdout,
      stderr: err.stderr,
    });
  }
});

// -------- Simplified parallel pipeline (NL -> requirements -> concepts -> 3 concept SysML) --------

app.post("/api/simple/run", (req: Request, res: Response) => {
  const parsed = simpleRunSchema.safeParse(req.body);
  if (!parsed.success) return res.status(400).json({ error: parsed.error.flatten() });
  try {
    const { runId, state } = startSimpleRun(parsed.data.nl, Math.min(parsed.data.concepts ?? 3, 3));
    res.json({ runId, state });
  } catch (error) {
    res.status(500).json({ error: (error as Error).message });
  }
});

app.get("/api/simple/state/:id", (req: Request, res: Response) => {
  const state = getSimpleRunState(req.params.id);
  if (!state) return res.status(404).json({ error: "run not found" });
  res.json({ state });
});

app.get("/api/simple/runs", async (req: Request, res: Response) => {
  const limit = Number(req.query.limit ?? 20);
  const runs = await listSimpleRuns(Number.isFinite(limit) && limit > 0 ? limit : 20);
  res.json({ runs });
});

app.get("/api/simple/stream/:id", (req: Request, res: Response) => {
  const state = getSimpleRunState(req.params.id);
  if (!state) {
    res.status(404).end();
    return;
  }
  res.setHeader("Content-Type", "text/event-stream");
  res.setHeader("Cache-Control", "no-cache");
  res.setHeader("Connection", "keep-alive");
  if (res.flushHeaders) res.flushHeaders();
  const send = (payload: unknown) => {
    res.write(`data: ${JSON.stringify({ state: payload })}\n\n`);
  };
  send(state);
  const unsubscribe = subscribeSimpleRun(req.params.id, (next) => send(next));
  const keepAlive = setInterval(() => res.write(": keep-alive\n\n"), 15000);
  req.on("close", () => {
    clearInterval(keepAlive);
    unsubscribe();
  });
});

const port = Number(process.env.PORT || 3000);
app.listen(port, () => {
  console.log(`Component finder listening on http://localhost:${port}`);
});
const timeout = <T>(ms: number, message = "timeout"): Promise<T> =>
  new Promise((_resolve, reject) => setTimeout(() => reject(new Error(message)), ms));
