#!/usr/bin/env python3
"""
Builds a feedback prompt for the SysML refinement agent using the translation checker output.

Usage:
  python pipeline/translation_feedback.py --nl-file prompt.txt --sysml-file requirements.sysml \
    [--model gpt-4o-mini] [--out feedback.txt]
"""

from __future__ import annotations

import argparse
import json
from pathlib import Path
from typing import Dict, Any

from translation_checker import run_check, read_text  # reuse helper


def format_feedback(report: Dict[str, Any]) -> str:
  missing = report.get("missing_requirements") or []
  partial = report.get("partial_or_weakened") or []
  extraneous = report.get("extraneous_sysml") or []
  notes = report.get("coverage_notes") or ""

  lines = ["# Translation feedback for SysML refinement"]
  if missing:
    lines.append("## Add/strengthen these requirements")
    for item in missing:
      lines.append(f"- {item}")
  if partial:
    lines.append("## Tighten these partially covered points")
    for item in partial:
      lines.append(f"- {item}")
  if extraneous:
    lines.append("## Remove or justify these SysML elements")
    for item in extraneous:
      lines.append(f"- {item}")
  if notes:
    lines.append(f"## Coverage notes\n- {notes}")
  lines.append(
    "## Instruction to model\n"
    "- Revise the SysML so every missing/partial item is explicitly represented with numeric constraints where applicable.\n"
    "- Remove or justify extraneous SysML elements.\n"
    "- Return only SysMLv2 code; keep it minimal and valid for syside."
  )
  return "\n".join(lines)


def main() -> None:
  ap = argparse.ArgumentParser(description=__doc__)
  ap.add_argument("--nl-file", type=Path, required=True)
  ap.add_argument("--sysml-file", type=Path, required=True)
  ap.add_argument("--model", default="gpt-4o-mini")
  ap.add_argument("--out", type=Path, help="Optional path to write feedback prompt.")
  args = ap.parse_args()

  nl = read_text(args.nl_file)
  sysml = read_text(args.sysml_file)
  report = run_check(nl, sysml, args.model)
  feedback = format_feedback(report)

  if args.out:
    args.out.write_text(feedback, encoding="utf-8")
  else:
    print(feedback)


if __name__ == "__main__":
  main()
