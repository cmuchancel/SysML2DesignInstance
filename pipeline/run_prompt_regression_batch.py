#!/usr/bin/env python3
from __future__ import annotations

import argparse
import json
import os
import re
import subprocess
import sys
from pathlib import Path
from typing import Any


SCRIPT_DIR = Path(__file__).resolve().parent
MANIFEST_PATH = SCRIPT_DIR / "prompt_regression_manifest.json"
RUN_ALL_PATH = SCRIPT_DIR / "run_all.py"
RUNS_DIR = SCRIPT_DIR / "runs"


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description="Run end-to-end prompt regressions through the full SysMLtoDesignInstance pipeline.")
    parser.add_argument("--manifest", type=Path, default=MANIFEST_PATH)
    parser.add_argument("--concepts", type=int, default=1)
    parser.add_argument("--parts-per-concept", type=int, default=2)
    parser.add_argument("--search-limit", type=int, default=1)
    parser.add_argument("--max-iters", type=int, default=25)
    parser.add_argument("--max-parallel-concepts", type=int, default=1)
    parser.add_argument("--model", type=str, default=os.environ.get("OPENAI_MODEL", "gpt-5-mini"))
    parser.add_argument("--disable-configurator-validator", action="store_true", default=True)
    return parser.parse_args()


def list_runs() -> list[Path]:
    return sorted(
        [
            path
            for path in RUNS_DIR.glob("*")
            if path.is_dir() and re.fullmatch(r"\d{8}_\d{6}(?:_[a-f0-9]{4})?", path.name)
        ]
    )


def newest_new_run(before: list[Path], after: list[Path]) -> Path:
    before_names = {path.name for path in before}
    candidates = [path for path in after if path.name not in before_names]
    if candidates:
        return sorted(candidates)[-1]
    return after[-1]


def run_case(case: dict[str, Any], args: argparse.Namespace) -> dict[str, Any]:
    before = list_runs()
    cmd = [
        sys.executable,
        str(RUN_ALL_PATH),
        "--nl",
        str(case["prompt"]),
        "--concepts",
        str(args.concepts),
        "--max-parallel-concepts",
        str(args.max_parallel_concepts),
        "--parts-per-concept",
        str(args.parts_per_concept),
        "--search-limit",
        str(args.search_limit),
        "--max-iters",
        str(args.max_iters),
        "--model",
        str(args.model),
    ]
    if args.disable_configurator_validator:
        cmd.append("--disable-configurator-validator")

    proc = subprocess.run(
        cmd,
        cwd=SCRIPT_DIR.parent.parent,
        text=True,
        capture_output=True,
        env=os.environ.copy(),
    )
    after = list_runs()
    run_dir = newest_new_run(before, after)
    summary_path = run_dir / "summary_auto.json"
    summary = json.loads(summary_path.read_text(encoding="utf-8")) if summary_path.exists() else {}
    concept_status = summary.get("concept_status") or []
    feasible_concepts = [status for status in concept_status if status.get("design_feasible")]
    return {
        "id": case["id"],
        "prompt": case["prompt"],
        "returncode": proc.returncode,
        "run_dir": str(run_dir),
        "summary_path": str(summary_path) if summary_path.exists() else None,
        "concept_status": concept_status,
        "feasible_count": len(feasible_concepts),
        "ok": proc.returncode == 0 and len(feasible_concepts) > 0,
        "stdout_tail": proc.stdout[-2000:],
        "stderr_tail": proc.stderr[-2000:],
    }


def main() -> None:
    args = parse_args()
    manifest = json.loads(args.manifest.read_text(encoding="utf-8"))
    results = [run_case(case, args) for case in manifest]
    report = {
        "manifest": str(args.manifest),
        "results": results,
        "all_ok": all(result["ok"] for result in results),
    }
    print(json.dumps(report, indent=2))
    if not report["all_ok"]:
        raise SystemExit(1)


if __name__ == "__main__":
    main()
