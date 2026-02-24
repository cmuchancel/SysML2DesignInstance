#!/usr/bin/env python3
"""Iteratively refine SysMLv2 models with gpt-5.1-codex-mini and SysIDE."""

from __future__ import annotations

import argparse
import json
import os
import subprocess
import sys
import textwrap
from datetime import datetime
from pathlib import Path
from typing import Dict, List, Optional, Tuple
from time import perf_counter

from openai import OpenAI

# Paths relative to this file so the script works from anywhere inside the repo.
SCRIPT_DIR = Path(__file__).resolve().parent


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument(
        "--input",
        required=True,
        type=Path,
        help="Path to the requirements prompt (.json or .txt).",
    )
    parser.add_argument(
        "--output-dir",
        type=Path,
        default=SCRIPT_DIR / "runs",
        help="Directory for generated SysML files and logs.",
    )
    parser.add_argument(
        "--model",
        default="gpt-5.1-codex-mini",
        help="OpenAI model identifier.",
    )
    parser.add_argument(
        "--max-iters",
        type=int,
        default=5,
        help="Number of refinement attempts to perform.",
    )
    parser.add_argument(
        "--temperature",
        type=float,
        default=None,
        help="Sampling temperature for the model (omit to use API default).",
    )
    parser.add_argument(
        "--max-total-tokens",
        type=int,
        default=50000,
        help="Stop once roughly this many LLM tokens have been consumed.",
    )
    parser.add_argument(
        "--example",
        type=Path,
        help="Optional path to an example SysML snippet to include in the prompt.",
    )
    parser.add_argument(
        "--venv",
        type=Path,
        required=True,
        help="Virtual environment root that owns the syside CLI (must contain bin/python).",
    )
    parser.add_argument(
        "--dry-run",
        action="store_true",
        help="Skip LLM and compiler calls (useful for smoke tests).",
    )
    return parser.parse_args()


def ensure_dir(path: Path) -> None:
    path.mkdir(parents=True, exist_ok=True)


def read_markdown(path: Path) -> str:
    """Lightweight markdown-to-text helper (strip fences/headings only)."""
    raw = path.read_text(encoding="utf-8").strip()
    lines: List[str] = []
    inside_fence = False
    for line in raw.splitlines():
        if line.strip().startswith("```"):
            inside_fence = not inside_fence
            continue
        if inside_fence:
            lines.append(line)
            continue
        if line.lstrip().startswith("#"):
            lines.append(line.lstrip("# ").strip())
        else:
            lines.append(line)
    return "\n".join(lines).strip()


def load_user_input(path: Path) -> str:
    suffix = path.suffix.lower()
    if suffix == ".json":
        data = json.loads(path.read_text(encoding="utf-8"))
        for candidate_key in ("prompt", "requirements", "input", "description"):
            value = data.get(candidate_key)
            if isinstance(value, str) and value.strip():
                base = value.strip()
                break
        else:
            base = json.dumps(data, indent=2, ensure_ascii=False)
        extras = data.get("extra_context") or data.get("context")
        if isinstance(extras, str) and extras.strip():
            base = f"{base}\n\nAdditional context:\n{extras.strip()}"
        return base
    if suffix == ".md":
        return read_markdown(path)
    return path.read_text(encoding="utf-8").strip()


def load_example_snippet(path: Optional[Path]) -> Optional[str]:
    if path is None:
        return None
    text = path.read_text(encoding="utf-8").strip()
    return text or None


def extract_text_from_response(response) -> str:
    text_chunks: List[str] = []
    maybe_text = getattr(response, "output_text", None)
    if isinstance(maybe_text, str) and maybe_text.strip():
        return maybe_text.strip()
    for item in getattr(response, "output", []):
        for content in getattr(item, "content", []):
            text = getattr(content, "text", None)
            if isinstance(text, str):
                text_chunks.append(text)
    return "\n".join(text_chunks).strip()


def build_prompt(
    spec_text: str,
    iteration: int,
    previous_candidate: Optional[str],
    compiler_feedback: Optional[str],
    example_text: Optional[str],
) -> str:
    sections = [
        "You are Codex, an expert SysMLv2 engineer operating inside a "
        "closed-loop synthesis pipeline.",
        textwrap.dedent(
            f"""
            USER REQUIREMENT INPUT:
            {spec_text.strip()}
            """
        ).strip(),
        "Produce valid SysMLv2 (.sysml) content using the official syntax. "
        "Do not include commentary, markdown fencing, or prose outside of the model.",
        "STRUCTURE RULES:\n"
        "- Keep requirements at the top level (use 'requirement def R {...}').\n"
        "- Constraints separate (use 'constraint def C { in x: Real; (expr) }'). NO semicolon after the expression.\n"
        "- Always use 'public import ScalarValues::*;' so Real is in scope.\n"
        "- Define only abstract/reusable design elements (blocks/parts/constraints). Do NOT emit any concrete design instances or BOM/source suggestions in this refinement stage.\n"
        "- No solution-specific values or part numbers; stay solution-agnostic.\n"
        "- Follow the TEMPLATE exactly if unsure.\n",
        "MINIMALITY: Use the fewest lines, elements, and properties possible while "
        "fully satisfying every requirement above. Avoid optional fluff, redundant "
        "packages, duplicate definitions, and unnecessary hierarchy.",
        textwrap.dedent(
            """
            TEMPLATE (copy style):
            package RequirementsOnly {
              public import ScalarValues::*;
              requirement def Req_Freq { text = "LED flickers at 10 Hz ±5%"; }
              requirement def Req_Supply { text = "Operate from 5 V supply"; }
              requirement def Req_Current { text = "Include current limiting for LED"; }
              constraint def C_Freq {
                in f: Real;
                (f >= 9.5) and (f <= 10.5)
              }
              constraint def C_Supply {
                in V: Real;
                (V >= 4.75) and (V <= 5.25)
              }
              // optional abstract blocks, no instances
              part def LED { }
              part def Driver { }
            }
            """
        ).strip(),
    ]
    if previous_candidate:
        sections.append(
            textwrap.dedent(
                f"""
                PREVIOUS ATTEMPT (iteration {iteration - 1}):
                {previous_candidate.strip()}
                """
            ).strip()
        )
    if example_text:
        sections.append(
            textwrap.dedent(
                f"""
                REFERENCE EXAMPLE SYSML SNIPPET:
                {example_text.strip()}
                """
            ).strip()
        )
    if compiler_feedback:
        sections.append(
            textwrap.dedent(
                f"""
                SYSIDE COMPILER FEEDBACK TO ADDRESS:
                {compiler_feedback.strip()}
                """
            ).strip()
        )
        sections.append(
            "Revise the earlier model to resolve the diagnostics without undoing "
            "correct structure."
        )
    sections.append("Return only the updated SysMLv2 model.")
    return "\n\n".join(section for section in sections if section)


def call_model(
    client: Optional[OpenAI], prompt: str, model: str, temperature: Optional[float]
) -> Tuple[str, Dict[str, int], Dict[str, object]]:
    if client is None:
        return (
            "# Dry run placeholder SysMLv2 model",
            {"input_tokens": 0, "output_tokens": 0, "total_tokens": 0},
            {},
        )
    request_kwargs: Dict[str, object] = {
        "model": model,
        "input": prompt,
    }
    if temperature is not None:
        request_kwargs["temperature"] = temperature

    response = client.responses.create(**request_kwargs)
    response_text = extract_text_from_response(response)
    usage = getattr(response, "usage", None)

    def usage_value(*names: str) -> int:
        for name in names:
            value = getattr(usage, name, None) if usage else None
            if value is not None:
                return int(value)
        if usage and hasattr(usage, "model_dump"):
            dump = usage.model_dump()
            for name in names:
                if name in dump:
                    return int(dump[name])
        return 0

    token_stats = {
        "input_tokens": usage_value("input_tokens", "prompt_tokens"),
        "output_tokens": usage_value("output_tokens", "completion_tokens"),
        "total_tokens": usage_value("total_tokens"),
    }
    if not token_stats["total_tokens"]:
        token_stats["total_tokens"] = (
            token_stats["input_tokens"] + token_stats["output_tokens"]
        )

    response_payload: Dict[str, object] = {}
    if hasattr(response, "model_dump"):
        response_payload = response.model_dump()

    return response_text, token_stats, response_payload


def resolve_python_executable(venv_root: Optional[Path]) -> Path:
    if not venv_root:
        raise ValueError("--venv is required so syside runs inside the correct environment.")
    venv_root = venv_root.resolve()
    python_path = (venv_root / "bin" / "python")
    if not python_path.exists():
        raise FileNotFoundError(
            f"Could not find python at {python_path}. "
            "Ensure --venv points to a valid virtual environment containing syside."
        )
    return python_path


def resolve_syside_command(python_path: Path, venv_root: Path) -> List[str]:
    """Prefer the venv's syside CLI; fall back to python -m syside."""
    venv_root = venv_root.resolve()
    syside_cli = venv_root / "bin" / "syside"
    if syside_cli.exists():
        return [str(syside_cli)]
    return [str(python_path), "-m", "syside"]


def run_syside_check(
    python_path: Path, venv_root: Optional[Path], model_path: Path
) -> subprocess.CompletedProcess:
    relative_target = model_path.name
    cmd = resolve_syside_command(python_path, venv_root.resolve()) + ["check", relative_target]
    return subprocess.run(
        cmd,
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
        text=True,
        cwd=model_path.parent,
        check=False,
    )


def assert_syside_available(python_path: Path, venv_root: Path) -> None:
    """Fail fast if syside is not available in the chosen interpreter/venv."""
    venv_root = venv_root.resolve()
    cmd = resolve_syside_command(python_path, venv_root)
    probe = subprocess.run(
        cmd + ["--version"],
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
        text=True,
        check=False,
    )
    if probe.returncode != 0:
        raise RuntimeError(
            "syside is not available in the selected venv/interpreter. "
            f"Interpreter: {python_path}\n"
            f"Command tried: {' '.join(cmd)}\n"
            f"stdout:\n{probe.stdout}\n"
            f"stderr:\n{probe.stderr}"
        )


def main() -> None:
    args = parse_args()
    ensure_dir(args.output_dir)
    timestamp_dir = args.output_dir / datetime.now().strftime("%Y%m%d-%H%M%S")
    ensure_dir(timestamp_dir)
    run_start_time = datetime.utcnow()
    run_start_wall = perf_counter()

    spec_text = load_user_input(args.input)
    example_text = load_example_snippet(args.example)
    client = None if args.dry_run else OpenAI()
    python_exe = None if args.dry_run else resolve_python_executable(args.venv)
    if not args.dry_run and python_exe is not None:
        assert_syside_available(python_exe, args.venv)

    run_log: List[Dict[str, object]] = []
    previous_candidate: Optional[str] = None
    compiler_feedback: Optional[str] = None
    tokens_consumed = 0

    for iteration in range(1, args.max_iters + 1):
        if args.max_total_tokens and tokens_consumed >= args.max_total_tokens:
            print(
                f"[stop] Token budget of {args.max_total_tokens} exhausted "
                f"(~{tokens_consumed} used)."
            )
            break
        print(f"[iter {iteration}] generating proposal...")
        iteration_start_time = datetime.utcnow()
        iteration_wall_start = perf_counter()
        prompt = build_prompt(
            spec_text=spec_text,
            iteration=iteration,
            previous_candidate=previous_candidate,
            compiler_feedback=compiler_feedback,
            example_text=example_text,
        )
        (
            candidate_text,
            token_usage,
            raw_response,
        ) = call_model(client, prompt, args.model, args.temperature)
        prompt_path = timestamp_dir / f"iteration_{iteration:02d}_prompt.txt"
        prompt_path.write_text(prompt, encoding="utf-8")
        sysml_path = timestamp_dir / f"iteration_{iteration:02d}.sysml"
        sysml_path.write_text(candidate_text, encoding="utf-8")
        response_path = timestamp_dir / f"iteration_{iteration:02d}_response.json"
        response_path.write_text(json.dumps(raw_response, indent=2), encoding="utf-8")
        tokens_consumed += token_usage.get("total_tokens", 0)
        previous_candidate = candidate_text

        compile_stdout = ""
        compile_stderr = ""
        success = False
        return_code: Optional[int] = None
        if args.dry_run:
            compile_stdout = "[dry-run] Skipping syside check."
            success = True
        else:
            print(
                f"[iter {iteration}] running 'python -m syside check {sysml_path.name}' "
                f"via {python_exe}..."
            )
            result = run_syside_check(python_exe, args.venv, sysml_path)
            compile_stdout = result.stdout.strip()
            compile_stderr = result.stderr.strip()
            return_code = result.returncode
            success = "Checks passed!" in compile_stdout and result.returncode == 0
            compiler_feedback = "\n".join(filter(None, [compile_stdout, compile_stderr]))
            print(f"[iter {iteration}] syside return code: {result.returncode}")
            if success:
                print(f"[iter {iteration}] Checks passed!")
            else:
                print(f"[iter {iteration}] Checks NOT passed (continuing).")

        iteration_end_time = datetime.utcnow()
        run_log.append(
            {
                "iteration": iteration,
                "iteration_start": iteration_start_time.isoformat() + "Z",
                "iteration_end": iteration_end_time.isoformat() + "Z",
                "iteration_duration_seconds": perf_counter() - iteration_wall_start,
                "sysml_path": str(sysml_path),
                "prompt_path": str(prompt_path),
                "response_path": str(response_path),
                "success": success,
                "compiler_stdout": compile_stdout,
                "compiler_stderr": compile_stderr,
                "return_code": return_code,
                "tokens_used_this_iter": token_usage,
                "tokens_used_total": tokens_consumed,
            }
        )

        if success:
            break

    summary_path = timestamp_dir / "run_log.json"
    summary_path.write_text(json.dumps(run_log, indent=2), encoding="utf-8")
    run_meta = {
        "run_start": run_start_time.isoformat() + "Z",
        "run_end": datetime.utcnow().isoformat() + "Z",
        "run_duration_seconds": perf_counter() - run_start_wall,
        "iterations_completed": len(run_log),
        "tokens_used_total": tokens_consumed,
    }
    (timestamp_dir / "run_meta.json").write_text(json.dumps(run_meta, indent=2), encoding="utf-8")
    print(f"[done] run details saved to {summary_path}")


if __name__ == "__main__":
    main()
