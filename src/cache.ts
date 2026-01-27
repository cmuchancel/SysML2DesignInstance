import fs from "fs";
import path from "path";
import { Provider, ResistorResult } from "./types.js";

type CacheEntry = {
  provider: Provider;
  query: string;
  results: ResistorResult[];
  timestamp: number;
};

const cachePath = path.join(process.cwd(), "cache", "search-cache.json");
const ttlMinutes = Number(process.env.CACHE_TTL_MINUTES || "60");

const ensureCacheFile = () => {
  const dir = path.dirname(cachePath);
  if (!fs.existsSync(dir)) fs.mkdirSync(dir, { recursive: true });
  if (!fs.existsSync(cachePath)) fs.writeFileSync(cachePath, "[]", "utf8");
};

const loadCache = (): CacheEntry[] => {
  try {
    ensureCacheFile();
    const raw = fs.readFileSync(cachePath, "utf8");
    return JSON.parse(raw) as CacheEntry[];
  } catch {
    return [];
  }
};

const saveCache = (entries: CacheEntry[]) => {
  ensureCacheFile();
  fs.writeFileSync(cachePath, JSON.stringify(entries, null, 2), "utf8");
};

export const getCachedResults = (
  provider: Provider,
  query: string,
): ResistorResult[] | null => {
  const entries = loadCache();
  const now = Date.now();
  const ttlMs = ttlMinutes * 60 * 1000;
  const hit = entries.find(
    (e) => e.provider === provider && e.query === query && now - e.timestamp < ttlMs,
  );
  if (!hit) return null;
  if (!hit.results || hit.results.length === 0) return null;
  return hit.results;
};

export const setCachedResults = (
  provider: Provider,
  query: string,
  results: ResistorResult[],
) => {
  if (!results || results.length === 0) return;
  const entries = loadCache().filter(
    (e) => !(e.provider === provider && e.query === query),
  );
  entries.unshift({ provider, query, results, timestamp: Date.now() });
  // keep cache small
  saveCache(entries.slice(0, 50));
};
