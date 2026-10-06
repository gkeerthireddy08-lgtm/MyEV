# MyEV

An EV charging companion for India. It finds compatible chargers, compares options, decides whether to wait at a busy charger or switch, plans highway trips, and answers questions through an AI assistant running on NVIDIA's API (build.nvidia.com). The app works in English, Hindi, Telugu, Tamil, Kannada, Marathi and Bengali.

This folder is the complete software: a Node.js server with a database, accounts and the API, plus the app it serves.

---

## 1. Run it on your computer (5 minutes)

**You need:** Node.js **22.13 or newer** (https://nodejs.org, the "LTS" download). Nothing else to install: the server uses only Node's built-in features.

**Windows:** double-click **`Start MyEV.cmd`**. It creates `.env` from `.env.example` the first time and opens the app. After changing `.env`, double-click **`Restart MyEV.cmd`**.

**Any system:**
```bash
# in this folder
cp .env.example .env        # Windows: copy .env.example .env
npm start
```

Open **http://localhost:8080** in your browser. The terminal shows what's running:

```
MyEV is running at http://localhost:8080
  Chatbot   : NVIDIA (meta/llama-3.3-70b-instruct)
  Stations  : demo data (Hyderabad)
  ...
```

Chargers, places, routes and weather use built-in demo data for Hyderabad. Without an NVIDIA key, the chatbot falls back to a simple built-in assistant.

### Try every feature without keys

```bash
npm run demo:full
```
This starts MyEV with every feature switched on, using local stand-ins for the NVIDIA chatbot, Open Charge Map, Google and OpenWeather that answer in each real service's format. The chatbot stand-in picks the right tool and summarises its result in English; it's not the real model. It ignores your `.env` (your key is never used) and has its own database (`data/full-stack-demo.sqlite`). Use it to click through every screen; use `npm start` with your key for the real chatbot.

## 2. Add your chatbot key

`.env` holds only the chatbot settings. Open it in any text editor (Notepad is fine), put your key after `NVIDIA_API_KEY=`, save, and restart.

| Setting | What it does | Default |
|---|---|---|
| `NVIDIA_API_KEY` | Your key from **build.nvidia.com** → any model → *Get API Key* (starts with `nvapi-`). Required for the AI chatbot. | none: built-in assistant |
| `NVIDIA_MODEL` | Which model answers. It must support tool calling. | `meta/llama-3.3-70b-instruct` |
| `NVIDIA_MAX_TOKENS` | Longest reply, in tokens. | `1024` |
| `NVIDIA_THINKING` | `on` lets reasoning models (Nemotron, Qwen3 and similar) think before answering. Slower and uses more tokens; their thinking is never shown to the user. | `off` |

The key stays on the server. The browser only learns *that* the chatbot is on and which model it uses (`/api/config`), never the key.

<details><summary>Optional settings that are not in <code>.env</code></summary>

The server also understands these. Add a line to `.env` only if you need one; everything works without them.

| Setting | Use |
|---|---|
| `PORT`, `HOST` | Port (default `8080`) and who can connect (default `127.0.0.1`, this computer only; `0.0.0.0` lets phones on your Wi-Fi open `http://<your-computer's-IP>:8080`). |
| `OPENCHARGEMAP_API_KEY` | Real charger listings across India instead of the Hyderabad demo stations. |
| `GOOGLE_MAPS_SERVER_KEY` | Google place search and traffic-aware routes instead of demo places and distance estimates. |
| `WEATHER_API_KEY` | OpenWeather temperature instead of the assumed 34 °C. |
| `GOOGLE_OAUTH_CLIENT_ID`, `GOOGLE_OAUTH_CLIENT_SECRET`, `PUBLIC_URL` | Google sign-in. |
| `ANTHROPIC_API_KEY`, `ANTHROPIC_MODEL`, `AI_PROVIDER` | Use Claude for the chatbot instead. If both keys are set, `AI_PROVIDER=nvidia` or `anthropic` picks one. |
| `DATABASE_FILE`, `SESSION_DAYS`, `TRUST_PROXY` | Database location, sign-in length, and proxy setting for hosting. |

</details>

## 3. How it's built

```
public/index.html        The app (one page). Talks to the server when served by it;
                         opened on its own it runs in demo mode.
server/index.js          HTTP server: serves the app + JSON API, security headers, rate limits
server/config.js         Reads .env, reports which features are live
server/db.js             SQLite database (data/myev.sqlite, created automatically)
server/auth.js           Accounts: scrypt-hashed passwords, HttpOnly session cookies, Google sign-in
server/chat.js           The assistant: NVIDIA chat completions (or Claude) + tools (below)
server/engine.js         Arrival battery, charge time, cost, ranking, stay-or-switch, trip plans
server/providers/        stations.js (Open Charge Map + demo + driver reports), geo.js (Google places/routes, weather)
server/data/demo.js      Demo stations, places, vehicles and highway corridors
i18n/                    Translation tables (also embedded in public/index.html)
tests/                   Automated tests with stand-in services (no real keys needed)
```

**The assistant** gets every fact from tools, so it doesn't invent availability or prices:
`search_stations`, `get_station`, `estimate_arrival`, `stay_or_switch`, `plan_trip`, `get_vehicle_status`, `get_charging_history`, `get_weather`. It replies in the user's chosen language and labels estimates as estimates.

**API** (all JSON, under `/api`): `config`, `health`, `auth/signup|login|logout|me|forgot`, `auth/google/start|callback`, `profile` (GET/PUT), `history` (GET/POST), `account` (DELETE), `stations`, `stations/:id`, `reports` (POST), `places`, `route`, `weather`, `chat` (POST).

**Security:** passwords hashed with scrypt; sessions in HttpOnly SameSite cookies (Secure when `PUBLIC_URL` is https); cross-site write requests rejected; rate limits on sign-in, reports, routes, station/place/weather lookups and chat (by connection address; `X-Forwarded-For` only with `TRUST_PROXY=1`); Google sign-in state bound to the browser; request size limits; browser input to the assistant is validated and clamped; Content-Security-Policy on the app.

## 4. Tests

```bash
npm test
```
Runs 33 end-to-end tests against real server instances (demo mode, every provider switched on, and the NVIDIA chatbot) using stand-in services. Tests never read your `.env`, so your key is never used. They cover accounts, profiles, history, deleting an account, cross-site protection, Open Charge Map mapping, driver reports, Google places/routes, weather, the full NVIDIA and Claude tool loops (including hiding a reasoning model's thinking), rejected and placeholder keys, and regression checks for bad input (malformed addresses, wrong data types, oversized requests).

Optional browser walkthrough (needs Playwright): `npm i -D playwright && npx playwright install chromium && node tests/browser-walkthrough.js`

Check translations: `python3 tools/check-translations.py`

## Troubleshooting

| You see | Fix |
|---|---|
| `MyEV needs Node.js 22.13 or newer` | Install the current LTS from nodejs.org, then `npm start` again. |
| `EADDRINUSE` / address already in use | Another program uses port 8080. Set `PORT=8081` in `.env`. |
| Startup says `Chatbot : not set up` | `NVIDIA_API_KEY` in `.env` is empty, or still says `nvapi-your-key-here`. Paste your real key and restart. |
| Chatbot says the NVIDIA key was rejected | Check `NVIDIA_API_KEY` in `.env` (starts with `nvapi-`, no spaces or quotes) and restart. Keys can be revoked on build.nvidia.com. |
| Chatbot says the model wasn't found | Check `NVIDIA_MODEL` against the model ID on build.nvidia.com, or delete that line to use the default. |
| Chatbot replies but never looks anything up | The model doesn't support tool calling. Use one that does, such as the default. |
| Chatbot says the answer ran past the length limit | Raise `NVIDIA_MAX_TOKENS` (for example `2048`), or keep `NVIDIA_THINKING` off. |
| Map says demo stations only cover Hyderabad | Expected: chargers are demo data for Hyderabad only. |
| Changes to `.env` do nothing | The server reads `.env` only at start. Double-click `Restart MyEV.cmd` (or stop it with Ctrl+C and run `npm start` again). |

Server problems are printed in the terminal window where `npm start` runs, prefixed like `[chat]`, `[stations]` or `[api]`.

## 5. Putting it online

Any host that runs Node 22 works (Render, Railway, Fly.io, a VPS). A `Dockerfile` is included.
1. Set `NVIDIA_API_KEY` (and `NVIDIA_MODEL` if you changed it) in the host's environment settings, plus `HOST=0.0.0.0` and `PUBLIC_URL=https://your-domain`. If the host puts a proxy or load balancer in front of the app (Render, Railway, Fly.io and most others do), also set `TRUST_PROXY=1` so rate limits see each visitor's real address. The Docker image never contains `.env` or `data/` (see `.dockerignore`).
2. Give the `data/` folder persistent storage, or the database resets on every deploy.
3. Serve over HTTPS (most hosts do this automatically).

## 6. Not finished yet

- **Password-reset emails:** the reset screen works, but no email is sent until an email provider is wired into `server/index.js` (`/api/auth/forgot`).
- **Sign in with Apple:** needs an Apple Developer account. The button says it isn't set up.
- **Live charger availability:** Open Charge Map gives listings, not live free/busy status. Live status needs the UEI / Unified Bharat e-Charge network or charger-operator data agreements. Until then, status comes from driver reports and is labelled as such.
- **Amenities and prices** are often missing from Open Charge Map. The app says when it doesn't know.
- **Live battery from the car** needs partnerships with car makers. Manual battery entry works fully.
- **Highway trip planner** still uses the demo corridor stations.
- **Mobile app stores:** this is a web app. It can be installed from the phone's browser ("Add to Home Screen"). A React Native app can reuse the same server and API.
- **Translations** are drafts and need review by native speakers.
- **Scale:** SQLite and in-memory rate limits suit one server. For many users, move to Postgres and a shared cache.
