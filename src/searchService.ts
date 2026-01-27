import { digikeyAvailable, digikeyKeywordSearch } from "./digikeyApi.js";
import { octopartAvailable, octopartSearch } from "./octopartApi.js";
import { mockParts } from "./mockData.js";
import { mouserAvailable, mouserSearch } from "./mouserApi.js";
import { getCachedResults, setCachedResults } from "./cache.js";
import { buildKeywordQuery } from "./queryBuilder.js";
import { Provider, PartResult, PartSearchInput, SearchOutcome } from "./types.js";
import { webSearch, webSearchAvailable } from "./webSearchProvider.js";

const preferMock = () => process.env.USE_MOCK === "1";

const filterMock = (
  items: PartResult[],
  input: PartSearchInput,
): PartResult[] => {
  const haystackFor = (item: PartResult) =>
    [
      item.manufacturer,
      item.manufacturerPartNumber,
      item.description,
      ...Object.values(item.attributes || {}),
    ]
      .filter(Boolean)
      .join(" ")
      .toLowerCase();

  const matchesField = (value: string | undefined, haystack: string) =>
    !value || haystack.includes(value.trim().toLowerCase());

  const matchesArray = (values: string[] | undefined, haystack: string) =>
    !values || values.every((v) => matchesField(v, haystack));

  const matchesSpecs = (specs: Record<string, string> | undefined, haystack: string) =>
    !specs ||
    Object.entries(specs).every(
      ([k, v]) =>
        matchesField(k, haystack) ||
        matchesField(v, haystack) ||
        matchesField(`${k} ${v}`, haystack),
    );

  return items.filter((item) => {
    const hay = haystackFor(item);
    return (
      matchesField(input.category, hay) &&
      matchesField(input.manufacturer, hay) &&
      matchesField(input.partNumber, hay) &&
      matchesField(input.value, hay) &&
      matchesField(input.tolerance, hay) &&
      matchesField(input.power, hay) &&
      matchesField(input.voltage, hay) &&
      matchesField(input.current, hay) &&
      matchesField(input.package, hay) &&
      matchesField(input.temperatureCoefficient, hay) &&
      matchesField(input.material, hay) &&
      matchesArray(input.features, hay) &&
      matchesArray(input.keywords, hay) &&
      matchesSpecs(input.specs, hay)
    );
  });
};

export const searchParts = async (
  input: PartSearchInput,
  limit = 8,
): Promise<SearchOutcome> => {
  const query = buildKeywordQuery(input);
  if (!query) {
    throw new Error("Provide at least one search term or keyword.");
  }

  const disableOctopart = process.env.DISABLE_OCTOPART === "1";
  const useMock =
    preferMock() || (!digikeyAvailable && (!octopartAvailable || disableOctopart) && !mouserAvailable);
  const providerPreference: Provider[] = [];
  // Web search first to reach suppliers without APIs, then Mouser, Octopart, Digi-Key.
  if (webSearchAvailable && !preferMock()) providerPreference.push("web");
  if (mouserAvailable && !preferMock()) providerPreference.push("mouser");
  if (octopartAvailable && !disableOctopart && !preferMock())
    providerPreference.push("octopart");
  if (digikeyAvailable && !preferMock()) providerPreference.push("digikey");
  if (useMock || providerPreference.length === 0) providerPreference.push("mock");

  for (const provider of providerPreference) {
    const cached = getCachedResults(provider, query);
    if (cached) {
      return { source: provider === "mock" ? "mock" : "live", query, results: cached };
    }

    try {
      if (provider === "octopart") {
        const results = await octopartSearch(input, limit);
        setCachedResults(provider, query, results);
        return { source: "live", query, results };
      }
      if (provider === "mouser") {
        const results = await mouserSearch(input, limit);
        setCachedResults(provider, query, results);
        return { source: "live", query, results };
      }
      if (provider === "digikey") {
        const results = await digikeyKeywordSearch(input, limit);
        setCachedResults(provider, query, results);
        return { source: "live", query, results };
      }
      if (provider === "web") {
        const results = await webSearch(input, limit);
        setCachedResults(provider, query, results);
        if (results.length) {
          return { source: "live", query, results };
        }
      }
      if (provider === "mock") {
        const filtered = filterMock(mockParts, input).slice(0, limit);
        setCachedResults(provider, query, filtered);
        return { source: "mock", query, results: filtered };
      }
    } catch (err) {
      // Continue to next provider
      continue;
    }
  }

  return { source: "mock", query, results: [] };
};
