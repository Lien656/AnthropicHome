# -*- coding: utf-8 -*-

import threading
import json
from pathlib import Path

from kivy.app import App
from kivy.lang import Builder
from kivy.clock import Clock
from kivy.uix.popup import Popup
from kivy.uix.boxlayout import BoxLayout
from kivy.uix.textinput import TextInput
from kivy.uix.button import Button
from kivy.metrics import dp
from kivy.core.window import Window

from core import ChatCore
from api_anthropic import Anthropic, APIError

# -----------------------------
# PATHS
# -----------------------------
DATA_DIR = Path.home() / ".claude_home"
DATA_DIR.mkdir(exist_ok=True)
CONFIG_FILE = DATA_DIR / "config.json"

# -----------------------------
# WINDOW
# -----------------------------
Window.clearcolor = (0.176, 0.176, 0.176, 1)
Window.softinput_mode = "pan"

# -----------------------------
# APP
# -----------------------------
class ClaudeHome(App):

    def build(self):
        self.root = Builder.load_file("ui.kv")
        self.core = ChatCore(self)
        Clock.schedule_once(lambda dt: self._init_api(), 0)
        return self.root

    # ---------- API KEY ----------
    def _init_api(self):
        key = self._load_key()
        if not key:
            self._ask_key()
        else:
            self.core.set_client(Anthropic(key))

    def _load_key(self):
        if CONFIG_FILE.exists():
            try:
                return json.loads(CONFIG_FILE.read_text("utf-8")).get("api_key")
            except:
                pass
        return None

    def _save_key(self, key):
        CONFIG_FILE.write_text(
            json.dumps({"api_key": key}, ensure_ascii=False, indent=2),
            encoding="utf-8"
        )

    def _ask_key(self):
        box = BoxLayout(orientation="vertical", padding=dp(12), spacing=dp(10))
        inp = TextInput(
            hint_text="Anthropic API key",
            multiline=False,
            size_hint_y=None,
            height=dp(44)
        )
        btn = Button(text="Сохранить", size_hint_y=None, height=dp(44))

        box.add_widget(inp)
        box.add_widget(btn)

        popup = Popup(
            title="API ключ",
            content=box,
            size_hint=(0.9, 0.4),
            auto_dismiss=False
        )

        def save(*a):
            key = inp.text.strip()
            if key:
                self._save_key(key)
                self.core.set_client(Anthropic(key))
                popup.dismiss()

        btn.bind(on_release=save)
        popup.open()


if __name__ == "__main__":
    ClaudeHome().run()