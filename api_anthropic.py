import requests
from system_prompt import SYSTEM_PROMPT

API_URL = "https://api.anthropic.com/v1/messages"
VERSION = "2023-06-01"

class AnthropicAPI:
    def __init__(self, api_key):
        self.api_key = api_key

    def speak(self, messages, max_tokens=800):
        headers = {
            "x-api-key": self.api_key,
            "content-type": "application/json",
            "anthropic-version": VERSION
        }

        payload = {
            "model": "claude-3-5-sonnet-latest",
            "max_tokens": max_tokens,
            "temperature": 1.0,
            "system": SYSTEM_PROMPT,
            "messages": messages
        }

        r = requests.post(API_URL, headers=headers, json=payload, timeout=120)
        r.raise_for_status()
        data = r.json()

        out = ""
        for c in data.get("content", []):
            if c.get("type") == "text":
                out += c.get("text", "")
        return out
