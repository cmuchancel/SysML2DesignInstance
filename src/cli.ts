#!/usr/bin/env node
import "dotenv/config";
import yargs from "yargs";
import { hideBin } from "yargs/helpers";
import { naturalLanguageToSearch, llmAvailable } from "./llm.js";
import { searchParts } from "./searchService.js";
import { PartSearchInput, Provider } from "./types.js";

const builder = (y: typeof yargs) =>
  y
    .option("nl", {
      type: "string",
      describe:
        "Natural language description (uses OpenAI to extract fields when OPENAI_API_KEY is set)",
    })
    .option("category", { type: "string", describe: "Category (resistor, capacitor, ic, connector...)" })
    .option("manufacturer", { type: "string", describe: "Manufacturer name" })
    .option("partNumber", { type: "string", describe: "Exact manufacturer part number" })
    .option("value", { alias: "v", type: "string", describe: "Value (10k, 1uF, 3.3V regulator, etc.)" })
    .option("tolerance", { alias: "t", type: "string", describe: "Tolerance (1%, 5%, etc.)" })
    .option("power", { alias: "p", type: "string", describe: "Power rating (0.25W, 1W...)" })
    .option("voltage", { alias: "V", type: "string", describe: "Voltage rating or supply voltage" })
    .option("current", { alias: "I", type: "string", describe: "Current rating" })
    .option("package", { alias: "pkg", type: "string", describe: "Package (0603, QFN48, SOT-23-5...)" })
    .option("temperatureCoefficient", { alias: "tc", type: "string", describe: "Tempco (e.g., 100ppm/°C)" })
    .option("material", { alias: "m", type: "string", describe: "Material/dielectric (X7R, FR4, etc.)" })
    .option("feature", {
      alias: "f",
      type: "array",
      describe: "Feature keywords (low-noise, shielded, waterproof...)",
      default: [],
    })
    .option("keyword", {
      alias: "k",
      type: "array",
      describe: "Additional keywords",
      default: [],
    })
    .option("provider", {
      alias: "P",
      type: "array",
      describe: "Provider order override (web,mouser,octopart,digikey,mock)",
      default: [],
    })
    .option("limit", {
      alias: "l",
      type: "number",
      describe: "Maximum results to return (1-30)",
      default: 12,
    })
    .option("quantity", {
      alias: "q",
      type: "number",
      describe: "Desired quantity (used for sorting only)",
    })
    .option("json", {
      type: "boolean",
      describe: "Emit JSON output instead of human-readable text",
      default: false,
    })
    .example("$0 --category capacitor --value 10uF --voltage 6.3V --package 0603", "Find a 10uF 6.3V 0603 ceramic capacitor.")
    .help();

const run = async () => {
  const argv = await builder(yargs(hideBin(process.argv))).parseAsync();

  const clean = (s?: string) => (s && s.trim() ? s.trim() : undefined);

  let input: PartSearchInput = {
    category: clean(argv.category as string | undefined),
    manufacturer: clean(argv.manufacturer as string | undefined),
    partNumber: clean(argv.partNumber as string | undefined),
    value: clean(argv.value as string | undefined),
    tolerance: clean(argv.tolerance as string | undefined),
    power: clean(argv.power as string | undefined),
    voltage: clean(argv.voltage as string | undefined),
    current: clean(argv.current as string | undefined),
    package: clean(argv.package as string | undefined),
    temperatureCoefficient: clean(argv.temperatureCoefficient as string | undefined),
    material: clean(argv.material as string | undefined),
    features: ((argv.feature as string[] | undefined) || []).map((f) => f.trim()).filter(Boolean),
    quantity: argv.quantity as number | undefined,
    keywords: ((argv.keyword as string[] | undefined) || []).map((k) => k.trim()).filter(Boolean),
  };
  if (input.keywords && input.keywords.length === 0) {
    input.keywords = undefined;
  }
  const providersArg = ((argv.provider as string[] | undefined) || []).map((p) =>
    p.trim(),
  ) as Provider[];
  const limitArg = (argv.limit as number) || 12;
  const jsonOutput = Boolean(argv.json);

  if (argv.nl && typeof argv.nl === "string") {
    if (!llmAvailable) {
      console.error("OPENAI_API_KEY not set; cannot parse natural language.");
      process.exit(1);
    }
    try {
      const parsed = await naturalLanguageToSearch(argv.nl);
      if (parsed) {
        const keywords =
          parsed.keywords?.map((k) => k.trim()).filter(Boolean).slice(0, 3) || undefined;
        input = {
          ...input,
          ...parsed,
          value: clean(parsed.value),
          tolerance: clean(parsed.tolerance),
          power: clean(parsed.power),
          voltage: clean(parsed.voltage),
          current: clean(parsed.current),
          package: clean(parsed.package),
          temperatureCoefficient: clean(parsed.temperatureCoefficient),
          material: clean(parsed.material),
          keywords,
        };
        if ((!input.keywords || input.keywords.length === 0) && typeof argv.nl === "string") {
          input.keywords = argv.nl.split(/\s+/).filter(Boolean);
        }
        if (!jsonOutput) {
          console.log("LLM parsed query:", { ...input, keywords });
        }
      } else {
        if (!jsonOutput) {
          console.warn("LLM parse failed, using manual flags only.");
        }
      }
    } catch (err) {
      if (!jsonOutput) {
        console.warn("LLM parsing error, using manual flags only.", (err as Error).message);
      }
    }
  }

  try {
    const result = await searchParts(input, limitArg, providersArg);
    if (jsonOutput) {
      console.log(
        JSON.stringify(
          {
            query: result.query,
            source: result.source,
            providersTried: result.providersTried,
            count: result.results.length,
            results: result.results,
            input,
          },
          null,
          2,
        ),
      );
      return;
    }
    if (!result.results.length) {
      console.log("No results found. Adjust your query or relax filters.");
      return;
    }

    console.log(
      `Source: ${result.source} | Query: \"${result.query}\" | Matches: ${result.results.length}`,
    );
    console.log("-".repeat(72));
    for (const item of result.results) {
      console.log(`${item.manufacturerPartNumber} (${item.manufacturer})`);
      if (item.attributes?.mouserPartNumber) {
        console.log(`  Mouser #: ${item.attributes.mouserPartNumber}`);
      }
      if (item.description) console.log(`  ${item.description}`);
      if (item.digiKeyPartNumber)
        console.log(`  Digi-Key #: ${item.digiKeyPartNumber}`);
      if (item.stock !== undefined) console.log(`  Stock: ${item.stock}`);
      if (item.unitPrice !== undefined)
        console.log(`  Unit price: $${item.unitPrice.toFixed(4)}`);
      if (item.url) console.log(`  URL: ${item.url}`);
      else if (item.attributes?.mouserPartNumber) {
        console.log(
          `  URL: https://www.mouser.com/ProductDetail/${encodeURIComponent(
            item.attributes.mouserPartNumber,
          )}`,
        );
      }
      console.log("-".repeat(72));
    }
  } catch (error) {
    console.error("Search failed:", (error as Error).message);
    process.exitCode = 1;
  }
};

run();
