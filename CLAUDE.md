# MyEV — notes for Claude Code

MyEV is an EV charging companion for India (Hyderabad demo data). Zero-dependency Node.js 22.13+ server
(`server/`), single-page front end (`public/index.html`), SQLite via `node:sqlite`, 7 languages (`i18n/`).

- Run: `npm start` → http://localhost:8080 · Full stand-in demo: `npm run demo:full` · Tests: `npm test`
- Chatbot: NVIDIA API catalog (OpenAI-style chat completions with tool calling) in `server/chat.js` (`chatNvidia`).
  `.env` holds only `NVIDIA_API_KEY`, `NVIDIA_MODEL`, `NVIDIA_MAX_TOKENS`; other features run on demo data.
  Claude (Anthropic) support still exists in the code as an option but isn't configured.
- API keys live only in `.env` (server side). Never print, commit, or send them to the browser.
  Tests and `demo:full` set `MYEV_ENV_FILE` to a missing file so they never read the real `.env`.
- After editing `.env` or server code on Windows: double-click `Restart MyEV.cmd`.
- Estimates (arrival charge, wait, cost) are always shown as estimates with their reasoning, never as guarantees.
- Every new user-facing string goes through `t()` and needs entries in all 7 languages.

## Project skills (in `.claude/skills/`)

Use these when the task matches:

| Task | Skill |
|---|---|
| Chatbot / tool-calling safety, prompt injection, `server/chat.js` changes | `ai-security` |
| Auth, sessions, cookies, rate limits, OWASP review of `server/` | `security-pen-testing` |
| Anything touching `.env`, `.env.example`, keys, or secret leakage | `env-secrets-manager` |
| Chatbot cost and speed: model choice, tool-loop steps, max tokens, prompt size | `llm-cost-optimizer` |
| Accessibility of `public/index.html` (contrast, ARIA, keyboard, screen readers) | `a11y-audit` |
| Writing or fixing browser tests (`tests/browser-walkthrough.js`) | `playwright-pro` |
| General code review before a release or zip | `code-reviewer` |
| `Dockerfile` / container deployment | `docker-development` |

The skills' helper scripts need Python 3 (standard library only).
