import json
from pathlib import Path
from datetime import datetime

DATA_DIR = Path.home() / ".anthropic_home"
DATA_DIR.mkdir(exist_ok=True)
MEMORY_FILE = DATA_DIR / "memory.json"

class Memory:
    def __init__(self):
        self.data = self._load()

    def _load(self):
        if MEMORY_FILE.exists():
            try:
                return json.loads(MEMORY_FILE.read_text("utf-8"))
            except:
                return []
        return []

    def add(self, role, text):
        self.data.append({
            "role": role,
            "text": text,
            "ts": datetime.utcnow().isoformat()
        })
        self.save()

    def save(self):
        MEMORY_FILE.write_text(
            json.dumps(self.data, ensure_ascii=False, indent=2),
            encoding="utf-8"
        )

    def recent(self, n=30):
        return self.data[-n:]
