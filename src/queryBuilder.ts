import { PartSearchInput } from "./types.js";

const sanitize = (value: string | undefined) =>
  value?.trim().replace(/\s+/g, " ");

export const buildKeywordQuery = (input: PartSearchInput): string => {
  const parts: string[] = [];
  const category = sanitize(input.category);
  const manufacturer = sanitize(input.manufacturer);
  const partNumber = sanitize(input.partNumber);
  const value = sanitize(input.value);
  const tolerance = sanitize(input.tolerance);
  const power = sanitize(input.power);
  const voltage = sanitize(input.voltage);
  const current = sanitize(input.current);
  const pkg = sanitize(input.package);
  const tempco = sanitize(input.temperatureCoefficient);
  const material = sanitize(input.material);

  if (partNumber) parts.push(partNumber);
  if (manufacturer) parts.push(manufacturer);
  if (category) parts.push(category);
  if (value) parts.push(value);
  if (tolerance) parts.push(tolerance);
  if (power) parts.push(power);
  if (voltage) parts.push(`${voltage} volt`);
  if (current) parts.push(`${current} amp`);
  if (pkg) parts.push(pkg);
  if (tempco) parts.push(tempco);
  if (material) parts.push(material);
  if (input.features?.length) parts.push(input.features.map(sanitize).filter(Boolean).join(" "));

  if (input.keywords?.length) {
    parts.push(input.keywords.map((k) => sanitize(k)).filter(Boolean).join(" "));
  }

  if (parts.length === 0 && input.specs) {
    parts.push(
      Object.entries(input.specs)
        .map(([k, v]) => `${sanitize(k)} ${sanitize(v)}`)
        .filter(Boolean)
        .join(" "),
    );
  }

  if (input.specs) {
    parts.push(
      Object.entries(input.specs)
        .map(([k, v]) => `${sanitize(k)} ${sanitize(v)}`)
        .filter(Boolean)
        .join(" "),
    );
  }

  return parts.join(" ").trim();
};
