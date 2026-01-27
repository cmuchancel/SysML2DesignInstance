#!/usr/bin/env node
import "dotenv/config";
import yargs from "yargs";
import { hideBin } from "yargs/helpers";
import { naturalLanguageToSearch, llmAvailable } from "./llm.js";
import { searchResistors } from "./searchService.js";
import { ResistorSearchInput } from "./types.js";

const builder = (y: typeof yargs) =>
  y
    .option("resistance", {
      alias: "r",
      type: "string",
      describe: "Resistance value (e.g., 10k, 47k, 4.7)",
    })
    .option("nl", {
      type: "string",
      describe:
        "Natural language description (uses OpenAI to extract fields when OPENAI_API_KEY is set)",
    })
    .option("tolerance", {
      alias: "t",
      type: "string",
      describe: "Tolerance (e.g., 1%, 5%)",
    })
    .option("power", {
      alias: "p",
      type: "string",
      describe: "Power rating (e.g., 0.25W)",
    })
    .option("package", {
      alias: "pkg",
      type: "string",
      describe: "Package/size (e.g., 0603, 0402)",
    })
    .option("temperatureCoefficient", {
      alias: "tc",
      type: "string",
      describe: "Temperature coefficient (e.g., 100ppm/°C)",
    })
    .option("composition", {
      alias: "c",
      type: "string",
      describe: "Film type (Thick Film, Thin Film, Metal Film)",
    })
    .option("keyword", {
      alias: "k",
      type: "array",
      describe: "Additional keywords",
      default: [],
    })
    .option("quantity", {
      alias: "q",
      type: "number",
      describe: "Desired quantity (used for sorting only)",
    })
    .example(
      "$0 --resistance 10k --tolerance 1% --package 0603 --power 0.1W",
      "Find a 10k 1% 0603 resistor.",
    )
    .help();

const run = async () => {
  const argv = await builder(yargs(hideBin(process.argv))).parseAsync();

  const clean = (s?: string) => (s && s.trim() ? s.trim() : undefined);

  let input: ResistorSearchInput = {
    resistance: clean(argv.resistance as string | undefined),
    tolerance: clean(argv.tolerance as string | undefined),
    power: clean(argv.power as string | undefined),
    package: clean(argv.package as string | undefined),
    temperatureCoefficient: clean(argv.temperatureCoefficient as string | undefined),
    composition: clean(argv.composition as string | undefined),
    quantity: argv.quantity as number | undefined,
    keywords: ((argv.keyword as string[] | undefined) || []).map((k) => k.trim()).filter(Boolean),
  };

  if (argv.nl && typeof argv.nl === "string") {
    if (!llmAvailable) {
      console.error("OPENAI_API_KEY not set; cannot parse natural language.");
      process.exit(1);
    }
    try {
      const parsed = await naturalLanguageToSearch(argv.nl);
      if (parsed) {
        const keywords =
          parsed.keywords?.map((k) => k.trim()).filter(Boolean).slice(0, 2) || undefined;
        input = {
          ...input,
          ...parsed,
          resistance: clean(parsed.resistance),
          tolerance: clean(parsed.tolerance),
          power: clean(parsed.power),
          package: clean(parsed.package),
          temperatureCoefficient: clean(parsed.temperatureCoefficient),
          composition: clean(parsed.composition),
          keywords,
        };
        console.log("LLM parsed query:", { ...input, keywords });
      } else {
        console.warn("LLM parse failed, using manual flags only.");
      }
    } catch (err) {
      console.warn("LLM parsing error, using manual flags only.", (err as Error).message);
    }
  }

  try {
    const result = await searchResistors(input, 8);
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
      if (item.description) console.log(`  ${item.description}`);
      if (item.digiKeyPartNumber)
        console.log(`  Digi-Key #: ${item.digiKeyPartNumber}`);
      if (item.stock !== undefined) console.log(`  Stock: ${item.stock}`);
      if (item.unitPrice !== undefined)
        console.log(`  Unit price: $${item.unitPrice.toFixed(4)}`);
      if (item.url) console.log(`  URL: ${item.url}`);
      console.log("-".repeat(72));
    }
  } catch (error) {
    console.error("Search failed:", (error as Error).message);
    process.exitCode = 1;
  }
};

run();
