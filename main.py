# -*- coding: utf-8 -*-

from kivy.app import App
from kivy.lang import Builder
from kivy.uix.boxlayout import BoxLayout
from kivy.core.window import Window

# 🔒 фикс крашей без логов
import sys, traceback
def excepthook(exctype, value, tb):
    try:
        with open("/sdcard/anthropic_crash.log", "w") as f:
            f.write("".join(traceback.format_exception(exctype, value, tb)))
    except:
        pass
sys.excepthook = excepthook

Window.clearcolor = (0.18, 0.18, 0.18, 1)


class RootLayout(BoxLayout):
    pass


class AnthropicHome(App):
    def build(self):
        Builder.load_file("ui.kv")
        return RootLayout()


if __name__ == "__main__":
    AnthropicHome().run()