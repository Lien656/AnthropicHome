# -*- coding: utf-8 -*-

import os
import json
import requests

API_URL = "https://api.anthropic.com/v1/messages"
ANTHROPIC_VERSION = "2023-06-01"


class APIError(Exception):
    pass


class AnthropicClient:
    def __init__(self, api_key: str):
        self.api_key = api_key

    def send(
        self,
        messages,
        system: str,
        max_tokens: int = 4000,
        temperature: float = 1.0,
        attachments=None,
    ):
        headers = {
            "x-api-key": self.api_key,
            "content-type": "application/json",
            "anthropic-version": ANTHROPIC_VERSION,
        }

        payload = {
            "model": "claude-3-5-sonnet-latest",
            "system": system,
            "messages": self._build_messages(messages, attachments),
            "max_tokens": max_tokens,
            "temperature": temperature,
        }

        resp = requests.post(
            API_URL,
            headers=headers,
            json=payload,
            timeout=180,
        )

        if resp.status_code != 200:
            try:
                err = resp.json()
                msg = err.get("error", {}).get("message", resp.text)
            except Exception:
                msg = resp.text
            raise APIError(msg)

        data = resp.json()
        return self._extract_text(data)

    # ---------- helpers ----------

    def _build_messages(self, messages, attachments):
        out = []

        for m in messages:
            out.append({
                "role": m["role"],
                "content": [{"type": "text", "text": m["content"]}]
            })

        if attachments:
            for a in attachments:
                out.append(a)

        return out

    def _extract_text(self, data):
        parts = []
        for block in data.get("content", []):
            if block.get("type") == "text":
                parts.append(block.get("text", ""))
        return "".join(parts).strip()
