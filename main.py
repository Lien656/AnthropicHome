# -*- coding: utf-8 -*-

from kivy.app import App
from kivy.lang import Builder
from kivy.clock import Clock
from kivy.uix.boxlayout import BoxLayout
from kivy.core.window import Window
from kivy.metrics import dp

KV_FILE = "ui.kv"

Window.softinput_mode = "resize"
Window.clearcolor = (0.176, 0.176, 0.176, 1)  # #2d2d2d


class RootLayout(BoxLayout):
    pass


class AnthropicHome(App):
    def build(self):
        self.title = "AnthropicHome"
        Builder.load_file(KV_FILE)
        root = RootLayout()
        return root

    def on_send_pressed(self):
        root = self.root
        text = root.ids.message_input.text.strip()
        if not text:
            return

        root.ids.message_input.text = ""

        # bubble пользователя
        self.add_message(text, from_user=True)

        # временный ответ-заглушка (пока без API)
        Clock.schedule_once(
            lambda dt: self.add_message("…", from_user=False),
            0.2
        )

    def add_message(self, text, from_user=False):
        from kivy.factory import Factory

        bubble = Factory.ChatMessage()
        bubble.text = text

        if from_user:
            bubble.bg_color = (0.65, 0.65, 0.65, 0.82)  # #a6a6a6
            bubble.pos_hint = {"right": 1}
        else:
            bubble.bg_color = (0.33, 0.33, 0.33, 0.82)  # #545454
            bubble.pos_hint = {"left": 1}

        self.root.ids.chat_box.add_widget(bubble)
        Clock.schedule_once(lambda dt: self.scroll_down(), 0.05)

    def scroll_down(self):
        self.root.ids.scroll.scroll_y = 0


if __name__ == "__main__":
    AnthropicHome().run()