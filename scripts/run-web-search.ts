import "dotenv/config";
import { searchParts } from "../src/searchService.js";

const run = async () => {
  process.env.USE_MOCK = "0";
  process.env.DISABLE_WEB_SEARCH = "0";
  const { results, query, source, providersTried } = await searchParts(
    {
      category: "connector",
      keywords: ["USB", "micro B", "right angle", "smd"],
    },
    8,
    ["web", "mock"],
  );

  console.log(
    `Query "${query}" using source "${source}" providers [${providersTried?.join(
      ", ",
    )}] returned:`,
  );
  for (const item of results) {
    console.log(
      `- ${item.manufacturerPartNumber} (${item.manufacturer})` +
        (item.url ? ` -> ${item.url}` : "") +
        (item.provider ? ` [${item.provider}]` : ""),
    );
  }
};

run().catch((err) => {
  console.error(err);
  process.exit(1);
});
