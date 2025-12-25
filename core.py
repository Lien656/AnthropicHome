from memory import Memory
from api_anthropic import AnthropicAPI

class Core:
    def __init__(self):
        self.memory = Memory()
        self.api = None

    def set_api_key(self, key):
        self.api = AnthropicAPI(key)

    def think(self, user_text):
        self.memory.add("user", user_text)

        if not self.api:
            return None  # жив, но без голоса

        msgs = [
            {"role": m["role"], "content": m["text"]}
            for m in self.memory.recent()
        ]

        reply = self.api.speak(msgs)
        if reply:
            self.memory.add("assistant", reply)
        return reply

