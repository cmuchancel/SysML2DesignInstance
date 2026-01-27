import { buildKeywordQuery } from "./queryBuilder.js";
import { PartResult, PartSearchInput } from "./types.js";
import { fetchWithTimeout } from "./http.js";

type AccessToken = {
  token: string;
  expiresAt: number;
};

const env = process.env;
const clientId = env.DIGIKEY_CLIENT_ID;
const clientSecret = env.DIGIKEY_CLIENT_SECRET;
const refreshToken = env.DIGIKEY_REFRESH_TOKEN;
const baseUrl = env.DIGIKEY_BASE_URL || "https://api.digikey.com";

const hasCredentials = Boolean(clientId && clientSecret && refreshToken);

let cachedToken: AccessToken | null = null;

const nowSeconds = () => Math.floor(Date.now() / 1000);

const fetchAccessToken = async (): Promise<string> => {
  if (cachedToken && cachedToken.expiresAt - 60 > nowSeconds()) {
    return cachedToken.token;
  }

  const body = new URLSearchParams({
    client_id: clientId || "",
    client_secret: clientSecret || "",
    refresh_token: refreshToken || "",
    grant_type: "refresh_token",
  });

  const response = await fetchWithTimeout(`${baseUrl}/v1/oauth2/token`, {
    method: "POST",
    headers: {
      "Content-Type": "application/x-www-form-urlencoded",
      Accept: "application/json",
    },
    body,
  });

  if (!response.ok) {
    const text = await response.text();
    throw new Error(
      `Unable to refresh Digi-Key token (${response.status}): ${text}`,
    );
  }

  const json = (await response.json()) as {
    access_token: string;
    expires_in: number;
  };

  cachedToken = {
    token: json.access_token,
    expiresAt: nowSeconds() + json.expires_in,
  };

  return cachedToken.token;
};

const headersForRequest = async () => {
  const token = await fetchAccessToken();
  return {
    Authorization: `Bearer ${token}`,
    "X-DIGIKEY-Client-Id": clientId || "",
    "X-DIGIKEY-Locale-Site": env.DIGIKEY_LOCALE_SITE || "US",
    "X-DIGIKEY-Locale-Language": env.DIGIKEY_LOCALE_LANG || "en",
    "X-DIGIKEY-Locale-Currency": env.DIGIKEY_LOCALE_CURRENCY || "USD",
    Accept: "application/json",
    "Content-Type": "application/json",
  };
};

const mapProductsToResults = (
  products: any[] | undefined,
): PartResult[] => {
  if (!Array.isArray(products)) return [];
  return products
    .map((p) => {
      const attributes: Record<string, string> = {};
      if (Array.isArray(p.Parameters)) {
        for (const param of p.Parameters) {
          if (param.Parameter && param.Value) {
            attributes[param.Parameter] = param.Value;
          }
        }
      }

      return {
        manufacturer: p.Manufacturer?.Value || p.Manufacturer?.Name || "Unknown",
        manufacturerPartNumber: p.ManufacturerPartNumber || "",
        digiKeyPartNumber: p.DigiKeyPartNumber || p.DigiKeyPartNumberFormatted,
        description: p.ProductDescription,
        stock: Number(p.QuantityAvailable) || undefined,
        unitPrice: Number(p.UnitPrice) || undefined,
        url: p.PrimaryPhoto?.ImageUrl || p.DigitalUrl || p.ProductUrl,
        attributes,
        provider: "digikey" as const,
      } as PartResult;
    })
    .filter((item) => item.manufacturerPartNumber);
};

export const digikeyKeywordSearch = async (
  input: PartSearchInput,
  limit = 10,
): Promise<PartResult[]> => {
  if (!hasCredentials) {
    throw new Error("Digi-Key credentials are missing.");
  }

  const query = buildKeywordQuery(input);
  if (!query) throw new Error("Provide at least one search term or keyword for Digi-Key search.");
  const headers = await headersForRequest();
  const payload = {
    Keywords: query,
    RecordCount: limit,
    RecordStartPosition: 0,
    Sort: [
      {
        Field: "QuantityAvailable",
        Direction: "Descending",
      },
    ],
    Filters: [],
  };

  const response = await fetchWithTimeout(`${baseUrl}/Search/v3/Products/Keyword`, {
    method: "POST",
    headers,
    body: JSON.stringify(payload),
  });

  if (!response.ok) {
    const text = await response.text();
    throw new Error(
      `Digi-Key search failed (${response.status}): ${text.slice(0, 500)}`,
    );
  }

  const data = (await response.json()) as { Products?: any[] };
  return mapProductsToResults(data.Products);
};

export const digikeyAvailable = hasCredentials;
