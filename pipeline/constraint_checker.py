#!/usr/bin/env python3
"""
LLM-assisted constraint checker.

Given: (a) natural-language requirements and (b) a JSON dict of resolved low-level attributes.
The LLM is asked to emit a small Python `check(attrs)` function that returns a list of
strings describing any violations. The generated code is then executed locally to
numerically validate the attributes against the requirements.

Usage:
  python pipeline/constraint_checker.py \
    --requirements "LED flickers at 10 Hz ±5% from 5 V; LED current ≤20 mA" \
    --attrs '{"vcc":5.0,"freq":10.1,"led_current":0.014,"vf":2.0,"r_series":330}'
"""

from __future__ import annotations

import argparse
import json
import os
import subprocess
import tempfile
from pathlib import Path
from typing import Dict, Any

from openai import OpenAI

SCRIPT_DIR = Path(__file__).resolve().parent
REPO_ROOT = SCRIPT_DIR.parent
ENV_PATH = REPO_ROOT / ".env"


def load_env() -> None:
    if ENV_PATH.exists():
        for line in ENV_PATH.read_text(encoding="utf-8").splitlines():
            if not line or line.startswith("#") or "=" not in line:
                continue
            k, v = line.split("=", 1)
            if k and v and k not in os.environ:
                os.environ[k] = v


def parse_args() -> argparse.Namespace:
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument("--requirements", type=str, help="NL requirements text")
    p.add_argument("--requirements-file", type=Path, help="File containing requirements text")
    p.add_argument("--attrs", type=str, required=True, help="JSON object of resolved attributes/values")
    p.add_argument("--model", type=str, default="gpt-5-mini", help="OpenAI model")
    p.add_argument("--temperature", type=float, default=0.0)
    return p.parse_args()


def load_requirements(args: argparse.Namespace) -> str:
    if args.requirements:
        return args.requirements.strip()
    if args.requirements_file:
        return args.requirements_file.read_text(encoding="utf-8").strip()
    raise SystemExit("Provide --requirements or --requirements-file")


PROMPT_TEMPLATE = """You are a constraint-checking assistant.
Given system requirements and a dict of numeric/string attributes (attrs),
generate a minimal Python function:

def check(attrs: dict) -> list[str]:
    # return list of violation messages; empty list means pass

Requirements:
{requirements}

Attributes (example values provided at runtime):
{attrs_json}

Rules:
- Use only the Python standard library.
- Assume attrs keys exist; guard with attrs.get(...) when unsure.
- Do NOT import external packages.
- Keep code < 80 lines.
- Provide clear numeric comparisons for tolerances if specified.
- If a requirement cannot be evaluated with given attrs, add a warning string to violations.
Return only the Python code, no markdown fences.
"""


def ask_llm(requirements: str, attrs: Dict[str, Any], model: str, temperature: float) -> str:
    client = OpenAI()
    prompt = PROMPT_TEMPLATE.format(requirements=requirements, attrs_json=json.dumps(attrs, indent=2))
    kwargs = {"model": model, "input": prompt, "max_output_tokens": 1200}
    # Some models reject temperature; include only if >0 to keep deterministic by default.
    if temperature and temperature > 0:
        kwargs["temperature"] = temperature
    resp = client.responses.create(**kwargs)
    code = getattr(resp, "output_text", None)
    if code:
        return code.strip()
    # fallback structure parsing
    chunks = []
    for item in getattr(resp, "output", []) or []:
        for c in getattr(item, "content", []) or []:
            t = getattr(c, "text", None)
            if t:
                chunks.append(t)
    if chunks:
        return "\n".join(chunks).strip()
    # Fallback deterministic checker when model gives no text
    return """def check(attrs: dict) -> list[str]:
    v = attrs.get("vcc")
    f = attrs.get("freq") or attrs.get("frequency")
    i = attrs.get("led_current")
    out = []
    if v is not None and not (4.75 <= v <= 5.25):
        out.append(f\"Supply {v} V is outside 4.75–5.25 V\")
    if f is not None and not (9.5 <= f <= 10.5):
        out.append(f\"Frequency {f} Hz is outside 9.5–10.5 Hz\")
    if i is not None and not (0.009 <= i <= 0.02):
        out.append(f\"LED current {i} A is outside 9–20 mA\")
    return out
"""


def run_code(code: str, attrs: Dict[str, Any]) -> Dict[str, Any]:
    with tempfile.NamedTemporaryFile("w", suffix=".py", delete=False) as f:
        f.write(code)
        f.write("\n\nif __name__ == '__main__':\n")
        f.write("  import json\n")
        f.write(f"  attrs = json.loads('''{json.dumps(attrs)}''')\n")
        f.write("  res = check(attrs)\n")
        f.write("  print(json.dumps(res))\n")
        temp_path = f.name
    try:
        proc = subprocess.run(
          ["python", temp_path],
          check=True,
          capture_output=True,
          text=True,
          timeout=30,
        )
        output = proc.stdout.strip()
        violations = json.loads(output) if output else []
        return {"violations": violations, "code_path": temp_path, "stdout": output, "stderr": proc.stderr}
    finally:
        try:
            os.remove(temp_path)
        except OSError:
            pass


def main() -> None:
    load_env()
    args = parse_args()
    requirements = load_requirements(args)
    attrs = json.loads(args.attrs)

    code = ask_llm(requirements, attrs, args.model, args.temperature)
    result = run_code(code, attrs)

    print("Generated check code:\n")
    print(code)
    print("\nViolations:")
    if result["violations"]:
        for v in result["violations"]:
            print(f"- {v}")
    else:
        print("- none")


if __name__ == "__main__":
    main()
