import { chromium, Browser } from "playwright";

let browser: Browser | null = null;

export const getBrowser = async () => {
  if (browser) return browser;
  browser = await chromium.launch({ headless: true });
  return browser;
};

export const renderPage = async (url: string, timeoutMs = 12000): Promise<string> => {
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
