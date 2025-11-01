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
