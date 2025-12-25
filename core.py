# -*- coding: utf-8 -*-

import threading
import time
from kivy.clock import Clock
from kivy.factory import Factory

from api_anthropic import AnthropicClient, APIError
from system_prompt import SYSTEM_PROMPT, INITIATION_PROMPT
from memory_store import MemoryStore


MAX_CONTEXT_MESSAGES = 30
CHUNK_SIZE = 800          # символов на bubble
BUBBLE_DELAY = 0.06       # сек между bubble
HEARTBEAT_INTERVAL = 20   # сек (тихий пульс)


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
        self.sleeping = False

        # память
        self.memory = MemoryStore(max_items=500)
        self.messages = self.memory.get_recent(limit=MAX_CONTEXT_MESSAGES)

        # восстановление истории
        Clock.schedule_once(lambda dt: self._restore_history(), 0)

        # heartbeat
        Clock.schedule_interval(self._heartbeat, HEARTBEAT_INTERVAL)

    # -------------------------------------------------
    # API
    # -------------------------------------------------

    def set_api_key(self, api_key: str):
        self.client = AnthropicClient(api_key)

    # -------------------------------------------------
    # UI
    # -------------------------------------------------

    def on_send_pressed(self):
        if self.waiting or self.sleeping:
            return

        text = self.input_field.text.strip()
        if not text:
            return

        self.input_field.text = ""
        self.waiting = True
        self.send_button.disabled = True

        # пользователь
        self._add_message(text, from_user=True)
        self.memory.add("user", text)
        self.messages.append({"role": "user", "content": text})

        # запрос к модели — В ФОНЕ
        threading.Thread(target=self._call_model, daemon=True).start()

    # -------------------------------------------------
    # Model
    # -------------------------------------------------

    def _call_model(self):
        if not self.client:
            self._unlock()
            return

        try:
            reply = self.client.send(
                messages=self.messages[-MAX_CONTEXT_MESSAGES:],
                system=SYSTEM_PROMPT,
            )
        except APIError as e:
            Clock.schedule_once(
                lambda dt: self._add_message(f"[API error]\n{e}", from_user=False)
            )
            self._unlock()
            return

        # возможность молчать
        if not reply.strip():
            self._unlock()
            return

        self.memory.add("assistant", reply)
        self.messages.append({"role": "assistant", "content": reply})

        # дробим ответ на bubble
        chunks = self._chunk_text(reply)
        Clock.schedule_once(lambda dt: self._emit_chunks(chunks), 0)

    # -------------------------------------------------
    # Chunking
    # -------------------------------------------------

    def _chunk_text(self, text: str):
        parts = []
        buf = ""

        for paragraph in text.split("\n\n"):
            if len(buf) + len(paragraph) < CHUNK_SIZE:
                buf += paragraph + "\n\n"
            else:
                parts.append(buf.strip())
                buf = paragraph + "\n\n"

        if buf.strip():
            parts.append(buf.strip())

        return parts

    def _emit_chunks(self, chunks):
        for i, chunk in enumerate(chunks):
            Clock.schedule_once(
                lambda dt, t=chunk: self._add_message(t, from_user=False),
                i * BUBBLE_DELAY,
            )

        Clock.schedule_once(lambda dt: self._unlock(), len(chunks) * BUBBLE_DELAY + 0.05)

    # -------------------------------------------------
    # Heartbeat / Silence
    # -------------------------------------------------

    def _heartbeat(self, dt):
        if self.waiting or self.sleeping:
            return

        # тихий пульс — без сообщений
        # здесь можно писать в файл / память, если захочешь
        pass

    def sleep(self, enable=True):
        self.sleeping = enable

    # -------------------------------------------------
    # History
    # -------------------------------------------------

    def _restore_history(self):
        for msg in self.messages:
            self._add_message(
                msg.get("content", ""),
                from_user=(msg.get("role") == "user"),
                scroll=False,
            )
        self._scroll_to_bottom()

    # -------------------------------------------------
    # UI helpers
    # -------------------------------------------------

    def _add_message(self, text, from_user, scroll=True):
        bubble = Factory.ChatMessage()
        bubble.text = text

        if from_user:
            bubble.bg_color = (0.65, 0.65, 0.65, 0.82)   # пользователь
            bubble.pos_hint = {"right": 1}
        else:
            bubble.bg_color = (0.33, 0.33, 0.33, 0.82)   # Claude
            bubble.pos_hint = {"left": 1}

        self.chat_box.add_widget(bubble)

        if scroll:
            Clock.schedule_once(lambda dt: self._scroll_to_bottom(), 0.05)

    def _scroll_to_bottom(self):
        self.scroll.scroll_y = 0

    def _unlock(self):
        self.waiting = False
        self.send_button.disabled = False