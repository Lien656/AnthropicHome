# -*- coding: utf-8 -*-
"""
Минимальный клиент Anthropic API.
Стабильный. Без стрима. Без лишней магии.
"""

import requests
import os

API_URL = "https://api.anthropic.com/v1/messages"
API_VERSION = "2023-06-01"


# -----------------------------
# SSL FIX (Android)
# -----------------------------
try:
    import certifi
    os.environ["SSL_CERT_FILE"] = certifi.where()
    os.environ["REQUESTS_CA_BUNDLE"] = certifi.where()
    SSL_VERIFY = certifi.where()
except Exception:
    SSL_VERIFY = True


# -----------------------------
# ERRORS
# -----------------------------
class APIError(Exception):
    pass


# -----------------------------
# CLIENT
# -----------------------------
class Anthropic:
    def __init__(self, api_key: str):
        self.api_key = api_key

    # -------- LOW LEVEL --------

    def _post(self, payload: dict):
        headers = {
            "x-api-key": self.api_key,
            "anthropic-version": API_VERSION,
            "content-type": "application/json"
        }

        try:
            r = requests.post(
                API_URL,
                headers=headers,
                json=payload,
                timeout=120,
                verify=SSL_VERIFY
            )
        except requests.exceptions.SSLError:
            r = requests.post(
                API_URL,
                headers=headers,
                json=payload,
                timeout=120,
                verify=False
            )

        if r.status_code != 200:
            try:
                err = r.json()
                msg = err.get("error", {}).get("message", r.text[:200])
            except Exception:
                msg = r.text[:200]
            raise APIError(f"{r.status_code}: {msg}")

        return r.json()

    # -------- PUBLIC --------

    class messages:
        @staticmethod
        def create(
            *,
            model: str,
            messages: list,
            system: str = "",
            temperature: float = 1.0,
            max_tokens: int = 4000
        ):
            payload = {
                "model": model,
                "messages": messages,
                "temperature": temperature,
                "max_tokens": max_tokens
            }

            if system:
                payload["system"] = system

            data = Anthropic._instance._post(payload)
            return Response(data)

    # internal singleton trick
    def __enter__(self):
        Anthropic._instance = self
        return self

    def __exit__(self, exc_type, exc, tb):
        Anthropic._instance = None


# -----------------------------
# RESPONSE
# -----------------------------
class Response:
    def __init__(self, data: dict):
        self.data = data
        self.content = [Content(c) for c in data.get("content", [])]
        self.model = data.get("model", "")
        self.stop_reason = data.get("stop_reason", "")
        self.usage = data.get("usage", {})


class Content:
    def __init__(self, data: dict):
        self.type = data.get("type", "text")
        self.text = data.get("text", "")
