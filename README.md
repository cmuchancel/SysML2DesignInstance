# Digi-Key Resistor Finder

CLI + lightweight UI that turns human-friendly resistor requirements into a Digi-Key search. Without live credentials it falls back to a small mock catalog so you can demo the flow immediately.

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
6) (Optional) OpenAI for natural-language parsing:
   - `OPENAI_API_KEY`
   - `OPENAI_MODEL` (defaults to `gpt-4o-mini`)

## CLI
Run searches from the terminal:
```bash
USE_MOCK=1 npm run cli -- --resistance 10k --tolerance 1% --package 0603 --power 0.1W
OPENAI_API_KEY=... npm run cli -- --nl "need 10k 1% 0603 0.1W thick film"
```

## UI
```bash
npm run dev:server
# open http://localhost:3000
```
Fill the form; results render from live or mock data depending on env.

## Notes
- The live path hits Digi-Key's keyword search endpoint using OAuth2 refresh tokens.
- If credentials are absent, the code automatically switches to the bundled mock dataset so you can still exercise the flows. Replace `USE_MOCK=1` with your env vars to query Digi-Key.
