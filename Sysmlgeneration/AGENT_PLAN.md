# NL → SysML Multi‑Agent Workflow (pivot)

This documents three cooperating roles built around the existing SysML refinement loop (`Sysmlgeneration/refine_sysml.py`) and the component finder.

## 1) Spec Guardian (requirements fidelity)
- Input: raw natural language brief from the user.
- Tasks:
  - Echo the NL brief verbatim and extract explicit structured requirements.
  - Generate a list of missing/ambiguous items as targeted questions (no more than 10, prioritized).
  - Build the initial prompt file for `refine_sysml.py` (`runs/<ts>/req.txt`).
  - Gate every refinement: compare emitted SysML text to the NL brief; if gaps exist, feed explicit deltas back into the next iteration.

How to run:
```
source .venv/bin/activate
python Sysmlgeneration/refine_sysml.py \
  --input runs/<ts>/req.txt \
  --venv /absolute/path/to/syside_venv \
  --max-iters 10 --max-total-tokens 60000
```

## 2) Design Instantiator (lateral design space)
- Input: the clarified requirements from the Spec Guardian.
- Tasks:
  - Propose 3–6 substantially different solution concepts (vary architecture, materials, control approaches, COTS vs custom, etc.).
  - For each concept, produce a concise SysML instance sketch or delta notes suitable to feed into the refinement loop as alternative branches.
  - Tag tradeoff axes (cost/complexity/performance/risk) for each concept.

Output paths (suggested):
- `runs/<ts>/concepts/concept_01.md` … `concept_0N.md` with bullet tradeoffs and any specific constraints to inject into refinement.

## 3) Design Realizer (parts binding)
- Input: each concept from the Design Instantiator.
- Tasks:
  - Derive key part parameters (e.g., resistor value/tolerance/package; spring length/rate; actuator torque/voltage).
  - Use the Component Finder CLI to search real parts. Example:
    ```
    npm run cli -- --provider web --limit 8 \
      --keywords "10k resistor" --keywords "0603" --keywords "1%"
    ```
  - Capture top matches with URLs and specs; flag “no viable part” when none found.
- Outputs:
  - `runs/<ts>/realization/concept_01_parts.json` listing candidate parts per requirement bucket.

## Hand‑off loop
1) Spec Guardian produces clarified prompt + questions.
2) Design Instantiator explores 3–6 concepts.
3) For each concept, Design Realizer binds parts; results can be folded back into `refine_sysml.py` by adding the chosen concept notes to the prompt or as `extra_context`.
4) Iterate until `syside check` passes and parts exist for the selected concept.

## Guardrails
- Always run `syside check` via `refine_sysml.py` after any SysML change.
- If parts lookup fails, return the missing parameters to the Spec Guardian to tighten the requirement before re‑generating SysML.
- Keep prompts minimal: include NL brief twice (per refine_sysml guidance) and deltas only.
