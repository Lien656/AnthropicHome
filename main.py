,
from kivy.app import App
from kivy.uix.boxlayout import BoxLayout
from kivy.uix.label import Label
from kivy.clock import Clock

from core import Core

class Root(BoxLayout):
    pass

class AnthropicHome(App):
    def build(self):
        self.core = Core()
        return Root()

    def send(self):
        text = self.root.ids.inp.text.strip()
        if not text:
            return
        self.root.ids.inp.text = ""

        self.add(text, True)
        reply = self.core.think(text)
        if reply:
            self.add(reply, False)

    def add(self, text, user):
        lbl = Label(
            text=text,
            size_hint_y=None,
            halign="left",
            valign="top"
        )
        lbl.bind(
            width=lambda *_: setattr(lbl, "text_size", (lbl.width, None)),
            texture_size=lambda *_: setattr(lbl, "height", lbl.texture_size[1])
        )
        self.root.ids.chat.add_widget(lbl)
        Clock.schedule_once(lambda dt: setattr(self.root.ids.scroll, "scroll_y", 0))

if __name__ == "__main__":
    AnthropicHome().run()
