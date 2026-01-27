import { PartResult } from "./types.js";

type NormalizedSpecs = {
  mpn?: string;
  manufacturer?: string;
  value?: string;
  voltage?: string;
  current?: string;
  power?: string;
  tolerance?: string;
  package?: string;
  dimensions?: string;
  thread?: string;
  material?: string;
  finish?: string;
  length?: string;
  diameter?: string;
  notes?: string[];
};

const normalizeText = (s?: string) => s?.toLowerCase().replace(/\s+/g, " ").trim();

const patterns = {
  voltage: /\b(\d+(?:\.\d+)?\s*(?:v|volt))\b/i,
  current: /\b(\d+(?:\.\d+)?\s*(?:a|amp))\b/i,
  power: /\b(\d+(?:\.\d+)?\s*(?:w|watt))\b/i,
  tolerance: /\b(±?\d+(?:\.\d+)?\s*%)\b/i,
  package: /\b(qfn\d+|soic-\d+|tssop-\d+|sot-23|0603|0402|0805|1206|smt|smd)\b/i,
  thread: /\b(M\d+(?:\.\d+)?(?:\s*x\s*\d+(?:\.\d+)?)?)\b/i,
  length: /\b(\d+(?:\.\d+)?\s*(?:mm|cm|in|inch))\b/i,
  diameter: /\b(\d+(?:\.\d+)?\s*(?:mm|cm|in|inch))\b/i,
};

export const extractSpecs = (item: PartResult): NormalizedSpecs => {
  const text = normalizeText(
    [
      item.manufacturerPartNumber,
      item.description,
      ...Object.values(item.attributes || {}),
    ]
      .filter(Boolean)
      .join(" "),
  );

  const specs: NormalizedSpecs = {
    mpn: item.manufacturerPartNumber,
    manufacturer: item.manufacturer,
  };

  const match = (re: RegExp) => (text ? text.match(re)?.[1] : undefined);

  specs.voltage = match(patterns.voltage);
  specs.current = match(patterns.current);
  specs.power = match(patterns.power);
  specs.tolerance = match(patterns.tolerance);
  specs.package = match(patterns.package);
  const thread = match(patterns.thread);
  if (thread) specs.thread = thread;
  const length = match(patterns.length);
  if (length) specs.length = length;
  const diameter = match(patterns.diameter);
  if (diameter) specs.diameter = diameter;

  const attrs = item.attributes || {};
  if (attrs.material) specs.material = attrs.material;
  if (attrs.finish) specs.finish = attrs.finish;
  if (attrs.value) specs.value = attrs.value;
  if (attrs.voltage && !specs.voltage) specs.voltage = attrs.voltage;
  if (attrs.current && !specs.current) specs.current = attrs.current;
  if (attrs.power && !specs.power) specs.power = attrs.power;
  if (attrs.package && !specs.package) specs.package = attrs.package;
  if (attrs.thread && !specs.thread) specs.thread = attrs.thread;
  if (attrs.length && !specs.length) specs.length = attrs.length;
  if (attrs.diameter && !specs.diameter) specs.diameter = attrs.diameter;

  return specs;
};

export const specsToAttributes = (specs: NormalizedSpecs): Record<string, string> => {
  const out: Record<string, string> = {};
  Object.entries(specs).forEach(([k, v]) => {
    if (!v) return;
    if (Array.isArray(v)) return;
    out[k] = v;
  });
  return out;
};
