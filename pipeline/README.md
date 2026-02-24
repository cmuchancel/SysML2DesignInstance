# SysML Pipeline (Spec → Design → Parts)

This folder wires the Spec Guardian → Design Instantiator → Design Realizer loop around the existing SysML refinement tool (`Sysmlgeneration/refine_sysml.py`) and the component finder CLI.

## Quick start
1) Create a run scaffold from a natural-language brief:
   ```bash
   python pipeline/scaffold.py --nl "Design a 1 kg inspection drone that fits in a 30 cm cube and flies 20 min." \
     --out pipeline/runs
   ```
   This creates `pipeline/runs/<timestamp>/` with:
   - `prompt.txt` (NL duplicated, ready for Spec Guardian / refine loop)
   - `questions.md` (fill in open points)
   - `concepts/` (place Design Instantiator alternatives)
   - `parts/` (place Design Realizer part picks)

2) Run the SysML refinement loop (compiler-in-the-loop):
   ```bash
   ./pipeline/run_refine.sh pipeline/runs/<timestamp>/prompt.txt /abs/path/to/syside_venv \
     --max-iters 10 --max-total-tokens 60000
   ```
   The loop saves each iteration + compiler output under `sysml/`.

Or end-to-end in one go (scaffold + refine):
```bash
python pipeline/run_full.py --nl "Design a 1 kg inspection drone..." \
  --syside-venv /abs/path/to/syside_venv \
  --max-iters 10 --max-total-tokens 60000
```

**Zero-touch flow (prompt → SysML → concepts → part searches):**
```bash
python pipeline/run_all.py --nl "Design a 1 kg inspection drone that fits in a 30 cm cube and flies 20 min."
```
Defaults:
- Uses the repo `.venv` for syside
- Generates 3 concepts and 3 part searches each (provider order: mouser,web)
- Writes everything under `pipeline/runs/<timestamp>/`

3) Fill in Design Instantiator outputs:
   - Add 3–6 alternative concepts under `pipeline/runs/<timestamp>/concepts/` (markdown is fine).
   - Mark tradeoffs (cost / complexity / performance / risk).

4) Run Design Realizer (parts binding):
   - For each concept, derive key parameters and search parts with the component finder CLI, e.g.:
     ```bash
     npm run cli -- --provider web --limit 8 --keywords "10k resistor" --keywords "0603" --keywords "1%"
     ```
   - Save hits in `pipeline/runs/<timestamp>/parts/concept_XX.json` (include URL, price, stock, key specs).

5) Feed chosen concept + parts back into `prompt.txt` or `extra_context` and re-run `refine_sysml.py` until `syside check` passes and parts exist.

## Roles
- **Spec Guardian**: ensures SysML matches NL; updates `prompt.txt` and `questions.md`; drives `refine_sysml.py`.
- **Design Instantiator**: writes multiple concepts in `concepts/`.
- **Design Realizer**: binds parts and records them in `parts/`.

## Notes
- No provider APIs are required for the parts step; the CLI can operate on web scraping. If you have Mouser/Digi-Key/OCTOPART credentials, set env vars to improve fidelity.
- Keep prompts minimal—per `Sysmlgeneration/README.md`, the NL brief is echoed twice and deltas are appended iteration by iteration.
