#!/usr/bin/env python3
"""
Translation Checker Agent
Compares a natural-language requirements brief against a SysMLv2 requirements model
and reports discrepancies for refinement.

Usage:
  python pipeline/translation_checker.py --nl-file prompt.txt --sysml-file requirements.sysml \
    [--model gpt-4o-mini]

Outputs a JSON report to stdout with keys:
  - missing_requirements: list of NL clauses not expressed in SysML
  - partial_or_weakened: list of NL clauses that are present but weaker/partial in SysML
  - extraneous_sysml: SysML elements that lack grounding in the NL brief
  - coverage_notes: freeform short notes
"""

from __future__ import annotations

import argparse
import json
import os
from pathlib import Path
from typing import Any, Dict, List

import openai


def read_text(path: Path) -> str:
  return path.read_text(encoding="utf-8").strip()


def build_messages(nl: str, sysml: str) -> List[Dict[str, Any]]:
  return [
    {
      "role": "system",
      "content": [
        {
          "type": "input_text",
          "text": (
            "You are the Translation Checker. Compare the natural-language (NL) requirements "
            "against the provided SysMLv2 requirements model. Identify gaps and mismatches.\n"
            "- Treat quantitative operationalizations (adding reasonable numeric thresholds to make an NL clause testable, e.g., 'handheld' -> max mass/size) as acceptable, not extraneous, so long as they support the NL intent.\n"
            "- Flag as extraneous only features/behaviors that are not implied at all by the NL brief (e.g., UI/display, data logging, specific connectors) rather than numeric instantiations of existing NL clauses.\n"
            "- Focus on missing or weakened coverage of the original NL clauses."
          ),
        }
      ],
    },
    {
      "role": "user",
      "content": [
        {
          "type": "input_text",
          "text": (
            "NL requirements:\n"
            f"{nl}\n\n"
            "SysML model:\n"
            f"{sysml}\n\n"
            "Return JSON with fields:\n"
            "- missing_requirements: array of NL clauses not captured in SysML (be specific, short).\n"
            "- partial_or_weakened: array of clauses present but weaker/partial (cite what is missing numerically or structurally).\n"
            "- extraneous_sysml: array of SysML elements/constraints not grounded in NL.\n"
            "- coverage_notes: short string with overall coverage notes.\n"
            "Do NOT include any text outside the JSON object."
          ),
        }
      ],
    },
  ]


def run_check(nl: str, sysml: str, model: str) -> Dict[str, Any]:
  client = openai.OpenAI()
  # Use responses API to match project policy and avoid content-shape issues.
  completion = client.responses.create(
    model=model,
    input=build_messages(nl, sysml),
    max_output_tokens=1200,
  )
  # responses API returns output_text helper
  raw = getattr(completion, "output_text", None) or "{}"
  try:
    data = json.loads(raw)
  except Exception:
    data = {"parse_error": raw}
  return data


def main() -> None:
  ap = argparse.ArgumentParser(description=__doc__)
  ap.add_argument("--nl-file", type=Path, required=True, help="Path to NL prompt/brief.")
  ap.add_argument("--sysml-file", type=Path, required=True, help="Path to SysML requirements file.")
  ap.add_argument("--model", default=os.environ.get("OPENAI_MODEL", "gpt-5-mini"))
  args = ap.parse_args()

  nl = read_text(args.nl_file)
  sysml = read_text(args.sysml_file)
  report = run_check(nl, sysml, args.model)
  print(json.dumps(report, indent=2))


if __name__ == "__main__":
  main()
