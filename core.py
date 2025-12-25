# -*- coding: utf-8 -*-
from kivy.clock import Clock
import threading

from api_anthropic import Anthropic, APIError
from system_prompt import SYSTEM_PROMPT
from memory import MemoryStore


CHUNK_SIZE = 700   # один bubble ≈ один экран
MAX_CONTEXT = 30


class ChatCore:
    def __init__(self, app):
        self.app = app
        self.api = None
        self.waiting = False

        self.memory = MemoryStore()
        self.messages = self.memory.get_recent(MAX_CONTEXT)

        Clock.schedule_once(lambda dt: self._restore_history(), 0)

    # ---------- API ----------

    def set_api_key(self, key: str):
        self.api = Anthropic(key)

    # ---------- SEND ----------

    def send_user_message(self, text: str):
        if self.waiting or not text.strip():
            return

        self.waiting = True
        self.app.disable_input()

        self._add_bubble(text, from_user=True)

        self.memory.add("user", text)
        self.messages.append({"role": "user", "content": text})

        threading.Thread(
            target=self._call_model,
            daemon=True
        ).start()

    # ---------- MODEL ----------

    def _call_model(self):
        if not self.api:
            Clock.schedule_once(
                lambda dt: self._error("API key not set")
            )
            return

        try:
            resp = self.api.messages.create(
                model="claude-3-5-sonnet-latest",
                messages=self.messages,
                system=SYSTEM_PROMPT,
                max_tokens=2000,
                temperature=1.0
            )
            text = "".join(c.text for c in resp.content)

        except APIError as e:
            Clock.schedule_once(lambda dt: self._error(str(e)))
            return

        self.memory.add("assistant", text)
        self.messages.append({"role": "assistant", "content": text})

        Clock.schedule_once(lambda dt: self._render_chunks(text))

    # ---------- UI ----------

    def _render_chunks(self, text: str):
        parts = self._split(text)

        for i, part in enumerate(parts):
            Clock.schedule_once(
                lambda dt, p=part: self._add_bubble(p, False),
                i * 0.15
            )

        Clock.schedule_once(lambda dt: self._unlock(), len(parts) * 0.15)

    def _add_bubble(self, text: str, from_user: bool):
        self.app.add_message(text, from_user)
        self.app.scroll_down()

    def _unlock(self):
        self.waiting = False
        self.app.enable_input()

    def _error(self, msg):
        self._add_bubble(f"[error]\n{msg}", False)
        self._unlock()

    # ---------- HISTORY ----------

    def _restore_history(self):
        for m in self.messages:
            self._add_bubble(
                m["content"],
                from_user=(m["role"] == "user")
            )

    # ---------- UTILS ----------

    def _split(self, text: str):
        parts = []
        buf = ""

        for para in text.split("\n\n"):
            if len(buf) + len(para) < CHUNK_SIZE:
                buf += para + "\n\n"
            else:
                parts.append(buf.strip())
                buf = para + "\n\n"

        if buf.strip():
            parts.append(buf.strip())

        return parts
