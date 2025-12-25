from kivy.clock import Clock
from kivy.factory import Factory
import threading

from memory import MemoryStore
from api_anthropic import AnthropicClient
from system_prompt import SYSTEM_PROMPT

MAX_CONTEXT = 30
CHUNK = 700

class ChatCore:
    def __init__(self, app):
        self.app = app
        self.client = None
        self.memory = MemoryStore()

    def set_api_key(self, key):
        self.client = AnthropicClient(key)

    def send(self, text):
        self.memory.add("user", text)
        self.app.add_message(text, True)

        threading.Thread(
            target=self._ask,
            args=(text,),
            daemon=True
        ).start()

    def _ask(self, _):
        if not self.client:
            self.app.add_message("Нет API ключа.", False)
            return

        msgs = self.memory.recent(MAX_CONTEXT)
        try:
            reply = self.client.send(msgs, SYSTEM_PROMPT)
        except Exception as e:
            Clock.schedule_once(lambda _: self.app.add_message(str(e), False))
            return

        self.memory.add("assistant", reply)
        for part in self._split(reply):
            Clock.schedule_once(lambda _, p=part: self.app.add_message(p, False))

    def _split(self, text):
        return [text[i:i+CHUNK] for i in range(0, len(text), CHUNK)]

