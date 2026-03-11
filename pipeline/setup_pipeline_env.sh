#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'EOF'
Usage: pipeline/setup_pipeline_env.sh [options]

Creates the default SysMLtoDesignInstance pipeline venv, installs Python deps,
installs the Node deps used by the full pipeline, and optionally installs SysIDE.

Options:
  --venv PATH            Venv path to create/use (default: SysMLtoDesignInstance/.venv)
  --python BIN           Python interpreter used to create the venv (default: python3)
  --skip-node            Skip `npm install` in SysMLtoDesignInstance and sysml-v2-configurator
  --skip-playwright      Skip `npx playwright install chromium`
  --syside-pip-spec SPEC Install SysIDE with the given pip spec inside the venv
  --no-env-copy          Do not copy `.env.example` to `.env` when `.env` is missing
  -h, --help             Show this help

Environment:
  SYSIDE_PIP_SPEC        Alternative way to provide the SysIDE pip spec
EOF
}

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
SYSML_ROOT="$(cd -- "${SCRIPT_DIR}/.." && pwd)"
REPO_ROOT="$(cd -- "${SYSML_ROOT}/.." && pwd)"

VENV_DIR="${SYSML_ROOT}/.venv"
PYTHON_BIN="${PYTHON_BIN:-python3}"
SKIP_NODE=0
SKIP_PLAYWRIGHT=0
COPY_ENV=1
SYSIDE_PIP_SPEC="${SYSIDE_PIP_SPEC:-}"

while [[ $# -gt 0 ]]; do
  case "$1" in
    --venv)
      VENV_DIR="$2"
      shift 2
      ;;
    --python)
      PYTHON_BIN="$2"
      shift 2
      ;;
    --skip-node)
      SKIP_NODE=1
      shift
      ;;
    --skip-playwright)
      SKIP_PLAYWRIGHT=1
      shift
      ;;
    --syside-pip-spec)
      SYSIDE_PIP_SPEC="$2"
      shift 2
      ;;
    --no-env-copy)
      COPY_ENV=0
      shift
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "Unknown option: $1" >&2
      usage >&2
      exit 1
      ;;
  esac
done

if ! command -v "${PYTHON_BIN}" >/dev/null 2>&1; then
  echo "Python interpreter not found: ${PYTHON_BIN}" >&2
  exit 1
fi

if [[ ${SKIP_NODE} -eq 0 ]] && ! command -v npm >/dev/null 2>&1; then
  echo "npm is required unless --skip-node is used." >&2
  exit 1
fi

echo "Creating/updating pipeline venv at ${VENV_DIR}"
"${PYTHON_BIN}" -m venv "${VENV_DIR}"

VENV_PY="${VENV_DIR}/bin/python"
if [[ ! -x "${VENV_PY}" ]]; then
  echo "Expected venv python not found at ${VENV_PY}" >&2
  exit 1
fi

echo "Installing Python dependencies"
"${VENV_PY}" -m pip install --upgrade pip setuptools wheel
"${VENV_PY}" -m pip install -r "${SCRIPT_DIR}/requirements.txt"
"${VENV_PY}" "${REPO_ROOT}/optimization/scripts/bootstrap_deps.py" --no-upgrade

echo "Verifying OpenAI client import"
if ! "${VENV_PY}" - <<'PY' >/dev/null 2>&1
from openai import OpenAI
print("ok")
PY
then
  echo "OpenAI import failed; force-reinstalling openai"
  "${VENV_PY}" -m pip install --force-reinstall --no-cache-dir "openai>=1.0,<2"
fi

if [[ -n "${SYSIDE_PIP_SPEC}" ]]; then
  echo "Installing SysIDE from pip spec: ${SYSIDE_PIP_SPEC}"
  "${VENV_PY}" -m pip install "${SYSIDE_PIP_SPEC}"
else
  echo "Skipping SysIDE install. Set SYSIDE_PIP_SPEC or pass --syside-pip-spec if you have access."
fi

if [[ ${COPY_ENV} -eq 1 ]] && [[ ! -f "${SYSML_ROOT}/.env" ]] && [[ -f "${SYSML_ROOT}/.env.example" ]]; then
  cp "${SYSML_ROOT}/.env.example" "${SYSML_ROOT}/.env"
  echo "Copied ${SYSML_ROOT}/.env.example -> ${SYSML_ROOT}/.env"
fi

if [[ ${SKIP_NODE} -eq 0 ]]; then
  echo "Installing Node dependencies in ${SYSML_ROOT}"
  (cd "${SYSML_ROOT}" && npm install)

  echo "Installing Node dependencies in ${REPO_ROOT}/sysml-v2-configurator"
  (cd "${REPO_ROOT}/sysml-v2-configurator" && npm install)

  if [[ ${SKIP_PLAYWRIGHT} -eq 0 ]]; then
    echo "Installing Playwright Chromium browser"
    (cd "${SYSML_ROOT}" && npx playwright install chromium)
  fi
fi

echo
echo "Setup complete."
echo "- Python venv: ${VENV_DIR}"
echo "- Fill in credentials in: ${SYSML_ROOT}/.env"
echo "- Full pipeline run:"
echo "    cd ${REPO_ROOT}"
echo "    ${VENV_PY} SysMLtoDesignInstance/pipeline/run_all.py --nl \"Design ...\""
echo "- Batch regression run:"
echo "    cd ${REPO_ROOT}"
echo "    ${VENV_PY} SysMLtoDesignInstance/pipeline/run_prompt_regression_batch.py"

if ! "${VENV_PY}" -c "import importlib.util, sys; sys.exit(0 if importlib.util.find_spec('syside') else 1)" >/dev/null 2>&1; then
  echo
  echo "Note: SysIDE is not installed in ${VENV_DIR}."
  echo "Install it into that venv before running the full pipeline, and set SYSIDE_LICENSE_KEY in ${SYSML_ROOT}/.env."
fi
