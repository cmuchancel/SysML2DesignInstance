import { chromium, Browser } from "playwright";

let browser: Browser | null = null;

export const getBrowser = async () => {
  if (browser) return browser;
  browser = await chromium.launch({ headless: true });
  return browser;
};

const defaultTimeout = Number(process.env.HEADLESS_TIMEOUT_MS || "20000");

export const renderPage = async (url: string, timeoutMs = defaultTimeout): Promise<string> => {
  const b = await getBrowser();
  const context = await b.newContext({ userAgent: "Mozilla/5.0" });
  const page = await context.newPage();
  page.setDefaultNavigationTimeout(timeoutMs);
  await page.goto(url, { waitUntil: "domcontentloaded" });
  // Wait a moment for JS-rendered content
  await page.waitForTimeout(800);
  const html = await page.content();
  await context.close();
  return html;
};

export const shutdownBrowser = async () => {
  if (browser) {
    await browser.close();
    browser = null;
  }
};

export const renderPageAndGetLinks = async (
  url: string,
  linkSelector: string,
  limit = 3,
  timeoutMs = defaultTimeout,
): Promise<string[]> => {
  const b = await getBrowser();
  const context = await b.newContext({ userAgent: "Mozilla/5.0" });
  const page = await context.newPage();
  page.setDefaultNavigationTimeout(timeoutMs);
  await page.goto(url, { waitUntil: "domcontentloaded" });
  await page.waitForTimeout(800);
  const links = await page.$$eval(
    linkSelector,
    (nodes, max) =>
      nodes
        .slice(0, max as number)
        .map((n) => (n as HTMLAnchorElement).href)
        .filter(Boolean),
    limit,
  );
  await context.close();
  return links;
};

export const renderSinglePage = async (
  url: string,
  waitSelector?: string,
  timeoutMs = defaultTimeout,
): Promise<{ html: string | null; url: string; error?: string }> => {
  const browser = await chromium.launch({ headless: true });
  const context = await browser.newContext({ userAgent: "Mozilla/5.0" });
  const page = await context.newPage();
  page.setDefaultNavigationTimeout(timeoutMs);
  try {
    await page.goto(url, { waitUntil: "domcontentloaded" });
    await page.evaluate(() => window.scrollBy(0, window.innerHeight));
    await page.waitForTimeout(400);
    await page.evaluate(() => window.scrollBy(0, window.innerHeight * 2));
    if (waitSelector) {
      await page.waitForSelector(waitSelector, { timeout: Math.min(8000, timeoutMs - 2000) });
    } else {
      await page.waitForTimeout(800);
    }
    const html = await page.content();
    await browser.close();
    return { html, url };
  } catch (err) {
    await browser.close();
    return { html: null, url, error: (err as Error).message };
  }
};
