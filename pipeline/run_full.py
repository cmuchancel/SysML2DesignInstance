#!/usr/bin/env python3
"""
End-to-end runner:
1) Scaffold a run from an NL brief.
2) Invoke refine_sysml.py with syside in the loop.
"""

from __future__ import annotations

import argparse
import subprocess
from pathlib import Path
from datetime import datetime

SCRIPT_DIR = Path(__file__).resolve().parent
REFINE = SCRIPT_DIR / "refine_sysml.py"
SCAFFOLD = SCRIPT_DIR / "scaffold.py"


def parse_args() -> argparse.Namespace:
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument("--nl", type=str, help="Natural-language brief (or use --nl-file).")
    p.add_argument("--nl-file", type=Path, help="File containing NL brief.")
    p.add_argument("--syside-venv", type=Path, required=True, help="Path to syside-enabled venv.")
    p.add_argument("--max-iters", type=int, default=25)
    p.add_argument("--max-total-tokens", type=int, default=60000)
    p.add_argument("--output-base", type=Path, default=SCRIPT_DIR / "runs")
    p.add_argument("--dry-run", action="store_true", help="Create scaffold only, skip refine.")
    return p.parse_args()


def run(cmd: list[str], cwd: Path | None = None) -> None:
    subprocess.run(cmd, cwd=cwd, check=True)


def main() -> None:
    args = parse_args()
    if not REFINE.exists():
        raise SystemExit(f"refine_sysml.py not found at {REFINE}")
    if not args.syside_venv.is_dir() or not (args.syside_venv / "bin/python").exists():
        raise SystemExit(f"Invalid syside venv: {args.syside_venv}")

    scaffold_cmd = [
        str(SCAFFOLD),
        "--out",
        str(args.output_base),
    ]
    if args.nl:
        scaffold_cmd.extend(["--nl", args.nl])
    elif args.nl_file:
        scaffold_cmd.extend(["--nl-file", str(args.nl_file)])
    else:
        raise SystemExit("Provide --nl or --nl-file")

    print("Scaffolding run...")
    run(scaffold_cmd)

    # Locate newest run dir
    runs = sorted((args.output_base).glob("*"), key=lambda p: p.name)
    if not runs:
        raise SystemExit("No run directory created.")
    run_dir = runs[-1]
    prompt = run_dir / "prompt.txt"
    sysml_dir = run_dir / "sysml"
    sysml_dir.mkdir(exist_ok=True)

    if args.dry_run:
        print(f"Scaffold ready at {run_dir}. Dry run: skipping refine.")
        return

    print("Running refine_sysml.py ...")
    # Run the refiner under the current pipeline interpreter. It still uses
    # the SysIDE venv for compilation via --venv, but avoids coupling LLM
    # client imports to packages installed inside that venv.
    refine_cmd = [
        sys.executable,
        str(REFINE),
        "--input",
        str(prompt),
        "--output-dir",
        str(sysml_dir),
        "--venv",
        str(args.syside_venv),
        "--max-iters",
        str(args.max_iters),
        "--max-total-tokens",
        str(args.max_total_tokens),
    ]
    run(refine_cmd)
    print(f"Done. Outputs in {sysml_dir}")


if __name__ == "__main__":
    main()
