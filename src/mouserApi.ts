import { buildKeywordQuery } from "./queryBuilder.js";
import { PartResult, PartSearchInput } from "./types.js";
import { fetchWithTimeout } from "./http.js";

const apiKey = process.env.MOUSER_API_KEY;
const baseUrl =
  process.env.MOUSER_BASE_URL || "https://api.mouser.com/api/v1/search/keyword";

export const mouserAvailable = Boolean(apiKey);

type MouserPart = {
  Manufacturer?: string;
  ManufacturerPartNumber?: string;
  Description?: string;
  MouserPartNumber?: string;
  Availability?: string;
  UnitPrice?: string;
  DataSheetUrl?: string;
  ProductDetailUrl?: string;
  RohsStatus?: string;
  Category?: string;
};

const parseAvailability = (availability?: string): number | undefined => {
  if (!availability) return undefined;
  const match = availability.match(/(\d[\d,]*)/);
  return match ? Number(match[1].replace(/,/g, "")) : undefined;
};

const mapParts = (parts: MouserPart[]): PartResult[] =>
  parts
    ?.map((p) => {
      const mpn = p.MouserPartNumber || "";
      const manuMpn = p.ManufacturerPartNumber || "";
      const manu = p.Manufacturer || "";
      const productUrl =
        mpn ? `https://www.mouser.com/ProductDetail/${encodeURIComponent(mpn)}` : undefined;
      const manuUrl =
        manu && manuMpn
          ? `https://www.mouser.com/ProductDetail/${encodeURIComponent(manu)}/${encodeURIComponent(manuMpn)}`
          : undefined;
      return {
        manufacturer: p.Manufacturer || "Unknown",
        manufacturerPartNumber: p.ManufacturerPartNumber || "",
        digiKeyPartNumber: undefined,
        description: p.Description,
        stock: parseAvailability(p.Availability),
        unitPrice: p.UnitPrice ? Number(p.UnitPrice) : undefined,
        url: productUrl || manuUrl || p.ProductDetailUrl || p.DataSheetUrl,
        attributes: {
          category: p.Category || "",
          rohs: p.RohsStatus || "",
          mouserPartNumber: mpn,
          datasheet: p.DataSheetUrl || "",
        },
        provider: "mouser" as const,
      };
    })
    .filter((r) => r.manufacturerPartNumber);

export const mouserSearch = async (
  input: PartSearchInput,
  limit = 8,
): Promise<PartResult[]> => {
  if (!apiKey) throw new Error("Mouser API key missing.");
  let keyword = input.partNumber?.trim() || buildKeywordQuery(input);
  // Mouser keyword endpoint performs better with concise queries; trim to first few terms.
  const tokens = keyword.split(/\s+/).filter(Boolean);
  if (tokens.length > 8) {
    keyword = tokens.slice(0, 8).join(" ");
  }
  if (keyword.length > 120) {
    keyword = keyword.slice(0, 120);
  }
  if (!keyword) throw new Error("Provide at least one search term or keyword for Mouser search.");

  const payload = {
    SearchByKeywordRequest: {
      keyword,
      records: limit,
      searchOptions: "Anywhere",
    },
  };

  const res = await fetchWithTimeout(`${baseUrl}?apiKey=${encodeURIComponent(apiKey)}`, {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify(payload),
  });

  if (!res.ok) {
    const text = await res.text();
    throw new Error(`Mouser search failed (${res.status}): ${text.slice(0, 300)}`);
  }

  const json = (await res.json()) as { SearchResults?: { Parts?: MouserPart[] } };
  const parts = json.SearchResults?.Parts || [];
  return mapParts(parts);
};
