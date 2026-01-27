export type ResistorSearchInput = {
  resistance?: string;
  tolerance?: string;
  power?: string;
  package?: string;
  temperatureCoefficient?: string;
  composition?: string;
  quantity?: number;
  keywords?: string[];
};

export type ResistorResult = {
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
  results: ResistorResult[];
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
