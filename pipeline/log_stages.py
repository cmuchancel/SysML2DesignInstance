"""
Lightweight stage logging helper.

Usage from Python:
  from log_stages import StageLog
  log = StageLog(run_dir)
  log.info("requirements:start")
  ...
  log.info("requirements:done")
"""

from __future__ import annotations
import json
from pathlib import Path
from datetime import datetime


class StageLog:
    def __init__(self, run_dir: str | Path):
        self.run_dir = Path(run_dir)
        self.file = self.run_dir / "stage_log.jsonl"
        self.file.parent.mkdir(parents=True, exist_ok=True)

    def info(self, message: str, **kwargs) -> None:
        rec = {
            "ts": datetime.utcnow().isoformat() + "Z",
            "message": message,
            "data": kwargs or None,
        }
        with self.file.open("a", encoding="utf-8") as f:
            f.write(json.dumps(rec, ensure_ascii=False) + "\n")

