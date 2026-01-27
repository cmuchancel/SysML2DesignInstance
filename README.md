# Resistor Finder

CLI + lightweight UI that turns human-friendly resistor requirements into supplier searches. Prefers live APIs (Mouser, Octopart/Nexar, Digi-Key), but can now fall back to a web-search scraper to reach suppliers without APIs. Without any live path it uses a small mock catalog so you can demo immediately.

## Setup
1) Install deps: `npm install`
2) (Optional) Provide Digi-Key API credentials:
   - `DIGIKEY_CLIENT_ID`
   - `DIGIKEY_CLIENT_SECRET`
   - `DIGIKEY_REFRESH_TOKEN`
   - `DIGIKEY_BASE_URL` (defaults to `https://api.digikey.com`)
   - Locale (optional): `DIGIKEY_LOCALE_SITE`, `DIGIKEY_LOCALE_LANG`, `DIGIKEY_LOCALE_CURRENCY`
   - Leave `USE_MOCK=1` to stay on mock data.
3) (Optional) Octopart (simpler alternative to Digi-Key):
   - `OCTOPART_API_KEY`
   - `OCTOPART_BASE_URL` (defaults to `https://octopart.com/api/v4/endpoint`)
4) (Optional) Nexar (Octopart GraphQL, works with a bearer token):
   - `NEXAR_TOKEN`
   - `NEXAR_GRAPHQL_URL` (defaults to `https://api.nexar.com/graphql`)
5) (Optional) Mouser:
   - `MOUSER_API_KEY`
   - `MOUSER_BASE_URL` (defaults to `https://api.mouser.com/api/v1/search/keyword`)
   - Set `DISABLE_OCTOPART=1` if you want to force Mouser to be tried before any Octopart/Nexar calls.
6) (Optional) Web search scraper (DuckDuckGo HTML):
   - Enabled by default; set `DISABLE_WEB_SEARCH=1` to turn it off.
   - Optional: `WEB_SEARCH_USER_AGENT` to customize the UA string.
7) (Optional) OpenAI for natural-language parsing:
   - `OPENAI_API_KEY`
   - `OPENAI_MODEL` (defaults to `gpt-4o-mini`)

## CLI
Run searches from the terminal:
```bash
USE_MOCK=1 npm run cli -- --resistance 10k --tolerance 1% --package 0603 --power 0.1W
OPENAI_API_KEY=... npm run cli -- --nl "need 10k 1% 0603 0.1W thick film"
# Try the web-scrape path (hits DuckDuckGo and supplier pages):
DISABLE_WEB_SEARCH=0 npm run test:web
```

## UI
```bash
npm run dev:server
# open http://localhost:3000
```
Fill the form; results render from live or mock data depending on env.

## Notes
- Provider priority: Web search scraper → Mouser → Octopart/Nexar → Digi-Key → Mock.
- The web search scraper uses DuckDuckGo's HTML results to surface supplier listings even when no API is available. It caches results on disk (`cache/search-cache.json`) like the other providers.
- The live Digi-Key path uses OAuth2 refresh tokens.
- If credentials are absent and web search is disabled, the code automatically switches to the bundled mock dataset so you can still exercise the flows. Replace `USE_MOCK=1` with your env vars to query live sources.
