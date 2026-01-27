import "dotenv/config";
import { searchParts } from "../src/searchService.js";
import { Provider } from "../src/types.js";

const scenarios = [
  {
    name: "Capacitor 10uF 6.3V 0603",
    input: { category: "capacitor", value: "10uF", voltage: "6.3V", package: "0603" },
  },
  {
    name: "Op-amp zero-drift SOT-23-5",
    input: { category: "op-amp", keywords: ["zero-drift", "sot-23-5", "rrio"] },
  },
  {
    name: "Micro USB right angle connector",
    input: {
      category: "connector",
      keywords: ["micro usb", "right angle", "smd"],
    },
    providers: ["web", "mock"],
  },
];

const run = async () => {
  for (const scenario of scenarios) {
    const { name, input, providers } = scenario;
    const res = await searchParts(input, 6, providers as Provider[] | undefined);
    console.log(`\n[${name}] query="${res.query}" source=${res.source} tried=${res.providersTried?.join(",")}`);
    for (const item of res.results) {
      console.log(
        `- ${item.manufacturerPartNumber} (${item.manufacturer}) [${item.provider || "?"}] ${item.url || ""}`,
      );
    }
  }
};

run().catch((err) => {
  console.error(err);
  process.exit(1);
});
