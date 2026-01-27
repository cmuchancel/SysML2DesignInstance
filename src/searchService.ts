import { digikeyAvailable, digikeyKeywordSearch } from "./digikeyApi.js";
import { octopartAvailable, octopartSearch } from "./octopartApi.js";
import { mockResistors } from "./mockData.js";
import { mouserAvailable, mouserSearch } from "./mouserApi.js";
import { getCachedResults, setCachedResults } from "./cache.js";
import { buildKeywordQuery } from "./queryBuilder.js";
import { Provider, ResistorResult, ResistorSearchInput, SearchOutcome } from "./types.js";
import { webSearch, webSearchAvailable } from "./webSearchProvider.js";

const preferMock = () => process.env.USE_MOCK === "1";

const filterMock = (
  items: ResistorResult[],
  input: ResistorSearchInput,
): ResistorResult[] => {
  const haystackFor = (item: ResistorResult) =>
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

  return items.filter((item) => {
    const hay = haystackFor(item);
    return (
      matchesField(input.resistance, hay) &&
      matchesField(input.tolerance, hay) &&
      matchesField(input.power, hay) &&
      matchesField(input.package, hay) &&
      matchesField(input.temperatureCoefficient, hay) &&
      matchesField(input.composition, hay) &&
      (!input.keywords?.length ||
        input.keywords.every((kw) => matchesField(kw, hay)))
    );
  });
};

export const searchResistors = async (
  input: ResistorSearchInput,
  limit = 8,
): Promise<SearchOutcome> => {
  const query = buildKeywordQuery(input);
  if (!query) {
    throw new Error("At minimum provide a resistance value or a keyword.");
  }

  const disableOctopart = process.env.DISABLE_OCTOPART === "1";
  const useMock =
    preferMock() || (!digikeyAvailable && (!octopartAvailable || disableOctopart) && !mouserAvailable);
  const providerPreference: Provider[] = [];
  // Mouser first (per request), then Octopart (if not disabled), then Digi-Key.
  if (mouserAvailable && !preferMock()) providerPreference.push("mouser");
  if (octopartAvailable && !disableOctopart && !preferMock())
    providerPreference.push("octopart");
  if (digikeyAvailable && !preferMock()) providerPreference.push("digikey");
  if (webSearchAvailable && !preferMock()) providerPreference.push("web");
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
        const filtered = filterMock(mockResistors, input).slice(0, limit);
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
