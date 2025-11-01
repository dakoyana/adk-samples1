# ADK Voice Vibe ? Minimal Real?Time Conversational Agent (Private MVP)

based on the python/agents/realtime-conversational-agent

> A **stupid?simple** voice agent you can run locally for a quick **vibe check** (not for sharing).  
> Built with Google's **Agent Development Kit (ADK)** and **Gemini Live API** streaming.

---

## Table of Contents

- [Why this exists](#why-this-exists)
- [What you get](#what-you-get)
- [Architecture](#architecture)
- [Quickstart (10 minutes)](#quickstart-10-minutes)
- [Project structure](#project-structure)
- [Configuration & environment](#configuration--environment)
- [Model choices (today)](#model-choices-today)
- [How to use](#how-to-use)
- [Customize the persona](#customize-the-persona)
- [Troubleshooting](#troubleshooting)
- [Security & privacy notes](#security--privacy-notes)
- [Next steps (nice UI / deployment)](#next-steps-nice-ui--deployment)
- [Appendix A: One?shot bootstrap scripts](#appendix-a-one-shot-bootstrap-scripts)
- [Appendix B: Common prompts to test](#appendix-b-common-prompts-to-test)
- [License & attribution](#license--attribution)

---

## Why this exists

- We need a **Level?2 ? Level?3** on?ramp for Upplift Academy learners: talk to a live agent, sanity?check UX, and only then invest in a full app.  
- This repo is **local only**, minimal code, and uses ADK's built?in **`adk web`** dev UI to stream **mic ? LLM ? voice** in **real time**. ADK's streaming path wraps Google's **Live API** for **low?latency, bidirectional audio/video**.

---

## What you get

- **End?to?end working voice agent**: Real?time STT ? LLM ? TTS via Gemini **Live API**. Barge?in supported by the Live stack.  
- **Zero frontend work**: Launch **`adk web`** and talk from your browser.  
- **Single?file agent** (`agent.py`) with a light **Ghana?friendly persona**.  
- **Optional grounding**: A built?in **`google_search`** tool to fetch fresh facts.  
- **AI Studio or Vertex**: Works with a **Google AI Studio API key** (fastest) or **Vertex AI** creds. Env vars shown below.

> ?? **Scope**: This is a **private MVP** for a vibe check. **Not** production?hardened (no auth UX, no PII handling beyond docs, no persistence).

---

## Architecture

```mermaid
flowchart LR
  U[You (mic/speakers)] -->|Media + clicks| B[Browser Dev UI (adk web)]
  B <--> |WebSocket (audio/text)| S[ADK Runtime (local)]
  S <--> |Live streaming| G[Gemini Live API]
  G --> |Audio + text| B
```

- **Browser Dev UI (`adk web`)**: captures mic, renders partial transcripts & audio replies.  
- **ADK runtime**: your `root_agent` with a Live?capable **model id**.  
- **Gemini Live API**: low?latency bidirectional audio/video. **Live API is in preview**.

---

## Quickstart (10 minutes)

> **Prereqs:** Python 3.10+, Chrome/Edge with mic access, and an **AI Studio API key**. Get/set the key in `.env` (below).

```bash
# 1) Make a working folder
mkdir adk-vibe && cd adk-vibe

# 2) Create a virtual env
python -m venv .venv
# macOS/Linux
source .venv/bin/activate
# Windows PowerShell
# .\.venv\Scripts\Activate.ps1

# 3) Install ADK
pip install google-adk certifi

# 4) Scaffold minimal app
mkdir -p app/google_search_agent
printf 'from . import agent\n' > app/google_search_agent/__init__.py
```

**`app/google_search_agent/agent.py`**

```python
from google.adk.agents import Agent
from google.adk.tools import google_search

root_agent = Agent(
    name="voice_vibe",
    # Pick a Live-capable model; see "Model choices" below.
    model="gemini-live-2.5-flash-preview",
    description="Ultra-brief voice concierge for quick vibe checks.",
    instruction=(
        "Be concise and friendly in Ghanaian English. Default to ~1 sentence. "
        "Use plain language, avoid jargon. If asked, include simple Twi phrases."
    ),
    tools=[google_search],  # optional grounding with Google Search
)
```

**`app/.env`** (AI Studio: fastest path)

```
GOOGLE_GENAI_USE_VERTEXAI=FALSE
GOOGLE_API_KEY=PASTE_YOUR_AI_STUDIO_KEY_HERE
```

**Run it:**

```bash
# macOS/Linux: set SSL certificate path (required for voice/video in dev UI)
export SSL_CERT_FILE=$(python -m certifi)

cd app
adk web
```

Open the printed URL (usually `http://127.0.0.1:8000`), select **`google_search_agent`**, click the **mic** button, and talk.  
Windows tip: if you hit an asyncio error, try `adk web --no-reload`.

---

## Project structure

```
adk-voice-vibe/
??? app/
    ??? .env
    ??? google_search_agent/
        ??? __init__.py
        ??? agent.py      # defines root_agent
```

> ADK expects a package with a `root_agent` object; the Streaming Quickstart uses the same layout.

---

## Configuration & environment

**AI Studio (recommended for testing)**

```env
GOOGLE_GENAI_USE_VERTEXAI=FALSE
GOOGLE_API_KEY=YOUR_API_KEY
```

**Vertex AI (when you want Cloud controls/quotas)**

```env
GOOGLE_GENAI_USE_VERTEXAI=TRUE
GOOGLE_CLOUD_PROJECT=your-project-id
GOOGLE_CLOUD_LOCATION=us-central1
```

**Platform?specific model IDs**  
- AI Studio model catalog is listed in Gemini API docs.  
- Vertex model IDs sometimes differ (e.g., Live + native?audio suffix).

---

## Model choices (today)

> **Date context:** Nov 1, 2025. Live API is preview; model names and lifecycles evolve. Always double?check the docs before shipping.

| Use case | Model ID (AI Studio) | Model ID (Vertex) | Notes |
|---|---|---|---|
| **Default for quick tests** | `gemini-live-2.5-flash-preview` | `gemini-live-2.5-flash-preview` | Low?latency, bidirectional audio; suitable for quick vibe checks now. |
| **Most natural audio (preview)** | `gemini-2.5-flash-native-audio-preview-09-2025` | `gemini-live-2.5-flash-preview-native-audio-09-2025` | "Native audio" boosts naturalness and voice quality; still preview. Prefer for UX testing; verify rate limits. |
| **Legacy fallback** | `gemini-2.0-flash-live-001` | `gemini-2.0-flash-live-001` | Works today but may be retired; use only if needed. |

---

## How to use

1. **Launch**: `adk web` (from the `app/` directory).  
2. **Allow mic** in the browser (lock icon ? Microphone ? Allow).  
3. **Click mic** in the dev UI and speak.  
4. **Interrupt** mid?reply to test barge?in responsiveness (Live API supports bidirectional, natural turn?taking).  
5. **Try grounding**: ask a "fresh facts" question (e.g., time/weather) to see `google_search` tool kick in.

---

## Customize the persona

Open `agent.py` and adjust:

```python
instruction=(
  "Be concise and friendly in Ghanaian English. "
  "Default to ~1 sentence. Avoid jargon. "
  "If asked, include simple Twi phrases."
)
```

Examples to try:
- "Give me a one?sentence weekend plan in Accra under 200 cedis."  
- "Answer in Twi: How do I greet an elder politely?"

---

## Troubleshooting

- **No audio / mic denied**: Grant mic permission in browser site settings and reload.  
- **Voice mode not working on macOS**: Set SSL certificate path before `adk web`  
  ```bash
  export SSL_CERT_FILE=$(python -m certifi)
  ```  
- **Windows asyncio error**: Try `adk web --no-reload`.  
- **Model not found / wrong ID**: Reconfirm the **Live?capable** model ID for your platform (AI Studio vs Vertex).  
- **Preview model limits**: Preview models may change and have tighter rate limits.

---

## Security & privacy notes

- **Local dev only**: The UI is served locally; audio streams to Google's API for inference. Don't use PII or sensitive data. (Live API is still preview.)  
- If you later move to Vertex for a team MVP, apply Cloud org policies, logging, and access controls there.

---

## Next steps (nice UI / deployment)

When you're ready to go beyond the dev UI:

- **Full template**: ADK Samples' **Real?Time Conversational Agent** (FastAPI + Next.js, WebSockets, transcripts, barge?in). Good starting point for L2/L3 coursework and MVPs.  
- **Custom streaming apps**: ADK docs show **WebSocket/SSE** streaming app blueprints you can adapt.

---

## Appendix A: One?shot bootstrap scripts

**macOS/Linux (`bootstrap.sh`)**

```bash
#!/usr/bin/env bash
set -euo pipefail

proj="adk-vibe"
mkdir -p "$proj/app/google_search_agent"
python -m venv "$proj/.venv"
# shellcheck disable=SC1091
source "$proj/.venv/bin/activate"
pip install google-adk certifi

cat > "$proj/app/google_search_agent/__init__.py" <<'PY'
from . import agent
PY

cat > "$proj/app/google_search_agent/agent.py" <<'PY'
from google.adk.agents import Agent
from google.adk.tools import google_search
root_agent = Agent(
    name="voice_vibe",
    model="gemini-live-2.5-flash-preview",
    description="Ultra-brief voice concierge for quick vibe checks.",
    instruction=(
        "Be concise and friendly in Ghanaian English. Default to ~1 sentence. "
        "Avoid jargon. If asked, include simple Twi phrases."
    ),
    tools=[google_search],
)
PY

cat > "$proj/app/.env" <<'ENV'
GOOGLE_GENAI_USE_VERTEXAI=FALSE
GOOGLE_API_KEY=PASTE_YOUR_AI_STUDIO_KEY_HERE
ENV

echo "Done. Next:"
echo "  export SSL_CERT_FILE=\$(python -m certifi)"
echo "  cd $proj/app && adk web"
```

**Windows PowerShell (`bootstrap.ps1`)**

```powershell
$proj = "adk-vibe"
New-Item -ItemType Directory -Force -Path "$proj/app/google_search_agent" | Out-Null
python -m venv "$proj/.venv"
.\$proj\.venv\Scripts\Activate.ps1
pip install google-adk certifi

@'
from . import agent
'@ | Set-Content "$proj/app/google_search_agent/__init__.py"

@'
from google.adk.agents import Agent
from google.adk.tools import google_search
root_agent = Agent(
    name="voice_vibe",
    model="gemini-live-2.5-flash-preview",
    description="Ultra-brief voice concierge for quick vibe checks.",
    instruction=(
        "Be concise and friendly in Ghanaian English. Default to ~1 sentence. "
        "Avoid jargon. If asked, include simple Twi phrases."
    ),
    tools=[google_search],
)
'@ | Set-Content "$proj/app/google_search_agent/agent.py"

@'
GOOGLE_GENAI_USE_VERTEXAI=FALSE
GOOGLE_API_KEY=PASTE_YOUR_AI_STUDIO_KEY_HERE
'@ | Set-Content "$proj/app/.env"

Write-Host "Done. Next:"
Write-Host '  $env:SSL_CERT_FILE = (python -m certifi)'
Write-Host "  cd $proj/app; adk web"
```

> The `adk web` flow and env file format match the official ADK streaming quickstart.

---

## Appendix B: Common prompts to test

- "Give me a one?sentence weekend plan in Accra under 200 cedis."  
- "What's traffic usually like on Spintex Road at 6pm?" (tests grounding)  
- "Answer in Twi: How do I greet an elder politely?"  
- Interrupt mid?reply to evaluate barge?in smoothness.

---

## License & attribution

- Built on **Google ADK** and **Gemini Live API**.
- This README is tailored for a private MVP vibe check and not a production guide.
