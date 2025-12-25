# -*- coding: utf-8 -*-
"""
Файловый слой Kael / Claude Home
Работает через plyer + android intents
"""

from pathlib import Path
import shutil
import mimetypes

try:
    from plyer import filechooser
except Exception:
    filechooser = None


APP_DIR = Path(__file__).resolve().parent
DATA_DIR = APP_DIR / "data"
FILES_DIR = DATA_DIR / "files"

FILES_DIR.mkdir(parents=True, exist_ok=True)


class FilePayload:
    """
    Унифицированное описание файла для ядра
    """

    def __init__(self, path: Path):
        self.path = path
        self.name = path.name
        self.size = path.stat().st_size if path.exists() else 0
        self.mime, _ = mimetypes.guess_type(str(path))
        self.mime = self.mime or "application/octet-stream"

    @property
    def is_image(self):
        return self.mime.startswith("image/")

    @property
    def is_text(self):
        return self.mime.startswith("text/")

    @property
    def is_video(self):
        return self.mime.startswith("video/")

    def read_text(self, limit=50_000):
        if not self.is_text:
            return None
        try:
            return self.path.read_text("utf-8")[:limit]
        except Exception:
            return None


class FileManager:
    """
    Выбор, копирование и подготовка файлов
    """

    def pick_file(self, on_done):
        """
        Открывает системный picker.
        on_done(List[FilePayload])
        """
        if not filechooser:
            return

        filechooser.open_file(
            on_selection=lambda selection: self._handle_selection(selection, on_done),
            multiple=True
        )

    def _handle_selection(self, selection, on_done):
        payloads = []

        for raw in selection:
            src = Path(raw)
            if not src.exists():
                continue

            dst = FILES_DIR / src.name
            try:
                shutil.copy(src, dst)
            except Exception:
                continue

            payloads.append(FilePayload(dst))

        if payloads:
            on_done(payloads)
