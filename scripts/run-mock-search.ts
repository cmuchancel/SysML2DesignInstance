import "dotenv/config";
import { searchResistors } from "../src/searchService.js";

const run = async () => {
  process.env.USE_MOCK = "1";
  const { results, query, source } = await searchResistors(
    {
      resistance: "10k",
      tolerance: "1%",
      package: "0603",
      power: "0.1W",
    },
    5,
  );

  console.log(`Query "${query}" using source "${source}" returned:`);
  for (const item of results) {
    console.log(
      `- ${item.manufacturerPartNumber} (${item.manufacturer})` +
        (item.digiKeyPartNumber ? ` | Digi-Key # ${item.digiKeyPartNumber}` : ""),
    );
  }
};

run().catch((err) => {
  console.error(err);
  process.exit(1);
});
