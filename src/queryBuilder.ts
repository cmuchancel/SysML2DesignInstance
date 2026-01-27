import { ResistorSearchInput } from "./types.js";

const sanitize = (value: string | undefined) =>
  value?.trim().replace(/\s+/g, " ");

export const buildKeywordQuery = (input: ResistorSearchInput): string => {
  const parts: string[] = [];
  const resistance = sanitize(input.resistance);
  const tolerance = sanitize(input.tolerance);
  const power = sanitize(input.power);
  const pkg = sanitize(input.package);
  const tempco = sanitize(input.temperatureCoefficient);
  const composition = sanitize(input.composition);

  if (resistance) parts.push(`${resistance} resistor`);
  if (tolerance) parts.push(`${tolerance} tol`);
  if (power) parts.push(`${power} power`);
  if (pkg) parts.push(pkg);
  if (tempco) parts.push(`${tempco} tempco`);
  if (composition) parts.push(composition);

  if (input.keywords?.length) {
    parts.push(input.keywords.map((k) => sanitize(k)).filter(Boolean).join(" "));
  }

  return parts.join(" ").trim();
};
