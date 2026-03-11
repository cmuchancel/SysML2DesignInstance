#!/usr/bin/env python3
"""
Create a run scaffold for the SysML compiler-in-loop pipeline.

Outputs:
- prompt.txt     : NL brief duplicated, ready for refine_sysml.py
- questions.md   : placeholder for Spec Guardian gaps
- concepts/      : Design Instantiator alternatives
- parts/         : Design Realizer picks
- run.json       : metadata
"""

from __future__ import annotations

import argparse
import json
import os
from datetime import datetime
from pathlib import Path
import secrets
from textwrap import dedent


def parse_args() -> argparse.Namespace:
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument("--nl", type=str, help="Natural-language brief (use instead of --nl-file).")
    p.add_argument("--nl-file", type=Path, help="Path to file with natural-language brief.")
    p.add_argument("--out", type=Path, default=Path("pipeline/runs"), help="Output base directory.")
    return p.parse_args()


def read_nl(nl: str | None, nl_file: Path | None) -> str:
    if nl:
        return nl.strip()
    if nl_file:
        return nl_file.read_text(encoding="utf-8").strip()
    raise SystemExit("Provide --nl or --nl-file")


def main() -> None:
    args = parse_args()
    brief = read_nl(args.nl, args.nl_file)

    ts = datetime.now().strftime("%Y%m%d_%H%M%S")
    run_dir = args.out / ts
    while run_dir.exists():
        run_dir = args.out / f"{ts}_{secrets.token_hex(2)}"
    concepts_dir = run_dir / "concepts"
    parts_dir = run_dir / "parts"
    sysml_dir = run_dir / "sysml"
    run_dir.mkdir(parents=True, exist_ok=True)
    concepts_dir.mkdir(parents=True, exist_ok=True)
    parts_dir.mkdir(parents=True, exist_ok=True)
    sysml_dir.mkdir(parents=True, exist_ok=True)

    prompt_path = run_dir / "prompt.txt"
    prompt_body = dedent(
        f"""
        # Natural-language brief (echoed twice per Sysmlgeneration guidance)
        {brief}

        -- repeat --
        {brief}

        # Instructions to the model (keep in prompt for refine_sysml.py)
        - Emit the minimal SysMLv2 that satisfies the brief.
        - Avoid redundant packages/properties; be concise.
        - Conform to SysIDE; model must pass `syside check`.
        - If uncertain, make the best assumption and note it in a comment.
        """
    ).strip()
    prompt_path.write_text(prompt_body + "\n", encoding="utf-8")

    questions_path = run_dir / "questions.md"
    questions_path.write_text(
        dedent(
            """\
            # Open questions / ambiguities
            - [ ] (Spec Guardian) list missing or ambiguous requirements here.
            """
        ),
        encoding="utf-8",
    )

    (concepts_dir / "README.md").write_text(
        dedent(
            """\
            Add 3–6 alternative concepts (Design Instantiator):
            - concept_01.md: description, tradeoffs (cost/complexity/performance/risk), key params.
            - concept_02.md: ...
            Keep each concept concise (≤1 page).
            """
        ),
        encoding="utf-8",
    )

    (parts_dir / "README.md").write_text(
        dedent(
            """\
            Add parts per concept (Design Realizer):
            - concept_01_parts.json (array of {name, url, specs, price, stock, provider})
            - Note "no viable part" explicitly when none found.
            """
        ),
        encoding="utf-8",
    )

    meta = {
        "brief": brief,
        "created": ts,
        "paths": {
          "prompt": str(prompt_path),
          "questions": str(questions_path),
          "concepts": str(concepts_dir),
          "parts": str(parts_dir),
          "sysml": str(sysml_dir),
        },
    }
    (run_dir / "run.json").write_text(json.dumps(meta, indent=2), encoding="utf-8")

    print(f"Scaffold created at {run_dir}")
    print(f"- prompt: {prompt_path}")
    print(f"- questions: {questions_path}")
    print(f"- concepts dir: {concepts_dir}")
    print(f"- parts dir: {parts_dir}")
    print("Next: run refine_sysml.py with --input prompt.txt and your syside venv.")


if __name__ == "__main__":
    main()
