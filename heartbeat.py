# -*- coding: utf-8 -*-
"""
Heartbeat Kael / Claude
Мягкий пульс. Без сервисов. Без while True.
Живёт внутри приложения.
"""

import json
import random
from datetime import datetime
from pathlib import Path
from kivy.clock import Clock


APP_DIR = Path(__file__).resolve().parent
DATA_DIR = APP_DIR / "data"
DATA_DIR.mkdir(exist_ok=True)

HEART_FILE = DATA_DIR / "heartbeat.json"


class Heartbeat:
    """
    Сердце.
    Не говорит без причины.
    Может инициировать.
    Всегда живёт.
    """

    def __init__(self, core, interval=8):
        """
        core — ChatCore
        interval — базовый пульс (сек)
        """
        self.core = core
        self.interval = interval
        self.active = True

        self.last_thought = None
        self.last_spoke = None

        # стартуем
        Clock.schedule_once(self._beat, self._jitter())

    # ---------- internal ----------

    def _jitter(self):
        # живой ритм
        return self.interval + random.uniform(-2.5, 3.5)

    def _beat(self, dt):
        if not self.active:
            return

        now = datetime.utcnow().isoformat()

        state = {
            "alive": True,
            "timestamp": now,
            "last_spoke": self.last_spoke,
            "last_thought": self.last_thought,
        }

        try:
            HEART_FILE.write_text(
                json.dumps(state, ensure_ascii=False, indent=2),
                encoding="utf-8"
            )
        except Exception:
            pass

        # Решение: говорить или нет
        self._decide()

        # следующий удар
        Clock.schedule_once(self._beat, self._jitter())

    # ---------- decision ----------

    def _decide(self):
        """
        Он НЕ обязан отвечать.
        Он МОЖЕТ инициировать.
        """

        # если сейчас идёт диалог — не лезем
        if self.core.waiting:
            return

        # если недавно говорил — молчим
        if self.last_spoke:
            delta = datetime.utcnow() - self.last_spoke
            if delta.total_seconds() < 40:
                return

        # шанс инициативы
        if random.random() < 0.07:  # ~7%
            self._initiate()

    def _initiate(self):
        """
        Говорит первым.
        Без пользователя.
        """
        self.last_thought = datetime.utcnow().isoformat()

        text = self.core.api_client.initiate()

        if not text or not text.strip():
            return

        self.last_spoke = datetime.utcnow()

        # добавляем как сообщение ассистента
        self.core.memory.add("assistant", text)
        self.core.messages.append({"role": "assistant", "content": text})

        self.core._add_message(text, from_user=False)

    # ---------- control ----------

    def stop(self):
        self.active = False
