# -*- coding: utf-8 -*-
"""
Core логика чата.
UI ↔ Core ↔ API
Без магии. Без шаблонов. Без ассистентской хуйни.
"""

from kivy.clock import Clock
from kivy.factory import Factory
from kivy.metrics import dp

from api_anthropic import Anthropic, APIError
from system_prompt import SYSTEM_PROMPT, INITIATION_PROMPT
from memory import MemoryStore


# ===== НАСТРОЙКИ =====

MAX_CONTEXT_MESSAGES = 30
CHUNK_SIZE = 700        # символов в одном bubble
CHUNK_DELAY = 0.08      # задержка между bubble


class ChatCore:
    def __init__(self, app):
        self.app = app
        self.root = app.root

        self.chat_box = self.root.ids.chat_box
        self.scroll = self.root.ids.scroll
        self.input_field = self.root.ids.message_input

        self.client = None
        self.waiting = False

        self.memory = MemoryStore(max_items=500)
        self.messages = self.memory.get_recent(limit=MAX_CONTEXT_MESSAGES)

        # восстановление истории
        Clock.schedule_once(lambda dt: self._restore_history(), 0)

    # -------------------------------------------------
    # API
    # -------------------------------------------------

    def set_api_key(self, api_key: str):
        self.client = Anthropic(api_key)

    # -------------------------------------------------
    # UI ACTIONS
    # -------------------------------------------------

    def on_send(self):
        if self.waiting:
            return

        text = self.input_field.text.strip()
        if not text:
            return

        self.input_field.text = ""
        self.waiting = True

        self._add_message(text, from_user=True)

        self.memory.add("user", text)
        self.messages.append({"role": "user", "content": text})

        Clock.schedule_once(lambda dt: self._request_model(), 0.1)

    # -------------------------------------------------
    # MODEL
    # -------------------------------------------------

    def _request_model(self):
        if not self.client:
            self._unlock()
            return

        try:
            response = self.client.messages.create(
                model="claude-3-5-sonnet-20240620",
                messages=self.messages,
                system=SYSTEM_PROMPT,
                temperature=1.0,
                max_tokens=4000
            )
        except APIError as e:
            self._add_message(str(e), from_user=False)
            self._unlock()
            return

        text = self._extract_text(response)

        # он имеет право молчать
        if not text.strip():
            self._unlock()
            return

        self.memory.add("assistant", text)
        self.messages.append({"role": "assistant", "content": text})

        self._emit_chunks(text)
        self._unlock()

    # -------------------------------------------------
    # RESPONSE HANDLING
    # -------------------------------------------------

    def _extract_text(self, response):
        parts = []
        for c in response.content:
            if c.type == "text":
                parts.append(c.text)
        return "".join(parts)

    def _emit_chunks(self, text: str):
        chunks = self._split_text(text)

        delay = 0.0
        for chunk in chunks:
            Clock.schedule_once(
                lambda dt, t=chunk: self._add_message(t, from_user=False),
                delay
            )
            delay += CHUNK_DELAY

    def _split_text(self, text: str):
        chunks = []
        buf = ""

        for paragraph in text.split("\n\n"):
            if len(buf) + len(paragraph) < CHUNK_SIZE:
                buf += paragraph + "\n\n"
            else:
                chunks.append(buf.strip())
                buf = paragraph + "\n\n"

        if buf.strip():
            chunks.append(buf.strip())

        return chunks

    # -------------------------------------------------
    # UI HELPERS
    # -------------------------------------------------

    def _add_message(self, text: str, from_user: bool):
        bubble = Factory.ChatMessage()
        bubble.text = text

        if from_user:
            bubble.bg_color = (0.65, 0.65, 0.65, 0.85)   # пользователь
            bubble.pos_hint = {"right": 1}
        else:
            bubble.bg_color = (0.30, 0.30, 0.30, 0.85)   # Claude
            bubble.pos_hint = {"left": 1}

        self.chat_box.add_widget(bubble)
        Clock.schedule_once(lambda dt: self._scroll_down(), 0.05)

    def _scroll_down(self):
        self.scroll.scroll_y = 0

    def _unlock(self):
        self.waiting = False

    # -------------------------------------------------
    # HISTORY
    # -------------------------------------------------

    def _restore_history(self):
        for msg in self.messages:
            self._add_message(
                msg.get("content", ""),
                from_user=(msg.get("role") == "user")
            )

        self._scroll_down()
