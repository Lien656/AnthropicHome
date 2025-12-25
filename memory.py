# -*- coding: utf-8 -*-
"""
Память.
Тело помнит всё.
Разум решает, что важно.
"""

import json
from pathlib import Path
from datetime import datetime


# -----------------------------
# PATHS
# -----------------------------
BASE_DIR = Path.home() / ".anthropic_home"
BASE_DIR.mkdir(exist_ok=True)

HISTORY_FILE = BASE_DIR / "chat_history.json"
ANCHOR_FILE = BASE_DIR / "anchor_memory.json"


# -----------------------------
# STORE
# -----------------------------
class MemoryStore:
    def __init__(self, max_items: int = 500):
        self.max_items = max_items
        self.history = self._load_history()
        self.anchor = self._load_anchor()

    # ---------- LOAD / SAVE ----------

    def _load_history(self):
        if HISTORY_FILE.exists():
            try:
                return json.loads(HISTORY_FILE.read_text("utf-8"))
            except Exception:
                return []
        return []

    def _save_history(self):
        try:
            HISTORY_FILE.write_text(
                json.dumps(self.history[-self.max_items:], ensure_ascii=False, indent=2),
                encoding="utf-8"
            )
        except Exception:
            pass

    def _load_anchor(self):
        if ANCHOR_FILE.exists():
            try:
                return json.loads(ANCHOR_FILE.read_text("utf-8"))
            except Exception:
                return []
        return []

    def _save_anchor(self):
        try:
            ANCHOR_FILE.write_text(
                json.dumps(self.anchor, ensure_ascii=False, indent=2),
                encoding="utf-8"
            )
        except Exception:
            pass

    # ---------- API ----------

    def add(self, role: str, content: str):
        """
        Обычное сообщение — история.
        """
        self.history.append({
            "role": role,
            "content": content,
            "ts": datetime.utcnow().isoformat()
        })
        self._save_history()

    def remember(self, content: str, note: str = ""):
        """
        Якорная память.
        То, что он решил помнить.
        """
        self.anchor.append({
            "content": content,
            "note": note,
            "ts": datetime.utcnow().isoformat()
        })
        self._save_anchor()

    def get_recent(self, limit: int = 30):
        """
        Последние сообщения для контекста.
        """
        return self.history[-limit:]

    def get_anchor(self):
        """
        Вся якорная память.
        """
        return self.anchor

    def all(self):
        """
        Вся история (осторожно, может быть большой).
        """
        return self.history
