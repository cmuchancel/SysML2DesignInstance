# SysML Pipeline

This is the full prompt-to-design pipeline for `SysMLtoDesignInstance`:

1. natural-language prompt
2. SysML refinement with `syside check`
3. concept generation
4. concept optimization through `optimization/scripts/syspipe.py`
5. supplier-backed part selection
6. final SysML/BOM deliverables under `pipeline/runs/<timestamp>/`

## First-time setup

From the repo root:

```bash
./setup_pipeline.sh
```

Equivalent direct path:

```bash
bash SysMLtoDesignInstance/pipeline/setup_pipeline_env.sh
```

That script:
- creates the default pipeline venv at `SysMLtoDesignInstance/.venv`
- installs Python dependencies from [`requirements.txt`](./requirements.txt)
- installs Node dependencies for `SysMLtoDesignInstance` and `sysml-v2-configurator`
- installs Playwright Chromium for the supplier-search path
- copies [`../.env.example`](../.env.example) to `SysMLtoDesignInstance/.env` if needed

You still need to fill in:
- `OPENAI_API_KEY`
- `SYSIDE_LICENSE_KEY`
- any optional supplier credentials you want to use

If you have a pip-installable SysIDE package, you can let the setup script install it:

```bash
SYSIDE_PIP_SPEC=syside bash SysMLtoDesignInstance/pipeline/setup_pipeline_env.sh
```

## Run the full pipeline

From the repo root:

```bash
./run_pipeline.sh --nl "Design a compact battery-powered inspection drone that fits in a 30 cm cube and flies for 20 minutes."
```

Equivalent direct path:

```bash
SysMLtoDesignInstance/.venv/bin/python SysMLtoDesignInstance/pipeline/run_all.py \
  --nl "Design a compact battery-powered inspection drone that fits in a 30 cm cube and flies for 20 minutes."
```

Useful options:
- `--concepts N`: number of concepts to generate
- `--max-parallel-concepts N`: cap concept-level parallel optimization
- `--parts-per-concept N`: max slots to source per concept
- `--search-limit N`: supplier search depth per slot
- `--max-iters N`: SysML refine iterations
- `--model MODEL`: LLM used by concept generation and refinement
- `--configurator-sites mouser.com,digikey.com`: restrict supplier domains if desired

Defaults:
- uses `SysMLtoDesignInstance/.venv` as the SysIDE venv
- writes outputs to `SysMLtoDesignInstance/pipeline/runs/<timestamp>/`
- uses broad supplier search by default
- keeps human input out of orchestration; decision points are delegated through the pipeline policy layer

## Regression batch

To run the checked-in prompt batch:

```bash
./run_pipeline_batch.sh
```

Equivalent direct path:

```bash
SysMLtoDesignInstance/.venv/bin/python SysMLtoDesignInstance/pipeline/run_prompt_regression_batch.py
```

## Full help

For the end-to-end run guide, environment notes, outputs, and troubleshooting, see:

- [HELP.md](./HELP.md)
