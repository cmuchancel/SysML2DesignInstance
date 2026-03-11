# Full Pipeline Help

This guide is for fresh clones that need to run the entire `SysMLtoDesignInstance` pipeline end to end.

## What the full pipeline does

`run_all.py` takes a natural-language prompt and drives:

1. scaffold creation
2. SysML refinement with `syside check`
3. conceptual architecture generation
4. per-concept optimization through `optimization/scripts/syspipe.py`
5. supplier-backed part selection
6. final deliverables:
   - `deliverables/final.sysml`
   - `deliverables/design_instances.sysml`
   - `deliverables/design_instances_optimized.sysml`
   - `deliverables/bom.json`
   - `deliverables/bom_optimized.json`
   - `summary_auto.json`

Everything lands in `SysMLtoDesignInstance/pipeline/runs/<timestamp>/`.

## Prerequisites

- Python available as `python3`
- Node.js and `npm`
- an OpenAI API key
- a SysIDE license key
- access to a SysIDE pip package if your environment does not already provide it

## One-command setup

From the repo root:

```bash
./setup_pipeline.sh
```

Equivalent direct path:

```bash
bash SysMLtoDesignInstance/pipeline/setup_pipeline_env.sh
```

Default behavior:
- creates `SysMLtoDesignInstance/.venv`
- installs Python packages from [`requirements.txt`](./requirements.txt)
- installs Node dependencies in:
  - [`SysMLtoDesignInstance/package.json`](../package.json)
  - [`sysml-v2-configurator/package.json`](../../sysml-v2-configurator/package.json)
- installs Playwright Chromium for the search/scraper path
- copies [`../.env.example`](../.env.example) to `SysMLtoDesignInstance/.env` if `.env` does not exist

If SysIDE is pip-installable in your environment, install it during setup:

```bash
SYSIDE_PIP_SPEC=syside bash SysMLtoDesignInstance/pipeline/setup_pipeline_env.sh
```

Or pass an explicit spec:

```bash
bash SysMLtoDesignInstance/pipeline/setup_pipeline_env.sh \
  --syside-pip-spec "syside==<your-version>"
```

Useful setup flags:
- `--venv PATH`
- `--python BIN`
- `--skip-node`
- `--skip-playwright`
- `--no-env-copy`

## Environment file

Fill in `SysMLtoDesignInstance/.env` after setup.

Required keys:
- `OPENAI_API_KEY`
- `SYSIDE_LICENSE_KEY`

Common optional keys:
- `OPENAI_MODEL`
- `MOUSER_API_KEY`
- `DIGIKEY_CLIENT_ID`
- `DIGIKEY_CLIENT_SECRET`
- `DIGIKEY_REFRESH_TOKEN`
- `OCTOPART_API_KEY`
- `NEXAR_TOKEN`
- `GEMINI_API_KEY`
- `PART_SEARCH_TIMEOUT_SEC`
- `OPTIMIZER_TIMEOUT_SEC`
- `PIPELINE_MAX_PARALLEL_CONCEPTS`

The checked-in example is here:
- [../.env.example](../.env.example)

## Run one full prompt

From the repo root:

```bash
./run_pipeline.sh --nl "Design a compact battery-powered inspection drone that fits in a 30 cm cube and flies for 20 minutes."
```

Equivalent direct path:

```bash
SysMLtoDesignInstance/.venv/bin/python SysMLtoDesignInstance/pipeline/run_all.py \
  --nl "Design a compact battery-powered inspection drone that fits in a 30 cm cube and flies for 20 minutes."
```

Example with more control:

```bash
SysMLtoDesignInstance/.venv/bin/python SysMLtoDesignInstance/pipeline/run_all.py \
  --nl "Design a solar-powered remote environmental monitor that uploads telemetry over LoRa." \
  --concepts 3 \
  --max-parallel-concepts 3 \
  --parts-per-concept 3 \
  --search-limit 3 \
  --max-iters 25 \
  --model gpt-5-mini
```

## Run the prompt regression batch

```bash
./run_pipeline_batch.sh
```

Equivalent direct path:

```bash
SysMLtoDesignInstance/.venv/bin/python SysMLtoDesignInstance/pipeline/run_prompt_regression_batch.py
```

That uses:
- [prompt_regression_manifest.json](./prompt_regression_manifest.json)

## Important outputs

Inside each run directory:

- `prompt.txt`: scaffolded prompt used by the refiner
- `sysml/<timestamp>/run_log.json`: refinement iterations and compiler feedback
- `concepts/auto_concepts.json`: generated concepts
- `optimization/concept_*/pareto_solutions.csv`: optimizer output
- `optimization/concept_*/selected_solution.json`: chosen representative solution
- `parts/*.log`: supplier search logs and selected parts
- `deliverables/final.sysml`: latest requirements/refined SysML
- `deliverables/design_instances_optimized.sysml`: final design instances with sourced parts
- `deliverables/bom_optimized.json`: optimized BOM with supplier data
- `summary_auto.json`: top-level run summary

## Troubleshooting

`syside venv missing`
- Run the setup script or pass `--syside-venv /path/to/venv`.

`OPENAI_API_KEY is not set`
- Put it in `SysMLtoDesignInstance/.env` or export it before running.

`SysIDE is not installed`
- Install your SysIDE package into `SysMLtoDesignInstance/.venv`.
- Make sure `SYSIDE_LICENSE_KEY` is set.

`part_selection_status` is `partial_parts_found`
- The pipeline completed, but one or more requested slots did not find a supplier-backed match.
- Inspect `parts/*.log` in that run directory to see which slot failed and what query was used.

`run_prompt_regression_batch.py` is slow
- It executes the real full pipeline, including refinement, optimization, and web-backed part search.
- Reduce `--search-limit`, `--parts-per-concept`, or `--concepts` for faster smoke runs.

## Recommended clone workflow

1. Clone the repo.
2. Run `./setup_pipeline.sh`.
3. Fill in `SysMLtoDesignInstance/.env`.
4. Run one `./run_pipeline.sh --nl "..."` prompt.
5. Run `./run_pipeline_batch.sh` if you want an end-to-end smoke test.
