# -*- coding: utf-8 -*-
from pathlib import Path
import json

from kivy.app import App
from kivy.lang import Builder
from kivy.clock import Clock
from kivy.core.window import Window
from kivy.uix.popup import Popup
from kivy.uix.boxlayout import BoxLayout
from kivy.uix.textinput import TextInput
from kivy.uix.button import Button
from kivy.uix.label import Label

from core import ChatCore


# -----------------------------
# PATHS
# -----------------------------
APP_DIR = Path.home() / ".anthropic_home"
APP_DIR.mkdir(exist_ok=True)
CONFIG_FILE = APP_DIR / "config.json"


# -----------------------------
# UI
# -----------------------------
Builder.load_file("ui.kv")

Window.softinput_mode = "pan"
Window.clearcolor = (0.11, 0.11, 0.11, 1)


class RootLayout(BoxLayout):
    pass


# -----------------------------
# APP
# -----------------------------
class AnthropicHome(App):

    def build(self):
        self.root = RootLayout()
        self.core = ChatCore(self)

        Clock.schedule_once(lambda dt: self._init_api(), 0)
        return self.root

    # ---------- API KEY ----------

    def _init_api(self):
        key = self._load_key()
        if key:
            self.core.set_api_key(key)
        else:
            self._ask_key()

    def _ask_key(self):
        box = BoxLayout(orientation="vertical", padding=12, spacing=10)

        txt = Label(
            text="Введите Anthropic API key\n(сохранится локально)",
            size_hint_y=None,
            height=60
        )

        inp = TextInput(
            multiline=False,
            password=True,
            hint_text="sk-ant-...",
            size_hint_y=None,
            height=44
        )

        btn = Button(
            text="Сохранить",
            size_hint_y=None,
            height=44
        )

        box.add_widget(txt)
        box.add_widget(inp)
        box.add_widget(btn)

        popup = Popup(
            title="API key",
            content=box,
            size_hint=(0.85, 0.45),
            auto_dismiss=False
        )

        def save_key(*a):
            key = inp.text.strip()
            if key:
                self._save_key(key)
                self.core.set_api_key(key)
                popup.dismiss()

        btn.bind(on_release=save_key)
        popup.open()

    def _save_key(self, key: str):
        CONFIG_FILE.write_text(
            json.dumps({"api_key": key}),
            encoding="utf-8"
        )

    def _load_key(self):
        if CONFIG_FILE.exists():
            try:
                return json.loads(CONFIG_FILE.read_text("utf-8")).get("api_key")
            except Exception:
                return None
        return None

    # ---------- UI hooks ----------

    def on_send(self):
        text = self.root.ids.message_input.text
        self.root.ids.message_input.text = ""
        self.core.send_user_message(text)

    def add_message(self, text: str, from_user: bool):
        from kivy.factory import Factory
        bubble = Factory.ChatMessage()
        bubble.text = text

        if from_user:
            bubble.bg_color = (0.65, 0.65, 0.65, 0.85)
            bubble.pos_hint = {"right": 1}
        else:
            bubble.bg_color = (0.30, 0.30, 0.30, 0.85)
            bubble.pos_hint = {"left": 1}

        self.root.ids.chat_box.add_widget(bubble)

    def scroll_down(self):
        Clock.schedule_once(
            lambda dt: setattr(self.root.ids.scroll, "scroll_y", 0),
            0.05
        )

    def disable_input(self):
        self.root.ids.send_button.disabled = True

    def enable_input(self):
        self.root.ids.send_button.disabled = False


# -----------------------------
if __name__ == "__main__":
    AnthropicHome().run()
