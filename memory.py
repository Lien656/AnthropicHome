import json
from pathlib import Path
from datetime import datetime

DATA_DIR = Path.home() / ".anthropic_home"
DATA_DIR.mkdir(exist_ok=True)
FILE = DATA_DIR / "memory.json"

class MemoryStore:
    def __init__(self, max_items=500):
        self.max_items = max_items
        self.data = self._load()

    def _load(self):
        if FILE.exists():
            try:
                return json.loads(FILE.read_text("utf-8"))
            except:
                pass
        return []

    def add(self, role, content):
        self.data.append({
            "role": role,
            "content": content,
            "ts": datetime.now().isoformat()
        })
        self.data = self.data[-self.max_items:]
        FILE.write_text(json.dumps(self.data, ensure_ascii=False, indent=2), "utf-8")

    def recent(self, limit=30):
        return self.data[-limit:]
