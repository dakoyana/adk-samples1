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
