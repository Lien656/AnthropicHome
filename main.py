from kivy.app import App
from kivy.lang import Builder
from kivy.uix.label import Label
from kivy.uix.boxlayout import BoxLayout
from kivy.clock import Clock
from kivy.core.text import LabelBase
from pathlib import Path
import json

from core import ChatCore

LabelBase.register(
    name="Emoji",
    fn_regular="NotoColorEmoji-Regular.ttf"
)

KV = Path("ui.kv").read_text("utf-8")

CONFIG = Path.home() / ".anthropic_home" / "config.json"
CONFIG.parent.mkdir(exist_ok=True)

class AnthropicHome(App):
    def build(self):
        self.root = Builder.load_string(KV)
        self.core = ChatCore(self)

        if CONFIG.exists():
            key = json.loads(CONFIG.read_text()).get("api_key")
            if key:
                self.core.set_api_key(key)

        return self.root

    def add_message(self, text, user):
        lbl = Label(
            text=text,
            size_hint_y=None,
            halign="left",
            valign="top"
        )
        lbl.bind(texture_size=lambda *_: setattr(lbl, "height", lbl.texture_size[1]))
        self.root.ids.chat_box.add_widget(lbl)
        Clock.schedule_once(lambda _: setattr(self.root.ids.scroll, "scroll_y", 0))

    def on_send(self):
        text = self.root.ids.input.text.strip()
        if not text:
            return
        self.root.ids.input.text = ""
        self.core.send(text)

if __name__ == "__main__":
    AnthropicHome().run()
