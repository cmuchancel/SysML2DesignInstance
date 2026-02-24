import { chromium } from "playwright";

const defaultTimeout = Number(process.env.HEADLESS_TIMEOUT_MS || "12000");

export type RenderResult = {
  html: string | null;
  url: string;
  error?: string;
};

export const renderSinglePage = async (url: string, waitSelector?: string): Promise<RenderResult> => {
  const browser = await chromium.launch({ headless: true });
  const context = await browser.newContext({ userAgent: "Mozilla/5.0" });
  const page = await context.newPage();
  page.setDefaultNavigationTimeout(defaultTimeout);
  try {
    await page.goto(url, { waitUntil: "domcontentloaded" });
    // gentle scroll to trigger lazy content
    await page.evaluate(() => window.scrollBy(0, window.innerHeight));
    if (waitSelector) {
      await page.waitForSelector(waitSelector, { timeout: 4000 });
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
