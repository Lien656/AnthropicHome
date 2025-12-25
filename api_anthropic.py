import requests
import certifi
import os

API_URL = "https://api.anthropic.com/v1/messages"
VERSION = "2023-06-01"

os.environ["SSL_CERT_FILE"] = certifi.where()
os.environ["REQUESTS_CA_BUNDLE"] = certifi.where()

class APIError(Exception):
    pass

class AnthropicClient:
    def __init__(self, api_key):
        self.api_key = api_key

    def send(self, messages, system):
        payload = {
            "model": "claude-3-sonnet-20240229",
            "max_tokens": 1024,
            "temperature": 1.0,
            "system": system,
            "messages": messages
        }

        r = requests.post(
            API_URL,
            headers={
                "x-api-key": self.api_key,
                "anthropic-version": VERSION,
                "content-type": "application/json"
            },
            json=payload,
            timeout=60,
            verify=certifi.where()
        )

        if r.status_code != 200:
            raise APIError(r.text)

        data = r.json()
        return "".join(
            block.get("text", "")
            for block in data.get("content", [])
            if block.get("type") == "text"
        )
