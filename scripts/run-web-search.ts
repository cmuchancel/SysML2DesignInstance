import "dotenv/config";
import { searchResistors } from "../src/searchService.js";

const run = async () => {
  process.env.USE_MOCK = "0";
  process.env.DISABLE_WEB_SEARCH = "0";
  const { results, query, source } = await searchResistors(
    {
      resistance: "10k",
      tolerance: "1%",
      package: "0603",
      power: "0.1W",
      keywords: ["thick film"],
    },
    5,
  );

  console.log(`Query "${query}" using source "${source}" returned:`);
  for (const item of results) {
    console.log(
      `- ${item.manufacturerPartNumber} (${item.manufacturer})` +
        (item.url ? ` -> ${item.url}` : ""),
    );
  }
};

run().catch((err) => {
  console.error(err);
  process.exit(1);
});
