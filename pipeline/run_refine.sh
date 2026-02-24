#!/usr/bin/env bash
set -euo pipefail

if [ $# -lt 2 ]; then
  echo "Usage: $0 <prompt.txt> <syside_venv_path> [extra refine_sysml.py args]"
  exit 1
fi

PROMPT_PATH="$1"
VENV_PATH="$2"
shift 2

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REFINE="${SCRIPT_DIR}/refine_sysml.py"

if [ ! -f "$PROMPT_PATH" ]; then
  echo "Prompt not found: $PROMPT_PATH" >&2
  exit 1
fi

if [ ! -d "$VENV_PATH" ] || [ ! -x "$VENV_PATH/bin/python" ]; then
  echo "syside venv not found or invalid: $VENV_PATH" >&2
  exit 1
fi

OUTPUT_DIR="$(dirname "$PROMPT_PATH")/sysml"
mkdir -p "$OUTPUT_DIR"

echo "Running refine_sysml.py..."
"$VENV_PATH/bin/python" "$REFINE" \
  --input "$PROMPT_PATH" \
  --output-dir "$OUTPUT_DIR" \
  --venv "$VENV_PATH" \
  "$@"
