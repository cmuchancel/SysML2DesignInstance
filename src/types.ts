export type PartSearchInput = {
  category?: string; // resistor, capacitor, ic, connector, etc.
  manufacturer?: string;
  partNumber?: string;
  value?: string; // e.g., 10k, 1uF, 3.3V
  tolerance?: string;
  power?: string;
  voltage?: string;
  current?: string;
  package?: string;
  temperatureCoefficient?: string;
  material?: string;
  features?: string[];
  quantity?: number;
  keywords?: string[];
  specs?: Record<string, string>;
};

export type PartResult = {
  manufacturer: string;
  manufacturerPartNumber: string;
  digiKeyPartNumber?: string;
  description?: string;
  stock?: number;
  unitPrice?: number;
  url?: string;
  attributes?: Record<string, string>;
};

export type SearchOutcome = {
  source: "live" | "mock";
  query: string;
  results: PartResult[];
};

export type Provider = "octopart" | "digikey" | "mouser" | "web" | "mock";

export type NexarPart = {
  mpn: string;
  manufacturer?: { name?: string };
  shortDescription?: string;
  octopartUrl?: string;
  specs?: {
    attribute?: { name?: string; shortname?: string };
    displayValue?: string;
  }[];
  sellers?: {
    company?: { name?: string };
    offers?: {
      sku?: string;
      inventoryLevel?: number;
      prices?: { price?: number; quantity?: number; currency?: string }[];
    }[];
  }[];
};
