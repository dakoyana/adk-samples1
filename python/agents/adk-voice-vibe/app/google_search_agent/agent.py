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
