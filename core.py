# -*- coding: utf-8 -*-

from kivy.clock import Clock
from kivy.factory import Factory
import threading
import math

from memory_store import MemoryStore
from system_prompt import SYSTEM_PROMPT


MAX_CONTEXT_MESSAGES = 30
CHUNK_SIZE = 800   # символов на bubble


class ChatCore:
    def __init__(self, app):
        self.app = app
        self.root = app.root

        self.chat_box = self.root.ids.chat_box
        self.scroll = self.root.ids.scroll
        self.input_field = self.root.ids.message_input
        self.send_button = self.root.ids.send_button

        self.client = None
        self.waiting = False

        self.memory = MemoryStore(max_items=500)
        self.messages = self.memory.get_recent(limit=MAX_CONTEXT_MESSAGES)

        Clock.schedule_once(self._restore_history, 0)

    # ================= API =================

    def set_api_client(self, client):
        self.client = client

    # ================= UI =================

    def on_send_pressed(self):
        if self.waiting:
            return

        text = self.input_field.text.strip()
        if not text:
            return

        self.input_field.text = ""
        self.waiting = True
        self.send_button.disabled = True

        self._add_message_ui(text, from_user=True)

        self.memory.add("user", text)
        self.messages.append({"role": "user", "content": text})

        threading.Thread(
            target=self._request_model,
            daemon=True
        ).start()

    # ================= MODEL =================

    def _request_model(self):
        if not self.client:
            self._unlock_ui()
            return

        try:
            reply = self.client.send(
                messages=self.messages[-MAX_CONTEXT_MESSAGES:],
                system=SYSTEM_PROMPT
            )
        except Exception as e:
            Clock.schedule_once(
                lambda dt: self._add_message_ui(f"[API error]\n{e}", False)
            )
            self._unlock_ui()
            return

        if reply and reply.strip():
            self.memory.add("assistant", reply)
            self.messages.append({"role": "assistant", "content": reply})

            chunks = self._split_text(reply)
            for i, chunk in enumerate(chunks):
                Clock.schedule_once(
                    lambda dt, t=chunk: self._add_message_ui(t, False),
                    i * 0.05
                )

        self._unlock_ui()

    # ================= HELPERS =================

    def _unlock_ui(self):
        Clock.schedule_once(lambda dt: self._unlock())

    def _unlock(self):
        self.waiting = False
        self.send_button.disabled = False
        self._scroll_to_bottom()

    def _restore_history(self, dt):
        for msg in self.messages:
            self._add_message_ui(
                msg.get("content", ""),
                from_user=(msg.get("role") == "user"),
                scroll=False
            )
        self._scroll_to_bottom()

    def _add_message_ui(self, text, from_user, scroll=True):
        bubble = Factory.ChatMessage()
        bubble.text = text

        if from_user:
            bubble.bg_color = (0.65, 0.65, 0.65, 0.82)  # user
            bubble.pos_hint = {"right": 1}
        else:
            bubble.bg_color = (0.33, 0.33, 0.33, 0.82)  # AI
            bubble.pos_hint = {"left": 1}

        self.chat_box.add_widget(bubble)

        if scroll:
            Clock.schedule_once(lambda dt: self._scroll_to_bottom(), 0.05)

    def _scroll_to_bottom(self):
        self.scroll.scroll_y = 0

    def _split_text(self, text):
        if len(text) <= CHUNK_SIZE:
            return [text]

        parts = []
        current = ""

        for paragraph in text.split("\n\n"):
            if len(current) + len(paragraph) < CHUNK_SIZE:
                current += paragraph + "\n\n"
            else:
                parts.append(current.strip())
                current = paragraph + "\n\n"

        if current.strip():
            parts.append(current.strip())

        return parts

