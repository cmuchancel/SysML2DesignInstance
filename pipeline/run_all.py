#!/usr/bin/env python3
"""
One-button pipeline:
  NL prompt -> scaffold -> SysML refine (compiler-in-loop) -> concepts -> part searches.

Requires:
  - OPENAI_API_KEY in environment.
  - syside installed in the chosen venv (defaults to repo .venv).
  - npm dependencies installed (component finder CLI).
"""

from __future__ import annotations

import argparse
import csv
from concurrent.futures import ThreadPoolExecutor, as_completed
import json
import math
import os
import re
import subprocess
import sys
from datetime import datetime
from pathlib import Path
from typing import List, Dict, Any, Optional
from log_stages import StageLog

SCRIPT_DIR = Path(__file__).resolve().parent
REPO_ROOT = SCRIPT_DIR.parent
ENV_PATH = REPO_ROOT / ".env"
SCAFFOLD = SCRIPT_DIR / "scaffold.py"
REFINE = SCRIPT_DIR / "refine_sysml.py"
OPTIMIZATION_DIR = REPO_ROOT.parent / "optimization"
SYSPIPE = OPTIMIZATION_DIR / "scripts" / "syspipe.py"
BOOTSTRAP_DEPS = OPTIMIZATION_DIR / "scripts" / "bootstrap_deps.py"
CONFIGURATOR_DIR = REPO_ROOT.parent / "sysml-v2-configurator"
CONFIG_PART_PICKER = CONFIGURATOR_DIR / "part_picker_cli.mjs"
CONFIG_CONSTRAINT_VALIDATOR = CONFIGURATOR_DIR / "ConstraintValidation.py"

DEFAULT_CONCEPT_COUNT = 3
DEFAULT_PROVIDER_ORDER = "web,mouser,octopart,digikey"
GENERIC_CONCEPT_VARIANTS = [
    (
        "Balanced COTS Architecture",
        "Use a balanced off-the-shelf architecture that satisfies the brief without over-specializing any subsystem.",
    ),
    (
        "Performance-First Architecture",
        "Favor higher-performing commercial subsystems and tighter integration to maximize requirement headroom.",
    ),
    (
        "Low-Complexity Architecture",
        "Favor a simpler, easier-to-source architecture with fewer custom dependencies and clearer implementation paths.",
    ),
]
PROMPT_STOPWORDS = {
    "a",
    "an",
    "and",
    "at",
    "be",
    "by",
    "design",
    "for",
    "from",
    "in",
    "into",
    "is",
    "it",
    "of",
    "on",
    "or",
    "system",
    "that",
    "the",
    "this",
    "to",
    "with",
}


# ---------- helpers ----------

def load_env_if_present() -> None:
    if not ENV_PATH.exists():
        return
    for line in ENV_PATH.read_text(encoding="utf-8").splitlines():
        line = line.strip()
        if not line or line.startswith("#") or "=" not in line:
            continue
        k, v = line.split("=", 1)
        if k and v and k not in os.environ:
            os.environ[k] = v


def make_openai_client():
    try:
        from openai import OpenAI
    except Exception as exc:
        raise RuntimeError(
            "OpenAI client import failed. Repair the pipeline venv or rerun "
            "SysMLtoDesignInstance/pipeline/setup_pipeline_env.sh."
        ) from exc
    return OpenAI()

def run(cmd: List[str], cwd: Path | None = None) -> str:
    result = subprocess.run(cmd, cwd=cwd, check=True, capture_output=True, text=True, env=os.environ.copy())
    return result.stdout


def latest_run(out_dir: Path) -> Path:
    runs = sorted(
        [p for p in out_dir.glob("*") if p.is_dir() and (p / "prompt.txt").exists()],
        key=lambda p: p.name,
    )
    if not runs:
        raise SystemExit(f"No run directory found in {out_dir}")
    return runs[-1]


def scaffold_run_dir_from_output(stdout: str) -> Path | None:
    for line in stdout.splitlines():
        if line.startswith("Scaffold created at "):
            candidate = line.split("Scaffold created at ", 1)[1].strip()
            if candidate:
                path = Path(candidate)
                if path.exists():
                    return path
    return None


def find_latest_sysml(sysml_dir: Path) -> Path:
    candidates = sorted(sysml_dir.glob("**/*.sysml"))
    if not candidates:
        raise SystemExit(f"No SysML files found in {sysml_dir}")
    return candidates[-1]


def load_run_log(sysml_dir: Path) -> dict | None:
    # pick the newest run_log.json under sysml_dir
    logs = sorted(sysml_dir.glob("**/run_log.json"))
    if not logs:
        return None
    try:
        return json.loads(logs[-1].read_text(encoding="utf-8"))
    except Exception:
        return None


def write_min_requirements_sysml(path: Path, prompt_text: str) -> None:
    content = f"""package RequirementsOnly {{
  requirement RQ_001 {{
    text = "{prompt_text.replace('"', '\\"')}";
  }}
}}"""
    path.write_text(content, encoding="utf-8")


def collect_parts_logs(parts_dir: Path) -> Dict[str, List[Dict[str, str]]]:
    """Parse simple CLI text logs into a minimal BOM summary.

    Supports filenames:
      - auto_c{ci}_q{qi}.log     (legacy concept-level)
      - auto_c{ci}_s{slot}_q{qi}.log (slot-aware)

    Keys are concept/slot aware so we can map back into design instances.
    """
    summary: Dict[str, List[Dict[str, str]]] = {}
    for log in sorted(parts_dir.glob("auto_c*_q*.log")):
        stem = log.stem  # auto_c{ci}_s{slot}_q{qi} or auto_c{ci}_q{qi}
        concept_id = ""
        slot_id: Optional[str] = None
        if "_s" in stem:
            # auto_c1_sdriver_q1
            head, tail = stem.split("_s", 1)
            concept_id = head.replace("auto_", "").lstrip("c")
            slot_id = tail.split("_", 1)[0]
        else:
            parts = stem.split("_")
            concept_id = parts[1] if len(parts) > 1 else stem.replace("auto_c", "")

        keys = {
            concept_id,
            f"c{concept_id}",
            f"auto_c{concept_id}",
        }
        if slot_id:
            keys.update(
                {
                    f"{concept_id}:{slot_id}",
                    f"c{concept_id}:{slot_id}",
                    f"auto_c{concept_id}:{slot_id}",
                }
            )

        entries: List[Dict[str, str]] = []
        lines = log.read_text(encoding="utf-8").splitlines()
        current: Dict[str, str] | None = None
        for line in lines:
            line = line.strip()
            if not line or line.startswith("Source:") or "Matches" in line or line.startswith("----"):
                continue
            if line.startswith("Search timed out"):
                entries.append({"title": "timeout", "status": "timeout", "detail": line})
                continue
            if "(" in line and ")" in line and not line.startswith("Stock") and not line.startswith("URL"):
                if current:
                    entries.append(current)
                current = {"title": line}
                continue
            if line.startswith("Stock:"):
                current = current or {}
                current["stock"] = line.replace("Stock:", "").strip()
                continue
            if line.startswith("URL:"):
                current = current or {}
                current["url"] = line.replace("URL:", "").strip()
                continue
        if current:
            entries.append(current)
        if not entries:
            entries.append({"title": "not found", "status": "not_found"})

        # derive status for each entry
        normed: List[Dict[str, str]] = []
        for e in entries:
            status = e.get("status") or ("url" in e and "found" or "pending")
            normed.append({**e, "status": status})

        for k in keys:
            if k:
                summary[k] = normed
    return summary


def bom_rows_from_summary(bom: Dict[str, List[Dict[str, str]]]) -> List[Dict[str, str]]:
    rows: List[Dict[str, str]] = []
    for concept_key, entries in bom.items():
        concept, slot = (concept_key.split(":", 1) + [""])[:2] if ":" in concept_key else (concept_key, "")
        for entry in entries:
            rows.append(
                {
                    "concept": concept,
                    "slot": slot,
                    "title": entry.get("title", "item"),
                    "url": entry.get("url"),
                    "supplier": entry.get("supplier"),
                    "status": entry.get("status", "pending"),
                    "stock": entry.get("stock"),
                }
            )
    return rows


def write_design_instances_sysml(path: Path, concepts: List[Dict[str, Any]], bom: Dict[str, List[Dict[str, str]]]) -> None:
    """Emit lightweight SysML instances with per-slot BOM annotations."""
    lines = ["package DesignInstances {", "  public import ScalarValues::*;"]
    lines.append("  part def ConceptInstance {")
    lines.append("    attribute name: String;")
    lines.append("    attribute approach: String;")
    lines.append("  }")
    lines.append("  part def SlotSelection {")
    lines.append("    attribute slot: String;")
    lines.append("    attribute title: String;")
    lines.append("    attribute supplier: String;")
    lines.append("    attribute url: String;")
    lines.append("    attribute status: String;")
    lines.append("  }")

    for idx, concept in enumerate(concepts, 1):
        cid = f"Concept_{idx}"
        approach = concept.get("approach", "").replace('"', "'")
        lines.append(f"  part {cid} : ConceptInstance {{")
        lines.append(f'    name = "{concept.get("name","Concept")}";')
        lines.append(f'    approach = "{approach}";')
        # slots, if any
        slots = concept.get("slots") or []
        for slot in slots:
            slot_name = str(slot.get("slot") or slot.get("name") or "slot").replace('"', "")
            key_candidates = [
                f"{idx}:{slot_name}",
                f"c{idx}:{slot_name}",
                f"auto_c{idx}:{slot_name}",
                f"{idx}",
                f"auto_c{idx}",
            ]
            entries: List[Dict[str, str]] = []
            for k in key_candidates:
                if k in bom:
                    entries = bom[k]
                    break
            entry = entries[0] if entries else {}
            title = entry.get("title", "unsourced").replace('"', '\\"')
            supplier = entry.get("supplier", "").replace('"', '\\"')
            url = entry.get("url", "").replace('"', '\\"')
            status = entry.get("status", "pending").replace('"', '\\"')
            lines.append("    part {}_{} : SlotSelection {{".format(cid, slot_name))
            lines.append(f'      slot = "{slot_name}";')
            lines.append(f'      title = "{title}";')
            lines.append(f'      supplier = "{supplier}";')
            lines.append(f'      url = "{url}";')
            lines.append(f'      status = "{status}";')
            lines.append("    }")
        lines.append("  }")
    lines.append("} end DesignInstances;")
    path.write_text("\n".join(lines), encoding="utf-8")


def load_prompt(run_dir: Path) -> str:
    return (run_dir / "prompt.txt").read_text(encoding="utf-8").strip()


def extract_user_brief(prompt_text: str) -> str:
    text = prompt_text.strip()
    repeat_marker = "-- repeat --"
    if repeat_marker in text:
        before_repeat = text.split(repeat_marker, 1)[0]
        lines = [line.strip() for line in before_repeat.splitlines() if line.strip() and not line.strip().startswith("#")]
        if lines:
            return " ".join(lines).strip()

    instruction_marker = "# Instructions to the model"
    if instruction_marker in text:
        text = text.split(instruction_marker, 1)[0].strip()

    lines = [line.strip() for line in text.splitlines() if line.strip() and not line.strip().startswith("#")]
    return " ".join(lines).strip() or prompt_text.strip()


def call_llm(prompt: str, model: str, temperature: float | None) -> str:
    client = make_openai_client()
    resp = client.responses.create(
        model=model,
        input=prompt,
        temperature=temperature,
        max_output_tokens=2000,
    )
    text = getattr(resp, "output_text", None)
    if text:
        return text.strip()
    # fallback for streaming-like structure
    chunks = []
    for item in getattr(resp, "output", []) or []:
        for c in getattr(item, "content", []) or []:
            t = getattr(c, "text", None)
            if t:
                chunks.append(t)
    if chunks:
        return "\n".join(chunks).strip()
    raise RuntimeError("LLM response contained no text")


def parse_json_array_from_text(text: str) -> List[Dict[str, Any]]:
    candidate_texts = [text]
    start = text.find("[")
    end = text.rfind("]")
    if start >= 0 and end > start:
        candidate_texts.append(text[start : end + 1])
    start_obj = text.find("{")
    end_obj = text.rfind("}")
    if start_obj >= 0 and end_obj > start_obj:
        candidate_texts.append(text[start_obj : end_obj + 1])

    for candidate in candidate_texts:
        try:
            parsed = json.loads(candidate)
        except Exception:
            continue
        if isinstance(parsed, list):
            return [item for item in parsed if isinstance(item, dict)]
        if isinstance(parsed, dict):
            concepts = parsed.get("concepts")
            if isinstance(concepts, list):
                return [item for item in concepts if isinstance(item, dict)]
    raise ValueError("response did not contain a JSON array of concepts")


def repair_concepts_json(raw_text: str, model: str, temperature: float | None) -> str:
    repair_prompt = f"""
Convert the following model output into valid JSON only.

Requirements:
- Return either a JSON array or a JSON object with key "concepts".
- Each concept must be an object with:
  - "name"
  - "approach"
  - optional "slots" array of objects with "slot", "purpose", and "search_queries"
  - optional "search_queries" array
- Do not add markdown fences or explanatory prose.

Raw output:
{raw_text}
"""
    return call_llm(repair_prompt, model, temperature)


def parse_slot_array_from_text(text: str) -> List[Dict[str, Any]]:
    candidate_texts = [text]
    start = text.find("[")
    end = text.rfind("]")
    if start >= 0 and end > start:
        candidate_texts.append(text[start : end + 1])
    start_obj = text.find("{")
    end_obj = text.rfind("}")
    if start_obj >= 0 and end_obj > start_obj:
        candidate_texts.append(text[start_obj : end_obj + 1])

    for candidate in candidate_texts:
        try:
            parsed = json.loads(candidate)
        except Exception:
            continue
        if isinstance(parsed, list):
            return [item for item in parsed if isinstance(item, dict)]
        if isinstance(parsed, dict):
            slots = parsed.get("slots")
            if isinstance(slots, list):
                return [item for item in slots if isinstance(item, dict)]
    raise ValueError("response did not contain a JSON array of slots")


def repair_slots_json(raw_text: str, model: str, temperature: float | None) -> str:
    repair_prompt = f"""
Convert the following model output into valid JSON only.

Requirements:
- Return either a JSON array or a JSON object with key "slots".
- Each slot must be an object with:
  - "slot"
  - "purpose"
  - "search_queries" as an array of 1-3 strings
- Do not add markdown fences or explanatory prose.

Raw output:
{raw_text}
"""
    return call_llm(repair_prompt, model, temperature)


def extract_prompt_keywords(prompt_text: str, limit: int = 8) -> List[str]:
    keywords: List[str] = []
    seen: set[str] = set()
    for token in re.findall(r"[A-Za-z][A-Za-z0-9_-]{2,}", prompt_text.lower()):
        if token in PROMPT_STOPWORDS or token in seen:
            continue
        seen.add(token)
        keywords.append(token)
        if len(keywords) >= limit:
            break
    return keywords


def build_generic_slot_specs(prompt_text: str, concept_name: str) -> List[Dict[str, Any]]:
    prompt_clean = " ".join(prompt_text.split())
    keywords = extract_prompt_keywords(prompt_clean)
    keyword_phrase = " ".join(keywords[:5]) if keywords else prompt_clean[:80].strip()
    return [
        {
            "slot": "primary_subsystem",
            "purpose": "Primary purchasable subsystem that implements the core function of the design brief.",
            "search_queries": [
                f"{keyword_phrase} commercial module",
                f"{keyword_phrase} supplier part",
                f"{keyword_phrase} off the shelf",
            ],
        },
        {
            "slot": "supporting_subsystem",
            "purpose": "Supporting purchasable subsystem that enables the primary function or integration of the design.",
            "search_queries": [
                f"{keyword_phrase} supporting module",
                f"{concept_name} supporting subsystem",
                f"{keyword_phrase} accessory component",
            ],
        },
    ]


def infer_slot_specs_with_llm(
    prompt_text: str,
    concept_name: str,
    concept_approach: str,
    model: str,
    temperature: float | None,
) -> List[Dict[str, Any]]:
    slot_prompt = f"""
You are extracting sourceable subsystems for a design concept.

Requirement:
{prompt_text}

Concept name:
{concept_name}

Concept approach:
{concept_approach}

Return JSON only.
Return either a JSON array or {{"slots": [...]}}.
Each slot must be an object with:
- "slot": a concise subsystem/component identifier
- "purpose": one sentence explaining its role
- "search_queries": array of 1-3 concrete web-search strings that could find a purchasable real-world part

Rules:
- Choose 1-4 slots.
- Keep slots general enough to apply to arbitrary domains, but specific enough to source real parts.
- Do not assume a fixed domain or benchmark family.
- No markdown or prose outside JSON.
"""
    raw = call_llm(slot_prompt, model, temperature)
    try:
        return parse_slot_array_from_text(raw)
    except Exception:
        repaired = repair_slots_json(raw, model, temperature)
        return parse_slot_array_from_text(repaired)


def normalize_slot_items(
    raw_slots: List[Dict[str, Any]],
    fallback_queries: List[str],
) -> List[Dict[str, Any]]:
    normalized_slots: List[Dict[str, Any]] = []
    for raw_slot in raw_slots:
        if not isinstance(raw_slot, dict):
            continue
        slot_name = str(raw_slot.get("slot") or raw_slot.get("name") or "").strip()
        if not slot_name:
            continue
        slot_queries = raw_slot.get("search_queries") or []
        if isinstance(slot_queries, str):
            slot_queries = [slot_queries]
        slot_queries = [str(q).strip() for q in slot_queries if str(q).strip()]
        normalized_slots.append(
            {
                "slot": slot_name,
                "purpose": str(raw_slot.get("purpose") or "").strip(),
                "search_queries": slot_queries or fallback_queries[:2],
            }
        )
    return normalized_slots


def resolve_slot_specs(
    prompt_text: str,
    concept_name: str,
    concept_approach: str,
    provided_slots: List[Dict[str, Any]] | None,
    fallback_queries: List[str],
    model: str,
    temperature: float | None,
) -> List[Dict[str, Any]]:
    normalized_slots = normalize_slot_items(provided_slots or [], fallback_queries)
    if normalized_slots:
        return normalized_slots
    try:
        llm_slots = infer_slot_specs_with_llm(prompt_text, concept_name, concept_approach, model, temperature)
        normalized_slots = normalize_slot_items(llm_slots, fallback_queries)
        if normalized_slots:
            return normalized_slots
    except Exception:
        pass
    return build_generic_slot_specs(prompt_text, concept_name)


def build_generic_fallback_concepts(
    prompt_text: str,
    n_concepts: int,
    model: str,
    temperature: float | None,
) -> List[Dict[str, Any]]:
    prompt_clean = " ".join(prompt_text.split())
    fallback_concepts: List[Dict[str, Any]] = []
    for idx in range(n_concepts):
        title, summary = GENERIC_CONCEPT_VARIANTS[idx % len(GENERIC_CONCEPT_VARIANTS)]
        concept_name = f"{title} {idx + 1}" if idx >= len(GENERIC_CONCEPT_VARIANTS) else title
        concept_approach = f"{summary} Brief context: {prompt_clean[:220].rstrip()}"
        fallback_queries = [
            f"{prompt_clean[:120].strip()} {concept_name}".strip(),
            f"{prompt_clean[:120].strip()} supplier".strip(),
            f"{prompt_clean[:120].strip()} commercial off the shelf".strip(),
        ]
        slots = resolve_slot_specs(
            prompt_text=prompt_clean,
            concept_name=concept_name,
            concept_approach=concept_approach,
            provided_slots=None,
            fallback_queries=fallback_queries,
            model=model,
            temperature=temperature,
        )
        fallback_concepts.append(
            {
                "name": concept_name,
                "approach": concept_approach,
                "slots": slots,
                "search_queries": fallback_queries,
            }
        )
    return fallback_concepts


def normalize_concept_item(
    item: Dict[str, Any],
    prompt_text: str,
    index: int,
    model: str,
    temperature: float | None,
) -> Dict[str, Any]:
    prompt_clean = " ".join(prompt_text.split())
    title, summary = GENERIC_CONCEPT_VARIANTS[index % len(GENERIC_CONCEPT_VARIANTS)]
    fallback_name = f"{title} {index + 1}" if index >= len(GENERIC_CONCEPT_VARIANTS) else title
    fallback_approach = f"{summary} Brief context: {prompt_clean[:220].rstrip()}"
    fallback_queries = [
        f"{prompt_clean[:120].strip()} {fallback_name}".strip(),
        f"{prompt_clean[:120].strip()} supplier".strip(),
        f"{prompt_clean[:120].strip()} commercial off the shelf".strip(),
    ]
    name = str(item.get("name") or fallback_name).strip() or fallback_name
    approach = str(item.get("approach") or fallback_approach).strip() or fallback_approach
    queries = item.get("search_queries") or []
    if isinstance(queries, str):
        queries = [queries]
    normalized_queries = [str(q).strip() for q in queries if str(q).strip()] or fallback_queries
    normalized_slots = resolve_slot_specs(
        prompt_text=prompt_text,
        concept_name=name,
        concept_approach=approach,
        provided_slots=item.get("slots") or [],
        fallback_queries=normalized_queries,
        model=model,
        temperature=temperature,
    )

    return {
        "name": name,
        "approach": approach,
        "slots": normalized_slots,
        "search_queries": normalized_queries,
    }


def gen_concepts(prompt_text: str, sysml_path: Path, n_concepts: int, model: str, temperature: float | None) -> List[Dict[str, Any]]:
    sysml_snippet = sysml_path.read_text(encoding="utf-8")[:4000]
    llm_prompt = f"""
You are the Design Instantiator.
Create {n_concepts} distinct design concepts that satisfy the requirement and are realizable with purchasable parts.

Requirement (natural language):
{prompt_text}

Latest SysML (for context, do not edit):
{sysml_snippet}

Return JSON array. Each item fields:
- "name": short concept name
- "approach": 1-2 sentence summary
- "slots": array where each slot is an object with:
    - "slot": concrete subsystem/component identifier relevant to the brief (e.g., "flight_controller", "battery_pack", "camera", "motor_driver", "sensor")
    - "purpose": short phrase of its role
    - "search_queries": array of 1-3 targeted search strings to find a concrete part for this slot
- "search_queries": optional fallback array (broad, concept-level) if slots are missing

Rules:
- Concepts must differ materially in architecture or implementation strategy.
- Prefer domain-specific slot names over generic names like "component" or "module".
- Limit each concept to 1-4 slots that are realistically sourceable.
- Return JSON only. No markdown.
"""
    try:
        text = call_llm(llm_prompt, model, temperature)
    except Exception:
        text = ""
    data: List[Dict[str, Any]] = []
    parsed = False
    if text:
        try:
            data = parse_json_array_from_text(text)
            parsed = True
        except Exception:
            try:
                repaired = repair_concepts_json(text, model, temperature)
                data = parse_json_array_from_text(repaired)
                parsed = True
            except Exception:
                parsed = False
    concepts: List[Dict[str, Any]] = []
    if parsed:
        for idx, item in enumerate(data):
            if not isinstance(item, dict):
                continue
            concepts.append(normalize_concept_item(item, prompt_text, idx, model, temperature))

    # Backfill to at least n_concepts with diverse defaults.
    for fb in build_generic_fallback_concepts(prompt_text, n_concepts, model, temperature):
        if len(concepts) >= n_concepts:
            break
        if fb["name"] not in [c["name"] for c in concepts]:
            concepts.append(fb)

    # If still short, cycle the pool.
    fallback_pool = build_generic_fallback_concepts(prompt_text, max(n_concepts, 1), model, temperature)
    while len(concepts) < n_concepts:
        concepts.append(fallback_pool[len(concepts) % len(fallback_pool)])

    return concepts


def run_part_search(query: str, limit: int, providers: List[str], logfile: Path, timeout_sec: int = 30) -> None:
    cmd = [
        "npm",
        "run",
        "cli",
        "--",
        "--provider",
        *providers,
        "--limit",
        str(limit),
        "--nl",
        query,
    ]
    with logfile.open("w", encoding="utf-8") as f:
        try:
            proc = subprocess.run(
                cmd,
                cwd=REPO_ROOT,
                text=True,
                capture_output=True,
                timeout=timeout_sec,
                env=os.environ.copy(),
            )
            f.write(proc.stdout or "")
            f.write(proc.stderr or "")
        except subprocess.TimeoutExpired as e:
            f.write(f"Search timed out after {timeout_sec}s\n")
            if e.stdout:
                if isinstance(e.stdout, bytes):
                    f.write(e.stdout.decode("utf-8", errors="ignore"))
                else:
                    f.write(e.stdout)
            if e.stderr:
                if isinstance(e.stderr, bytes):
                    f.write(e.stderr.decode("utf-8", errors="ignore"))
                else:
                    f.write(e.stderr)
        except Exception as e:
            f.write(f"Search failed: {e}\n")


def safe_slug(text: str) -> str:
    slug = re.sub(r"[^a-zA-Z0-9_]+", "_", text.strip().lower()).strip("_")
    return slug or "slot"


def as_float(value: Any, default: float = 0.0) -> float:
    try:
        if value is None:
            return default
        return float(value)
    except Exception:
        return default


def fmt_num(value: float) -> str:
    text = f"{value:.8f}".rstrip("0").rstrip(".")
    return text or "0"


def relpath_or_self(path_like: Any, root: Path) -> str:
    p = Path(path_like)
    try:
        return str(p.relative_to(root))
    except Exception:
        return str(p)


def parse_targets(prompt_text: str, requirements_sysml: str) -> Dict[str, float]:
    source = f"{prompt_text}\n{requirements_sysml}"
    defaults = {
        "supply_voltage_v": 5.0,
        "target_freq_hz": 10.0,
        "freq_tol_pct": 5.0,
        "current_min_ma": 8.0,
        "current_max_ma": 20.0,
        "runtime_min_h": 8.0,
    }

    voltage_match = re.search(r"(\d+(?:\.\d+)?)\s*V\b", source, flags=re.IGNORECASE)
    freq_match = re.search(r"(\d+(?:\.\d+)?)\s*Hz\b", source, flags=re.IGNORECASE)
    tol_match = re.search(r"[±\+\-]\s*(\d+(?:\.\d+)?)\s*%", source, flags=re.IGNORECASE)
    current_range = re.search(
        r"between\s+(\d+(?:\.\d+)?)\s*mA\s+and\s+(\d+(?:\.\d+)?)\s*mA",
        source,
        flags=re.IGNORECASE,
    )
    runtime_match = re.search(r"at\s+least\s+(\d+(?:\.\d+)?)\s*hours?", source, flags=re.IGNORECASE)

    targets = dict(defaults)
    if voltage_match:
        targets["supply_voltage_v"] = as_float(voltage_match.group(1), defaults["supply_voltage_v"])
    if freq_match:
        targets["target_freq_hz"] = as_float(freq_match.group(1), defaults["target_freq_hz"])
    if tol_match:
        targets["freq_tol_pct"] = as_float(tol_match.group(1), defaults["freq_tol_pct"])
    if current_range:
        lo = as_float(current_range.group(1), defaults["current_min_ma"])
        hi = as_float(current_range.group(2), defaults["current_max_ma"])
        targets["current_min_ma"] = min(lo, hi)
        targets["current_max_ma"] = max(lo, hi)
    if runtime_match:
        targets["runtime_min_h"] = as_float(runtime_match.group(1), defaults["runtime_min_h"])

    if targets["current_max_ma"] <= targets["current_min_ma"]:
        targets["current_max_ma"] = targets["current_min_ma"] + 5.0
    if targets["freq_tol_pct"] <= 0:
        targets["freq_tol_pct"] = defaults["freq_tol_pct"]
    return targets


def ensure_optimizer_dependencies(python_bin: str) -> None:
    check_cmd = [
        python_bin,
        "-c",
        "import numpy, scipy, sympy, matplotlib, pymoo, openai",
    ]
    check = subprocess.run(check_cmd, capture_output=True, text=True)
    if check.returncode == 0:
        return
    if not BOOTSTRAP_DEPS.exists():
        raise RuntimeError(f"Missing dependency bootstrap script: {BOOTSTRAP_DEPS}")
    boot_cmd = [python_bin, str(BOOTSTRAP_DEPS), "--minimal"]
    boot = subprocess.run(
        boot_cmd,
        cwd=REPO_ROOT.parent,
        text=True,
        capture_output=True,
        env=os.environ.copy(),
    )
    if boot.returncode != 0:
        raise RuntimeError(f"Failed to bootstrap optimizer deps.\nSTDOUT:\n{boot.stdout}\nSTDERR:\n{boot.stderr}")


def build_concept_optimization_sysml(concept: Dict[str, Any], concept_idx: int, targets: Dict[str, float]) -> str:
    package_name = f"concept_{concept_idx}_{safe_slug(str(concept.get('name', 'design')))}_optimization"
    target_freq = targets["target_freq_hz"]
    tol = targets["freq_tol_pct"] / 100.0
    freq_min = target_freq * (1.0 - tol)
    freq_max = target_freq * (1.0 + tol)
    target_current = (targets["current_min_ma"] + targets["current_max_ma"]) / 2.0
    supply_min = targets["supply_voltage_v"] * 0.95
    supply_max = targets["supply_voltage_v"] * 1.05
    runtime_min = targets["runtime_min_h"]

    return f"""package {package_name} {{
  public import ScalarValues::*;

  part def FlasherDesign {{
    attribute timing_resistor_kohm : Real;
    attribute timing_cap_uF : Real;
    attribute resistor_ohm : Real;
    attribute led_current_mA : Real;
    attribute supply_voltage_V : Real;
    attribute driver_quiescent_mA : Real;
    attribute battery_capacity_mAh : Real;
    attribute efficiency_factor : Real;

    attribute blink_frequency_hz : Real;
    attribute avg_current_mA : Real;
    attribute runtime_hours : Real;
    attribute total_cost_usd : Real;
    attribute performance_penalty : Real;
  }}

  part design : FlasherDesign;

  requirement def OptimizationObjectives {{
    attribute minimize_cost : Boolean = true;
    attribute minimize_performance_penalty : Boolean = true;
  }}

  constraint def VariableBounds {{
    parameter timing_resistor_kohm : Real;
    parameter timing_cap_uF : Real;
    parameter resistor_ohm : Real;
    parameter led_current_mA : Real;
    parameter supply_voltage_V : Real;
    parameter driver_quiescent_mA : Real;
    parameter battery_capacity_mAh : Real;
    parameter efficiency_factor : Real;

    constraint {{ timing_resistor_kohm >= 1.0 and timing_resistor_kohm <= 200.0; }}
    constraint {{ timing_cap_uF >= 0.01 and timing_cap_uF <= 100.0; }}
    constraint {{ resistor_ohm >= 100.0 and resistor_ohm <= 2200.0; }}
    constraint {{ led_current_mA >= {fmt_num(targets["current_min_ma"])} and led_current_mA <= {fmt_num(targets["current_max_ma"])}; }}
    constraint {{ supply_voltage_V >= {fmt_num(supply_min)} and supply_voltage_V <= {fmt_num(supply_max)}; }}
    constraint {{ driver_quiescent_mA >= 0.2 and driver_quiescent_mA <= 20.0; }}
    constraint {{ battery_capacity_mAh >= 500.0 and battery_capacity_mAh <= 6000.0; }}
    constraint {{ efficiency_factor >= 0.60 and efficiency_factor <= 0.98; }}
  }}

  constraint def SystemModel {{
    parameter timing_resistor_kohm : Real;
    parameter timing_cap_uF : Real;
    parameter resistor_ohm : Real;
    parameter led_current_mA : Real;
    parameter supply_voltage_V : Real;
    parameter driver_quiescent_mA : Real;
    parameter battery_capacity_mAh : Real;
    parameter efficiency_factor : Real;

    parameter blink_frequency_hz : Real;
    parameter avg_current_mA : Real;
    parameter runtime_hours : Real;
    parameter total_cost_usd : Real;
    parameter performance_penalty : Real;

    parameter target_freq_hz : Real = {fmt_num(target_freq)};
    parameter target_current_mA : Real = {fmt_num(target_current)};

    constraint {{
      blink_frequency_hz == 1.44 / ((timing_resistor_kohm * 1000.0) * (timing_cap_uF * 0.000001));
    }}
    constraint {{
      avg_current_mA == driver_quiescent_mA + (0.5 * led_current_mA);
    }}
    constraint {{
      runtime_hours == battery_capacity_mAh / avg_current_mA;
    }}
    constraint {{
      total_cost_usd == (0.04 * timing_resistor_kohm) + (0.12 * timing_cap_uF) + (0.0025 * resistor_ohm)
                        + (0.02 * led_current_mA) + (0.005 * battery_capacity_mAh) + (0.4 / efficiency_factor);
    }}
    constraint {{
      performance_penalty == ((blink_frequency_hz - target_freq_hz) * (blink_frequency_hz - target_freq_hz))
                             + ((led_current_mA - target_current_mA) * (led_current_mA - target_current_mA));
    }}
  }}

  constraint def RequirementConstraints {{
    parameter blink_frequency_hz : Real;
    parameter led_current_mA : Real;
    parameter runtime_hours : Real;
    parameter supply_voltage_V : Real;

    constraint {{ blink_frequency_hz >= {fmt_num(freq_min)} and blink_frequency_hz <= {fmt_num(freq_max)}; }}
    constraint {{ led_current_mA >= {fmt_num(targets["current_min_ma"])} and led_current_mA <= {fmt_num(targets["current_max_ma"])}; }}
    constraint {{ runtime_hours >= {fmt_num(runtime_min)}; }}
    constraint {{ supply_voltage_V >= {fmt_num(supply_min)} and supply_voltage_V <= {fmt_num(supply_max)}; }}
  }}

  constraint def ObjectiveCost {{
    parameter total_cost_usd : Real;
    constraint {{ total_cost_usd == design.total_cost_usd; }}
  }}

  constraint def ObjectivePerformance {{
    parameter performance_penalty : Real;
    constraint {{ performance_penalty == design.performance_penalty; }}
  }}

  assert VariableBounds(
    timing_resistor_kohm=design.timing_resistor_kohm,
    timing_cap_uF=design.timing_cap_uF,
    resistor_ohm=design.resistor_ohm,
    led_current_mA=design.led_current_mA,
    supply_voltage_V=design.supply_voltage_V,
    driver_quiescent_mA=design.driver_quiescent_mA,
    battery_capacity_mAh=design.battery_capacity_mAh,
    efficiency_factor=design.efficiency_factor
  );

  assert SystemModel(
    timing_resistor_kohm=design.timing_resistor_kohm,
    timing_cap_uF=design.timing_cap_uF,
    resistor_ohm=design.resistor_ohm,
    led_current_mA=design.led_current_mA,
    supply_voltage_V=design.supply_voltage_V,
    driver_quiescent_mA=design.driver_quiescent_mA,
    battery_capacity_mAh=design.battery_capacity_mAh,
    efficiency_factor=design.efficiency_factor,
    blink_frequency_hz=design.blink_frequency_hz,
    avg_current_mA=design.avg_current_mA,
    runtime_hours=design.runtime_hours,
    total_cost_usd=design.total_cost_usd,
    performance_penalty=design.performance_penalty
  );

  assert RequirementConstraints(
    blink_frequency_hz=design.blink_frequency_hz,
    led_current_mA=design.led_current_mA,
    runtime_hours=design.runtime_hours,
    supply_voltage_V=design.supply_voltage_V
  );

  assert ObjectiveCost(total_cost_usd=design.total_cost_usd);
  assert ObjectivePerformance(performance_penalty=design.performance_penalty);
  assert OptimizationObjectives();
}}
"""


def run_numeric_fallback_optimizer(
    concept_idx: int,
    targets: Dict[str, float],
    concept_dir: Path,
) -> Dict[str, Any]:
    """
    Fallback optimizer used only when syspipe generation/execution fails.
    Performs a constrained multi-objective search and returns least-penalized solution.
    """
    import numpy as np

    freq_target = targets["target_freq_hz"]
    tol = targets["freq_tol_pct"] / 100.0
    freq_min = freq_target * (1.0 - tol)
    freq_max = freq_target * (1.0 + tol)
    current_min = targets["current_min_ma"]
    current_max = targets["current_max_ma"]
    runtime_min = targets["runtime_min_h"]
    supply_v = targets["supply_voltage_v"]
    supply_min = supply_v * 0.95
    supply_max = supply_v * 1.05
    target_current = 0.5 * (current_min + current_max)

    names = [
        "timing_resistor_kohm",
        "timing_cap_uF",
        "resistor_ohm",
        "led_current_mA",
        "supply_voltage_V",
        "driver_quiescent_mA",
        "battery_capacity_mAh",
        "efficiency_factor",
    ]
    lb = np.array([1.0, 0.01, 100.0, current_min, supply_min, 0.2, 500.0, 0.60], dtype=float)
    ub = np.array([200.0, 100.0, 2200.0, current_max, supply_max, 20.0, 6000.0, 0.98], dtype=float)

    rng = np.random.default_rng(1234 + int(concept_idx))
    n_samples = int(os.environ.get("FALLBACK_OPT_SAMPLES", "30000"))
    samples = rng.random((n_samples, len(names)), dtype=float) * (ub - lb) + lb

    tr = samples[:, 0]
    tc = samples[:, 1]
    rohm = samples[:, 2]
    iled = samples[:, 3]
    vs = samples[:, 4]
    iq = samples[:, 5]
    batt = samples[:, 6]
    eff = samples[:, 7]

    freq = 1440.0 / (tr * tc)
    avg_current = iq + 0.5 * iled
    runtime = batt / np.maximum(avg_current, 1e-9)
    total_cost = (0.04 * tr) + (0.12 * tc) + (0.0025 * rohm) + (0.02 * iled) + (0.005 * batt) + (0.4 / eff)
    perf_penalty = (freq - freq_target) ** 2 + (iled - target_current) ** 2

    violation = (
        np.maximum(0.0, freq_min - freq)
        + np.maximum(0.0, freq - freq_max)
        + np.maximum(0.0, current_min - iled)
        + np.maximum(0.0, iled - current_max)
        + np.maximum(0.0, runtime_min - runtime)
        + np.maximum(0.0, supply_min - vs)
        + np.maximum(0.0, vs - supply_max)
    )

    # Multi-objective tradeoff with strong feasibility priority.
    score = total_cost + perf_penalty + (1e6 * violation)
    best_idx = int(np.argmin(score))
    best = samples[best_idx]

    row = {
        "f1": f"{float(total_cost[best_idx]):.18e}",
        "f2": f"{float(perf_penalty[best_idx]):.18e}",
        "feasible": "1.0" if float(violation[best_idx]) <= 1e-9 else "0.0",
    }
    for i, value in enumerate(best, 1):
        row[f"x{i}"] = f"{float(value):.18e}"

    # Emit CSV so downstream tooling still has optimizer-like artifacts.
    best_csv = concept_dir / "best_solution.csv"
    with best_csv.open("w", encoding="utf-8", newline="") as f:
        writer = csv.DictWriter(f, fieldnames=list(row.keys()))
        writer.writeheader()
        writer.writerow(row)

    optimized_values = {name: float(best[i]) for i, name in enumerate(names)}
    objective_values = {
        "f1": float(total_cost[best_idx]),
        "f2": float(perf_penalty[best_idx]),
    }
    return {
        "status": "success",
        "source_csv": "best_solution.csv",
        "optimized_values": optimized_values,
        "objective_values": objective_values,
        "raw_row": row,
        "fallback_optimizer": "random_search_penalty",
        "feasible": bool(float(violation[best_idx]) <= 1e-9),
        "violation": float(violation[best_idx]),
    }


def parse_variable_names(prompt_path: Path) -> List[str]:
    if not prompt_path.exists():
        return []
    names: List[str] = []
    in_vars = False
    for raw in prompt_path.read_text(encoding="utf-8").splitlines():
        line = raw.strip()
        lower = line.lower()
        if lower.startswith("variables"):
            in_vars = True
            continue
        if in_vars and (lower.startswith("objectives") or lower.startswith("constraints")):
            break
        if in_vars and line.startswith("-"):
            m = re.match(r"-\s*([A-Za-z_][A-Za-z0-9_]*)\b", line)
            if m:
                names.append(m.group(1))
    return names


def parse_solution_row(run_dir: Path) -> Dict[str, Any]:
    best_csv = run_dir / "best_solution.csv"
    pareto_csv = run_dir / "pareto_solutions.csv"
    rows: List[Dict[str, str]] = []
    source_path: Optional[Path] = None

    if best_csv.exists():
        source_path = best_csv
    elif pareto_csv.exists():
        source_path = pareto_csv
    else:
        raise RuntimeError(f"No optimization solution CSV found under {run_dir}")

    with source_path.open("r", encoding="utf-8") as f:
        reader = csv.DictReader(f)
        rows = [r for r in reader]
    if not rows:
        raise RuntimeError(f"Optimization CSV is empty: {source_path}")

    if source_path == pareto_csv and len(rows) > 1:
        obj_cols = sorted([c for c in rows[0].keys() if re.fullmatch(r"f\d+", c or "")], key=lambda x: int(x[1:]))
        def row_score(row: Dict[str, str]) -> float:
            feasible = as_float(row.get("feasible"), 1.0)
            penalty = 0.0 if feasible >= 1.0 else 1e6
            return penalty + sum(as_float(row.get(c), 0.0) for c in obj_cols)
        rows.sort(key=row_score)
    return {"row": rows[0], "source": source_path.name}


def try_recover_generated_script(concept_dir: Path, syspipe_stderr: str) -> Dict[str, Any]:
    script_path = concept_dir / "generated_auto.py"
    if not script_path.exists():
        return {"ok": False, "reason": "generated_auto.py missing"}

    script_original = script_path.read_text(encoding="utf-8")
    candidates: List[tuple[str, str]] = []
    seen_candidates: set[str] = set()

    def add_candidate(name: str, text: str) -> None:
        if text in seen_candidates:
            return
        seen_candidates.add(text)
        candidates.append((name, text))

    def patch_return_least_infeasible(text: str) -> tuple[str, int]:
        if "return_least_infeasible" in text:
            return text, 0
        return re.subn(
            r"(\bres\s*=\s*minimize\([^\n]*?verbose\s*=\s*False)(\s*\))",
            r"\1, return_least_infeasible=True\2",
            text,
            count=1,
        )

    def _flatten_repl(match: re.Match[str]) -> str:
        indent = match.group(1)
        return (
            f"{indent}X = np.asarray(X, dtype=float)\n"
            f"{indent}if X.ndim > 1:\n"
            f"{indent}    X = X.reshape(-1)"
        )

    # Candidate 1: patch first "X = np.atleast_2d(X)" line in _evaluate body.
    text1, n1 = re.subn(
        r"^(\s*)X\s*=\s*np\.atleast_2d\(X\)\s*$",
        _flatten_repl,
        script_original,
        count=1,
        flags=re.MULTILINE,
    )
    if n1 > 0:
        add_candidate("flatten_first_atleast2d", text1)

    # Candidate 2: patch all such lines, useful when script has multiple guards.
    text2, n2 = re.subn(
        r"^(\s*)X\s*=\s*np\.atleast_2d\(X\)\s*$",
        _flatten_repl,
        script_original,
        flags=re.MULTILINE,
    )
    if n2 > 0 and text2 != text1:
        add_candidate("flatten_all_atleast2d", text2)

    # Candidate 3: inject flattening directly after _evaluate signature for scalar indexing scripts.
    if re.search(r"=\s*X\[\d+\]", script_original):
        text3, n3 = re.subn(
            r"(def _evaluate\(self,\s*X,\s*out,\s*\*args,\s*\*\*kwargs\):\n)",
            (
                r"\1"
                r"        X = np.asarray(X, dtype=float)\n"
                r"        if X.ndim > 1:\n"
                r"            X = X.reshape(-1)\n"
            ),
            script_original,
            count=1,
        )
        if n3 > 0 and text3 not in {script_original, text1, text2}:
            add_candidate("inject_flatten_after_signature", text3)

    # Candidate 4+: ensure optimization returns least-infeasible solution
    # so scripts still emit numeric outputs when strict feasibility is hard.
    base_for_infeasible = [("original", script_original), *candidates]
    for strategy, base_text in base_for_infeasible:
        patched_text, patched_count = patch_return_least_infeasible(base_text)
        if patched_count > 0:
            add_candidate(f"{strategy}+least_infeasible", patched_text)

    # If no concrete patch candidates were generated, run once for diagnostics.
    if not candidates:
        rerun = subprocess.run(
            [sys.executable, str(script_path)],
            cwd=concept_dir,
            text=True,
            capture_output=True,
            env=os.environ.copy(),
        )
        ok = rerun.returncode == 0 and ((concept_dir / "best_solution.csv").exists() or (concept_dir / "pareto_solutions.csv").exists())
        return {
            "ok": ok,
            "patched": False,
            "strategy": None,
            "stdout": rerun.stdout,
            "stderr": rerun.stderr,
            "returncode": rerun.returncode,
        }

    attempts: List[Dict[str, Any]] = []
    last_result: Optional[subprocess.CompletedProcess[str]] = None
    for strategy, candidate_text in candidates:
        script_path.write_text(candidate_text, encoding="utf-8")
        rerun = subprocess.run(
            [sys.executable, str(script_path)],
            cwd=concept_dir,
            text=True,
            capture_output=True,
            env=os.environ.copy(),
        )
        last_result = rerun
        ok = rerun.returncode == 0 and ((concept_dir / "best_solution.csv").exists() or (concept_dir / "pareto_solutions.csv").exists())
        attempts.append(
            {
                "strategy": strategy,
                "returncode": rerun.returncode,
                "stderr_tail": (rerun.stderr or "")[-800:],
            }
        )
        if ok:
            return {
                "ok": True,
                "patched": True,
                "strategy": strategy,
                "stdout": rerun.stdout,
                "stderr": rerun.stderr,
                "returncode": rerun.returncode,
                "attempts": attempts,
            }

    # Restore original script for easier debugging if all recovery attempts fail.
    script_path.write_text(script_original, encoding="utf-8")
    if last_result is None:
        return {
            "ok": False,
            "patched": False,
            "strategy": None,
            "stdout": "",
            "stderr": syspipe_stderr,
            "returncode": 1,
            "attempts": attempts,
        }
    return {
        "ok": False,
        "patched": True,
        "strategy": attempts[-1]["strategy"] if attempts else None,
        "stdout": last_result.stdout,
        "stderr": last_result.stderr,
        "returncode": last_result.returncode,
        "attempts": attempts,
    }


def run_optimizer_for_concept(
    concept_idx: int,
    concept: Dict[str, Any],
    targets: Dict[str, float],
    run_dir: Path,
    model: str,
    decision_mode: str,
    decision_model: str | None,
) -> Dict[str, Any]:
    concept_dir = run_dir / "optimization" / f"concept_{concept_idx}"
    concept_dir.mkdir(parents=True, exist_ok=True)
    model_path = concept_dir / "model.sysml"
    model_path.write_text(build_concept_optimization_sysml(concept, concept_idx, targets), encoding="utf-8")

    objectives_path = concept_dir / "objectives.txt"
    objectives_path.write_text("- (minimize) total_cost_usd\n- (minimize) performance_penalty\n", encoding="utf-8")

    optimizer_model = os.environ.get("OPTIMIZER_SCRIPT_MODEL", "gpt-5-mini")
    cmd = [
        sys.executable,
        "-m",
        "optimization.scripts.syspipe",
        "--sysml",
        str(model_path),
        "--out",
        str(concept_dir / "generated_auto.py"),
        "--prompt-out",
        str(concept_dir / "prompt.txt"),
        "--model",
        optimizer_model,
        "--objectives-file",
        str(objectives_path),
        "--skip-checker",
        "--no-refine-unknown-checks",
        "--decision-mode",
        decision_mode,
    ]
    if decision_model:
        cmd.extend(["--decision-model", decision_model])
    optimizer_timeout = int(os.environ.get("OPTIMIZER_TIMEOUT_SEC", "240"))
    proc_stdout = ""
    proc_stderr = ""
    proc_returncode = 0
    timed_out = False
    try:
        proc = subprocess.run(
            cmd,
            cwd=REPO_ROOT.parent,
            text=True,
            capture_output=True,
            env=os.environ.copy(),
            timeout=optimizer_timeout,
        )
        proc_stdout = proc.stdout or ""
        proc_stderr = proc.stderr or ""
        proc_returncode = proc.returncode
    except subprocess.TimeoutExpired as exc:
        timed_out = True
        proc_returncode = 124
        proc_stdout = (exc.stdout.decode("utf-8", errors="ignore") if isinstance(exc.stdout, bytes) else (exc.stdout or ""))
        proc_stderr = (exc.stderr.decode("utf-8", errors="ignore") if isinstance(exc.stderr, bytes) else (exc.stderr or ""))
        proc_stderr = f"{proc_stderr}\nsyspipe timed out after {optimizer_timeout}s".strip()

    recovered = {"ok": False}
    if proc_returncode != 0:
        recovered = try_recover_generated_script(concept_dir, proc_stderr or "")
        if not recovered.get("ok"):
            fallback = run_numeric_fallback_optimizer(concept_idx, targets, concept_dir)
            if fallback.get("status") == "success":
                best_payload = {
                    "concept_index": concept_idx,
                    "status": "success",
                    "source_csv": fallback.get("source_csv", "best_solution.csv"),
                    "optimized_values": fallback.get("optimized_values", {}),
                    "objective_values": fallback.get("objective_values", {}),
                    "raw_row": fallback.get("raw_row", {}),
                    "recovered_from_syspipe_error": True,
                    "fallback_optimizer": fallback.get("fallback_optimizer"),
                    "fallback_feasible": fallback.get("feasible"),
                    "fallback_violation": fallback.get("violation"),
                }
                (concept_dir / "best_solution.json").write_text(json.dumps(best_payload, indent=2), encoding="utf-8")
                return {
                    **best_payload,
                    "model_path": str(model_path),
                    "best_solution_path": str(concept_dir / "best_solution.json"),
                    "stdout": proc_stdout,
                    "stderr": proc_stderr,
                    "recovery": recovered,
                }
            payload = {
                "concept_index": concept_idx,
                "status": "error",
                "model_path": str(model_path),
                "stdout": proc_stdout,
                "stderr": proc_stderr,
                "error": (
                    f"syspipe timed out after {optimizer_timeout}s"
                    if timed_out
                    else f"syspipe failed with code {proc_returncode}"
                ),
                "recovery": recovered,
            }
            (concept_dir / "best_solution.json").write_text(json.dumps(payload, indent=2), encoding="utf-8")
            return payload

    try:
        solution = parse_solution_row(concept_dir)
    except Exception as exc:
        payload = {
            "concept_index": concept_idx,
            "status": "error",
            "model_path": str(model_path),
            "stdout": proc_stdout,
            "stderr": proc_stderr,
            "error": str(exc),
        }
        (concept_dir / "best_solution.json").write_text(json.dumps(payload, indent=2), encoding="utf-8")
        return payload
    var_names = parse_variable_names(concept_dir / "prompt.txt")
    row = solution["row"]
    x_cols = sorted([k for k in row.keys() if re.fullmatch(r"x\d+", k or "")], key=lambda c: int(c[1:]))
    optimized_values: Dict[str, float] = {}
    for i, col in enumerate(x_cols):
        key = var_names[i] if i < len(var_names) else col
        optimized_values[key] = as_float(row.get(col))

    objective_values = {k: as_float(v) for k, v in row.items() if re.fullmatch(r"f\d+", k or "")}
    best_payload = {
        "concept_index": concept_idx,
        "status": "success",
        "source_csv": solution["source"],
        "optimized_values": optimized_values,
        "objective_values": objective_values,
        "raw_row": row,
        "recovered_from_syspipe_error": bool(proc_returncode != 0 and recovered.get("ok")),
    }
    (concept_dir / "best_solution.json").write_text(json.dumps(best_payload, indent=2), encoding="utf-8")
    return {
        **best_payload,
        "model_path": str(model_path),
        "best_solution_path": str(concept_dir / "best_solution.json"),
        "stdout": proc_stdout,
        "stderr": proc_stderr,
    }


def run_concept_optimizations(
    concepts: List[Dict[str, Any]],
    targets: Dict[str, float],
    run_dir: Path,
    model: str,
    decision_mode: str,
    decision_model: str | None,
    max_parallel: int,
) -> List[Dict[str, Any]]:
    if not concepts:
        return []

    worker_count = max(1, min(max_parallel, len(concepts)))
    results_by_index: Dict[int, Dict[str, Any]] = {}

    with ThreadPoolExecutor(max_workers=worker_count) as executor:
        future_map = {
            executor.submit(
                run_optimizer_for_concept,
                ci,
                concept,
                targets,
                run_dir,
                model,
                decision_mode,
                decision_model,
            ): ci
            for ci, concept in enumerate(concepts, 1)
        }
        for future in as_completed(future_map):
            ci = future_map[future]
            try:
                results_by_index[ci] = future.result()
            except Exception as exc:
                concept_dir = run_dir / "optimization" / f"concept_{ci}"
                concept_dir.mkdir(parents=True, exist_ok=True)
                result = {
                    "concept_index": ci,
                    "status": "error",
                    "model_path": str(concept_dir / "model.sysml"),
                    "best_solution_path": str(concept_dir / "best_solution.json"),
                    "error": str(exc),
                }
                (concept_dir / "best_solution.json").write_text(json.dumps(result, indent=2), encoding="utf-8")
                results_by_index[ci] = result

    return [results_by_index[ci] for ci in range(1, len(concepts) + 1)]


def token_set(text: str) -> set[str]:
    return {t for t in re.split(r"[^a-zA-Z0-9]+", text.lower()) if t}


def build_slot_search_input(
    concept: Dict[str, Any],
    slot: Dict[str, Any],
    optimized_values: Dict[str, float],
    targets: Dict[str, float],
    user_brief: str,
) -> Dict[str, Any]:
    slot_name = str(slot.get("slot") or slot.get("name") or "component").strip()
    slot_slug = safe_slug(slot_name)
    queries = [str(q).strip() for q in (slot.get("search_queries") or []) if str(q).strip()]
    keywords = list(queries[:2])
    if concept.get("name"):
        keywords.append(str(concept["name"]))
    keywords.append(slot_name)
    keywords = [k for k in keywords if k]

    resistor_ohm = optimized_values.get("resistor_ohm", 330.0)
    led_current = optimized_values.get("led_current_mA", (targets["current_min_ma"] + targets["current_max_ma"]) / 2.0)
    supply_v = optimized_values.get("supply_voltage_V", targets["supply_voltage_v"])

    data: Dict[str, Any] = {
        "slot": slot_slug,
        "keywords": keywords,
        "brief": user_brief,
        "concept_name": str(concept.get("name") or ""),
        "concept_approach": str(concept.get("approach") or ""),
        "slot_purpose": str(slot.get("purpose") or ""),
        "optimized_targets": {k: v for k, v in optimized_values.items() if isinstance(v, (int, float))},
    }

    if "resistor" in slot_slug:
        data.update(
            {
                "category": "resistor",
                "value": f"{int(round(resistor_ohm))} ohm",
                "power": "0.25W",
                "tolerance": "1%",
                "package": "through-hole or 0805",
            }
        )
    elif "led" in slot_slug:
        data.update(
            {
                "category": "led",
                "current": f"{fmt_num(led_current)}mA",
                "voltage": f"{fmt_num(supply_v)}V",
                "features": ["indicator", "visible"],
            }
        )
    elif any(k in slot_slug for k in ("driver", "timer", "mcu", "opamp", "controller")):
        data.update(
            {
                "category": "ic",
                "voltage": f"{fmt_num(supply_v)}V",
                "features": ["timer", "oscillator", "low power"],
            }
        )
    elif any(k in slot_slug for k in ("supply", "battery", "power")):
        data.update(
            {
                "category": "power supply",
                "voltage": f"{fmt_num(supply_v)}V",
                "current": "0.05A",
                "features": ["rechargeable", "regulated"],
            }
        )
    return data


def run_structured_part_search(
    search_input: Dict[str, Any],
    limit: int,
    providers: List[str],
    timeout_sec: int,
) -> Dict[str, Any]:
    cmd: List[str] = ["npm", "run", "-s", "cli", "--", "--json", "--limit", str(limit)]
    for provider in providers:
        cmd.extend(["--provider", provider])

    field_map = {
        "category": "--category",
        "manufacturer": "--manufacturer",
        "partNumber": "--partNumber",
        "value": "--value",
        "tolerance": "--tolerance",
        "power": "--power",
        "voltage": "--voltage",
        "current": "--current",
        "package": "--package",
        "material": "--material",
        "temperatureCoefficient": "--temperatureCoefficient",
    }
    for key, flag in field_map.items():
        value = search_input.get(key)
        if value:
            cmd.extend([flag, str(value)])

    for kw in search_input.get("keywords", []) or []:
        if str(kw).strip():
            cmd.extend(["--keyword", str(kw).strip()])
    for ft in search_input.get("features", []) or []:
        if str(ft).strip():
            cmd.extend(["--feature", str(ft).strip()])

    timeout_arg: float | None = None if timeout_sec <= 0 else float(timeout_sec)
    try:
        proc = subprocess.run(
            cmd,
            cwd=REPO_ROOT,
            text=True,
            capture_output=True,
            timeout=timeout_arg,
            env=os.environ.copy(),
        )
    except subprocess.TimeoutExpired:
        return {"status": "timeout", "input": search_input, "results": [], "error": f"timeout after {timeout_sec}s"}

    if proc.returncode != 0:
        return {
            "status": "error",
            "input": search_input,
            "results": [],
            "error": (proc.stderr or proc.stdout or "").strip() or f"search failed: code {proc.returncode}",
        }

    stdout = (proc.stdout or "").strip()
    try:
        payload = json.loads(stdout)
    except Exception:
        start = stdout.find("{")
        end = stdout.rfind("}")
        if start >= 0 and end > start:
            payload = json.loads(stdout[start : end + 1])
        else:
            return {"status": "error", "input": search_input, "results": [], "error": "invalid JSON from CLI"}
    return {"status": "ok", "input": search_input, **payload}


def run_configurator_part_picker(
    search_input: Dict[str, Any],
    slot_name: str,
    requirements_sysml: Path,
    timeout_sec: int,
    sites: Optional[List[str]] = None,
) -> Dict[str, Any]:
    if not CONFIG_PART_PICKER.exists():
        return {
            "status": "error",
            "input": search_input,
            "results": [],
            "error": f"missing configurator part picker: {CONFIG_PART_PICKER}",
        }

    picker_timeout = int(os.environ.get("CONFIGURATOR_PICKER_TIMEOUT_SEC", str(max(timeout_sec, 180))))
    picker_timeout_buffer = int(os.environ.get("CONFIGURATOR_PICKER_TIMEOUT_BUFFER_SEC", "180"))
    timeout_arg: float | None = None if picker_timeout <= 0 else float(max(picker_timeout + picker_timeout_buffer, 20))
    cmd = [
        "node",
        str(CONFIG_PART_PICKER),
        "--sysml-file",
        str(requirements_sysml),
        "--slot",
        slot_name,
        "--search-input-json",
        json.dumps(search_input, ensure_ascii=True),
        "--timeout-sec",
        str(picker_timeout),
    ]
    if sites:
        filtered_sites = [s.strip() for s in sites if s.strip()]
        if filtered_sites:
            cmd.extend(["--sites", ",".join(filtered_sites)])

    try:
        proc = subprocess.run(
            cmd,
            cwd=CONFIGURATOR_DIR,
            text=True,
            capture_output=True,
            timeout=timeout_arg,
            env=os.environ.copy(),
        )
    except subprocess.TimeoutExpired:
        return {
            "status": "timeout",
            "input": search_input,
            "results": [],
            "error": f"timeout after {picker_timeout}s",
        }

    stdout = (proc.stdout or "").strip()
    if proc.returncode != 0 and not stdout:
        return {
            "status": "error",
            "input": search_input,
            "results": [],
            "error": (proc.stderr or "").strip() or f"configurator picker failed: {proc.returncode}",
        }

    try:
        payload = json.loads(stdout)
    except Exception:
        start = stdout.find("{")
        end = stdout.rfind("}")
        if start >= 0 and end > start:
            payload = json.loads(stdout[start : end + 1])
        else:
            return {
                "status": "error",
                "input": search_input,
                "results": [],
                "error": "invalid JSON from configurator picker",
            }

    status = str(payload.get("status", "not_found"))
    if status == "selected":
        item = {
            "supplier": payload.get("supplier") or payload.get("provider") or payload.get("manufacturer") or None,
            "manufacturer": payload.get("manufacturer"),
            "manufacturerPartNumber": payload.get("manufacturerPartNumber"),
            "description": payload.get("description") or payload.get("title"),
            "stock": payload.get("stock"),
            "unitPrice": payload.get("unitPrice"),
            "url": payload.get("url"),
            "provider": "configurator",
            "attributes": payload.get("attributes") or {},
        }
        return {
            "status": "ok",
            "input": search_input,
            "source": "configurator",
            "count": 1,
            "results": [item],
            "raw": payload,
        }

    return {
        "status": "ok",
        "input": search_input,
        "source": "configurator",
        "count": 0,
        "results": [],
        "error": payload.get("reason") or "no_results",
        "raw": payload,
    }


def _search_count(search_result: Dict[str, Any]) -> int:
    count = search_result.get("count")
    if count is not None:
        return int(as_float(count, 0.0))
    return len(search_result.get("results") or [])


def build_relaxed_search_inputs(search_input: Dict[str, Any]) -> List[Dict[str, Any]]:
    attempts: List[Dict[str, Any]] = []
    attempts.append(dict(search_input))

    relaxed = dict(search_input)
    for key in ("value", "tolerance", "power", "voltage", "current", "package", "manufacturer", "partNumber", "features"):
        relaxed.pop(key, None)
    attempts.append(relaxed)

    slot_kw = str(search_input.get("slot") or "component")
    keywords = [k for k in (search_input.get("keywords") or []) if str(k).strip()]
    attempts.append(
        {
            "slot": slot_kw,
            "category": search_input.get("category"),
            "keywords": keywords[:2] + [slot_kw],
        }
    )
    attempts.append(
        {
            "slot": slot_kw,
            "keywords": [slot_kw],
        }
    )

    unique: List[Dict[str, Any]] = []
    seen: set[str] = set()
    for item in attempts:
        marker = json.dumps(item, sort_keys=True, ensure_ascii=True)
        if marker in seen:
            continue
        seen.add(marker)
        unique.append(item)
    return unique


def run_configurator_part_picker_with_relaxation(
    search_input: Dict[str, Any],
    slot_name: str,
    requirements_sysml: Path,
    timeout_sec: int,
    sites: Optional[List[str]] = None,
) -> Dict[str, Any]:
    attempts: List[Dict[str, Any]] = []
    last_result: Dict[str, Any] = {"status": "error", "results": [], "count": 0, "error": "no_attempts"}
    used_input = dict(search_input)
    for candidate_input in build_relaxed_search_inputs(search_input):
        result = run_configurator_part_picker(
            search_input=candidate_input,
            slot_name=slot_name,
            requirements_sysml=requirements_sysml,
            timeout_sec=timeout_sec,
            sites=sites,
        )
        attempts.append(
            {
                "input": candidate_input,
                "status": result.get("status"),
                "count": _search_count(result),
                "error": result.get("error"),
            }
        )
        last_result = result
        used_input = candidate_input
        if _search_count(result) > 0:
            break
    return {
        "search_result": last_result,
        "used_input": used_input,
        "attempts": attempts,
    }


def run_structured_part_search_with_relaxation(
    search_input: Dict[str, Any],
    limit: int,
    providers: List[str],
    timeout_sec: int,
) -> Dict[str, Any]:
    attempts: List[Dict[str, Any]] = []
    last_result: Dict[str, Any] = {"status": "error", "results": [], "count": 0, "error": "no_attempts"}
    used_input = dict(search_input)
    for candidate_input in build_relaxed_search_inputs(search_input):
        result = run_structured_part_search(candidate_input, limit, providers, timeout_sec)
        attempts.append(
            {
                "input": candidate_input,
                "status": result.get("status"),
                "count": _search_count(result),
                "error": result.get("error"),
            }
        )
        last_result = result
        used_input = candidate_input
        if _search_count(result) > 0:
            break
        status = str(result.get("status", "")).lower()
        if status == "timeout":
            # Do not cascade into more slow attempts after a hard timeout.
            break
        if status == "error":
            # Infrastructure/parse errors are unlikely to recover via relaxed input.
            break
    return {
        "search_result": last_result,
        "used_input": used_input,
        "attempts": attempts,
    }


def constraint_match_score(part: Dict[str, Any], search_input: Dict[str, Any]) -> int:
    hay = " ".join(
        [
            str(part.get("manufacturer", "")),
            str(part.get("manufacturerPartNumber", "")),
            str(part.get("description", "")),
            " ".join(str(v) for v in (part.get("attributes") or {}).values()),
        ]
    ).lower()
    hay_tokens = token_set(hay)

    desired: List[str] = []
    for key in ("value", "voltage", "current", "power", "package", "manufacturer", "partNumber"):
        value = search_input.get(key)
        if value:
            desired.extend(token_set(str(value)))
    for kw in search_input.get("keywords", []) or []:
        desired.extend(token_set(str(kw)))

    score = 0
    for tok in desired:
        if tok in hay_tokens:
            score += 1
    return score


def pick_best_part(search_result: Dict[str, Any], search_input: Dict[str, Any]) -> Dict[str, Any]:
    results = list(search_result.get("results") or [])
    if not results:
        return {
            "status": "not_found",
            "reason": search_result.get("error") or "no_results",
            "constraint_match_score": 0,
        }

    scored: List[Dict[str, Any]] = []
    for item in results:
        score = constraint_match_score(item, search_input)
        stock = int(as_float(item.get("stock"), 0.0))
        unit_price = as_float(item.get("unitPrice"), float("inf"))
        scored.append({**item, "_constraint_score": score, "_stock": stock, "_unit_price": unit_price})
    scored.sort(key=lambda it: (-it["_constraint_score"], -it["_stock"], it["_unit_price"]))
    best = scored[0]
    return {
        "status": "selected",
        "constraint_match_score": int(best["_constraint_score"]),
        "supplier": best.get("supplier"),
        "stock": best.get("stock"),
        "unitPrice": best.get("unitPrice"),
        "manufacturer": best.get("manufacturer"),
        "manufacturerPartNumber": best.get("manufacturerPartNumber"),
        "description": best.get("description"),
        "url": best.get("url"),
        "provider": best.get("provider"),
        "attributes": best.get("attributes") or {},
    }


def write_search_log(
    path: Path,
    original_search_input: Dict[str, Any],
    search_input_used: Dict[str, Any],
    search_result: Dict[str, Any],
    picked: Dict[str, Any],
    attempts: Optional[List[Dict[str, Any]]] = None,
) -> None:
    lines = []
    lines.append(f"slot: {original_search_input.get('slot', 'slot')}")
    lines.append(f"query_input_original: {json.dumps(original_search_input, ensure_ascii=True)}")
    lines.append(f"query_input_used: {json.dumps(search_input_used, ensure_ascii=True)}")
    if attempts:
        lines.append(f"search_attempts: {json.dumps(attempts, ensure_ascii=True)}")
    lines.append(f"search_status: {search_result.get('status', 'ok')}")
    if search_result.get("error"):
        lines.append(f"error: {search_result['error']}")
    lines.append(f"matches: {search_result.get('count', len(search_result.get('results', []) or []))}")
    lines.append("----")
    for item in (search_result.get("results") or [])[:10]:
        supplier = item.get("supplier") or item.get("provider") or ""
        supplier_suffix = f" @ {supplier}" if supplier else ""
        lines.append(f"{item.get('manufacturerPartNumber', 'unknown')} ({item.get('manufacturer', 'unknown')}){supplier_suffix}")
        if item.get("stock") is not None:
            lines.append(f"Stock: {item.get('stock')}")
        if item.get("unitPrice") is not None:
            lines.append(f"Unit price: {item.get('unitPrice')}")
        if item.get("url"):
            lines.append(f"URL: {item.get('url')}")
        lines.append("----")
    lines.append(f"selected: {json.dumps(picked, ensure_ascii=True)}")
    path.write_text("\n".join(lines) + "\n", encoding="utf-8")


def build_constraint_validation_sysml(
    concept: Dict[str, Any],
    concept_idx: int,
    optimized_values: Dict[str, float],
    targets: Dict[str, float],
    selected_slots: int,
    total_slots: int,
) -> str:
    tol = targets["freq_tol_pct"] / 100.0
    freq_min = targets["target_freq_hz"] * (1.0 - tol)
    freq_max = targets["target_freq_hz"] * (1.0 + tol)
    current_min = targets["current_min_ma"]
    current_max = targets["current_max_ma"]
    runtime_min = targets["runtime_min_h"]
    supply_min = targets["supply_voltage_v"] * 0.95
    supply_max = targets["supply_voltage_v"] * 1.05

    tr = as_float(optimized_values.get("timing_resistor_kohm"), 20.0)
    tc = as_float(optimized_values.get("timing_cap_uF"), 7.0)
    rohm = as_float(optimized_values.get("resistor_ohm"), 330.0)
    iled = as_float(optimized_values.get("led_current_mA"), 12.0)
    vsup = as_float(optimized_values.get("supply_voltage_V"), targets["supply_voltage_v"])
    iq = as_float(optimized_values.get("driver_quiescent_mA"), 2.0)
    batt = as_float(optimized_values.get("battery_capacity_mAh"), 1000.0)
    eff = as_float(optimized_values.get("efficiency_factor"), 0.85)
    selected = max(0, int(selected_slots))
    slots = max(0, int(total_slots))

    package_name = f"ConceptValidation_{concept_idx}_{safe_slug(str(concept.get('name', 'design')))}"
    return f"""package {package_name} {{
    part def Candidate {{
        attribute timing_resistor_kohm = 20.0;
        attribute timing_cap_uF = 7.0;
        attribute resistor_ohm = 330.0;
        attribute led_current_mA = 12.0;
        attribute supply_voltage_V = 5.0;
        attribute driver_quiescent_mA = 2.0;
        attribute battery_capacity_mAh = 1000.0;
        attribute efficiency_factor = 0.85;
        attribute selected_slots = 0.0;
        attribute total_slots = 0.0;

        assert constraint freqInRange {{
            (1.44e3 / (timing_resistor_kohm * timing_cap_uF)) >= {fmt_num(freq_min)} and
            (1.44e3 / (timing_resistor_kohm * timing_cap_uF)) <= {fmt_num(freq_max)}
        }}
        assert constraint currentInRange {{
            led_current_mA >= {fmt_num(current_min)} and led_current_mA <= {fmt_num(current_max)}
        }}
        assert constraint runtimeMin {{
            (battery_capacity_mAh / (driver_quiescent_mA + 0.5 * led_current_mA)) >= {fmt_num(runtime_min)}
        }}
        assert constraint supplyInRange {{
            supply_voltage_V >= {fmt_num(supply_min)} and supply_voltage_V <= {fmt_num(supply_max)}
        }}
        assert constraint partsAvailable {{
            selected_slots > 0
        }}
    }}

    part candidate_{concept_idx} : Candidate {{
        attribute timing_resistor_kohm redefines timing_resistor_kohm = {fmt_num(tr)};
        attribute timing_cap_uF redefines timing_cap_uF = {fmt_num(tc)};
        attribute resistor_ohm redefines resistor_ohm = {fmt_num(rohm)};
        attribute led_current_mA redefines led_current_mA = {fmt_num(iled)};
        attribute supply_voltage_V redefines supply_voltage_V = {fmt_num(vsup)};
        attribute driver_quiescent_mA redefines driver_quiescent_mA = {fmt_num(iq)};
        attribute battery_capacity_mAh redefines battery_capacity_mAh = {fmt_num(batt)};
        attribute efficiency_factor redefines efficiency_factor = {fmt_num(eff)};
        attribute selected_slots redefines selected_slots = {fmt_num(float(selected))};
        attribute total_slots redefines total_slots = {fmt_num(float(slots))};
    }}
}}
"""


def run_configurator_constraint_validation(
    validation_sysml_path: Path,
    output_path: Path,
    timeout_sec: int = 20,
) -> Dict[str, Any]:
    if not CONFIG_CONSTRAINT_VALIDATOR.exists():
        payload = {"status": "error", "error": f"missing validator: {CONFIG_CONSTRAINT_VALIDATOR}"}
        output_path.write_text(json.dumps(payload, indent=2), encoding="utf-8")
        return payload

    cmd = [sys.executable, str(CONFIG_CONSTRAINT_VALIDATOR), str(validation_sysml_path), "--compact"]
    try:
        proc = subprocess.run(
            cmd,
            text=True,
            capture_output=True,
            timeout=timeout_sec,
            env=os.environ.copy(),
        )
    except subprocess.TimeoutExpired:
        payload = {"status": "error", "error": f"constraint validator timeout after {timeout_sec}s"}
        output_path.write_text(json.dumps(payload, indent=2), encoding="utf-8")
        return payload

    raw_output = f"{proc.stdout or ''}{proc.stderr or ''}".strip()
    summary_match = re.search(r"Summary:\s*(\d+)\s+evaluated\s+\|\s*(\d+)\s+pass,\s*(\d+)\s+fail", raw_output)
    if summary_match:
        evaluated = int(summary_match.group(1))
        passed = int(summary_match.group(2))
        failed = int(summary_match.group(3))
        status = "pass" if failed == 0 and proc.returncode == 0 else "fail"
    else:
        evaluated = 0
        passed = 0
        failed = 0 if proc.returncode == 0 else 1
        status = "pass" if proc.returncode == 0 else "error"

    payload = {
        "status": status,
        "exit_code": proc.returncode,
        "evaluated": evaluated,
        "passed": passed,
        "failed": failed,
        "output": raw_output,
    }
    output_path.write_text(json.dumps(payload, indent=2), encoding="utf-8")
    return payload


def as_sysml_string(value: Any) -> str:
    text = "" if value is None else str(value)
    return text.replace('"', "'")


def write_optimized_design_instances_sysml(
    path: Path,
    concepts: List[Dict[str, Any]],
    optimization_results: List[Dict[str, Any]],
    optimized_bom_rows: List[Dict[str, Any]],
    constraint_validation_results: Optional[List[Dict[str, Any]]] = None,
) -> None:
    opt_by_idx = {int(r["concept_index"]): r for r in optimization_results if "concept_index" in r}
    val_by_idx = {
        int(r["concept_index"]): r
        for r in (constraint_validation_results or [])
        if "concept_index" in r
    }
    slots_by_idx: Dict[int, List[Dict[str, Any]]] = {}
    for row in optimized_bom_rows:
        idx = int(row.get("concept_index", 0))
        slots_by_idx.setdefault(idx, []).append(row)

    lines = ["package DesignInstancesOptimized {", "  public import ScalarValues::*;"]
    lines.append("  part def ConceptInstance {")
    lines.append("    attribute name: String;")
    lines.append("    attribute approach: String;")
    lines.append("    attribute optimizationStatus: String;")
    lines.append("    attribute partSelectionStatus: String;")
    lines.append("    attribute constraintValidationStatus: String;")
    lines.append("    attribute designFeasible: Boolean;")
    lines.append("  }")
    lines.append("  part def OptimizedAttribute {")
    lines.append("    attribute attr: String;")
    lines.append("    attribute value: Real;")
    lines.append("  }")
    lines.append("  part def SlotSelection {")
    lines.append("    attribute slot: String;")
    lines.append("    attribute title: String;")
    lines.append("    attribute supplier: String;")
    lines.append("    attribute url: String;")
    lines.append("    attribute status: String;")
    lines.append("    attribute constraintScore: Real;")
    lines.append("    attribute stock: Real;")
    lines.append("    attribute unitPriceUsd: Real;")
    lines.append("  }")

    for idx, concept in enumerate(concepts, 1):
        cid = f"Concept_{idx}"
        opt = opt_by_idx.get(idx, {})
        val = val_by_idx.get(idx, {})
        status = as_sysml_string(opt.get("status", "unknown"))
        validation_status = as_sysml_string(val.get("status", "unknown"))
        slot_rows = slots_by_idx.get(idx, [])
        selected_count = sum(1 for r in slot_rows if str(r.get("status")) == "selected")
        if status != "success":
            part_status = "optimization_failed"
            design_feasible = False
        elif slot_rows and selected_count == 0:
            part_status = "infeasible_no_parts"
            design_feasible = False
        elif slot_rows and selected_count < len(slot_rows):
            part_status = "partial_parts_found"
            design_feasible = True
        elif slot_rows:
            part_status = "all_slots_sourced"
            design_feasible = True
        else:
            part_status = "no_slots_defined"
            design_feasible = False
        if validation_status in {"fail", "error"}:
            design_feasible = False
        lines.append(f"  part {cid} : ConceptInstance {{")
        lines.append(f'    name = "{as_sysml_string(concept.get("name", "Concept"))}";')
        lines.append(f'    approach = "{as_sysml_string(concept.get("approach", ""))}";')
        lines.append(f'    optimizationStatus = "{status}";')
        lines.append(f'    partSelectionStatus = "{part_status}";')
        lines.append(f'    constraintValidationStatus = "{validation_status}";')
        lines.append(f"    designFeasible = {'true' if design_feasible else 'false'};")

        optimized_values = opt.get("optimized_values") or {}
        for attr, value in sorted(optimized_values.items()):
            attr_slug = safe_slug(attr)
            lines.append(f"    part {cid}_opt_{attr_slug} : OptimizedAttribute {{")
            lines.append(f'      attr = "{as_sysml_string(attr)}";')
            lines.append(f"      value = {fmt_num(as_float(value))};")
            lines.append("    }")

        for row in slot_rows:
            slot_slug = safe_slug(str(row.get("slot", "slot")))
            lines.append(f"    part {cid}_{slot_slug} : SlotSelection {{")
            lines.append(f'      slot = "{as_sysml_string(row.get("slot", "slot"))}";')
            lines.append(f'      title = "{as_sysml_string(row.get("title", "unsourced"))}";')
            lines.append(f'      supplier = "{as_sysml_string(row.get("supplier", ""))}";')
            lines.append(f'      url = "{as_sysml_string(row.get("url", ""))}";')
            lines.append(f'      status = "{as_sysml_string(row.get("status", "pending"))}";')
            lines.append(f"      constraintScore = {fmt_num(as_float(row.get('constraint_match_score'), 0.0))};")
            lines.append(f"      stock = {fmt_num(as_float(row.get('stock'), 0.0))};")
            lines.append(f"      unitPriceUsd = {fmt_num(as_float(row.get('unitPrice'), 0.0))};")
            lines.append("    }")
        lines.append("  }")

    lines.append("} end DesignInstancesOptimized;")
    path.write_text("\n".join(lines), encoding="utf-8")


# ---------- main ----------


def resolve_parallel_concept_limit(requested: int, concept_count: int) -> int:
    if concept_count <= 0:
        return 1
    if requested and requested > 0:
        return max(1, min(requested, concept_count))
    env_limit = int(os.environ.get("PIPELINE_MAX_PARALLEL_CONCEPTS", "0") or "0")
    if env_limit > 0:
        return max(1, min(env_limit, concept_count))
    return max(1, concept_count)


def parse_args() -> argparse.Namespace:
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument("--nl", type=str, help="Natural-language brief")
    p.add_argument("--nl-file", type=Path, help="File containing NL brief")
    p.add_argument("--syside-venv", type=Path, default=REPO_ROOT / ".venv", help="Venv with syside installed (default: ./.venv)")
    p.add_argument("--max-iters", type=int, default=25)
    p.add_argument("--max-total-tokens", type=int, default=200000)
    p.add_argument("--concepts", type=int, default=DEFAULT_CONCEPT_COUNT, help="Number of design concepts to generate")
    p.add_argument(
        "--max-parallel-concepts",
        type=int,
        default=0,
        help="Maximum number of concepts to optimize in parallel (0 = auto).",
    )
    p.add_argument("--parts-per-concept", type=int, default=3, help="Maximum number of concept slots to source per concept")
    p.add_argument("--search-limit", type=int, default=5, help="Max results per search in CLI")
    p.add_argument(
        "--providers",
        type=str,
        default=DEFAULT_PROVIDER_ORDER,
        help="Comma list provider order for CLI (default: web,mouser,octopart,digikey)",
    )
    p.add_argument(
        "--configurator-sites",
        type=str,
        default="",
        help="Optional comma-separated domains for configurator Gemini part picker (e.g., mouser.com,digikey.com)",
    )
    p.add_argument(
        "--disable-configurator-picker",
        action="store_true",
        help="Disable sysml-v2-configurator Gemini part picker and use only existing picker pipeline.",
    )
    p.add_argument(
        "--disable-configurator-validator",
        action="store_true",
        help="Disable sysml-v2-configurator ConstraintValidation stage.",
    )
    p.add_argument(
        "--disable-existing-picker-fallback",
        action="store_true",
        help="Disable fallback to existing picker CLI when configurator picker has no results.",
    )
    p.add_argument("--model", type=str, default="gpt-5-mini", help="LLM model for concepts")
    p.add_argument("--temperature", type=float, default=None)
    p.add_argument(
        "--optimizer-decision-mode",
        type=str,
        default=os.environ.get("PIPELINE_DECISION_MODE", "auto"),
        help="Decision mode passed through to optimization/scripts/syspipe.py (auto, agent, human, llm).",
    )
    p.add_argument(
        "--optimizer-decision-model",
        type=str,
        default=os.environ.get("PIPELINE_DECISION_MODEL"),
        help="Optional decision model passed through to optimization/scripts/syspipe.py when using llm mode.",
    )
    return p.parse_args()


def main() -> None:
    load_env_if_present()
    args = parse_args()
    if not (args.nl or args.nl_file):
        raise SystemExit("Provide --nl or --nl-file")
    if not (args.syside_venv / "bin/python").exists():
        raise SystemExit(f"syside venv missing: {args.syside_venv}")

    out_base = SCRIPT_DIR / "runs"
    providers = [p.strip() for p in args.providers.split(",") if p.strip()]
    configurator_sites = [s.strip() for s in args.configurator_sites.split(",") if s.strip()]
    use_configurator_picker = not args.disable_configurator_picker
    use_configurator_validator = not args.disable_configurator_validator
    use_existing_picker_fallback = not args.disable_existing_picker_fallback

    # 1) Scaffold
    scaffold_cmd = [str(SCAFFOLD), "--out", str(out_base)]
    if args.nl:
        scaffold_cmd += ["--nl", args.nl]
    else:
        scaffold_cmd += ["--nl-file", str(args.nl_file)]
    print("Scaffolding...")
    scaffold_stdout = run(scaffold_cmd)

    run_dir = scaffold_run_dir_from_output(scaffold_stdout) or latest_run(out_base)
    prompt_txt = load_prompt(run_dir)
    user_brief = extract_user_brief(prompt_txt)
    sysml_dir = run_dir / "sysml"
    sysml_dir.mkdir(exist_ok=True)

    # 2) Refine SysML
    stage = StageLog(run_dir)
    stage.info("requirements:start")
    print("Running refine_sysml.py ...")
    # Run the refiner under the current pipeline interpreter. It still uses
    # the SysIDE venv for compilation via --venv, but avoids coupling LLM
    # client imports to packages installed inside that venv.
    refine_cmd = [
        sys.executable,
        str(REFINE),
        "--input",
        str(run_dir / "prompt.txt"),
        "--output-dir",
        str(sysml_dir),
        "--venv",
        str(args.syside_venv),
        "--max-iters",
        str(args.max_iters),
        "--max-total-tokens",
        str(args.max_total_tokens),
        "--model",
        str(args.model),
    ]
    try:
        run(refine_cmd)
    except Exception as e:
        stage.info("requirements:failed", error=str(e))
        # fall back to minimal requirements-only SysML
        fallback = sysml_dir / "fallback_requirements.sysml"
        write_min_requirements_sysml(fallback, user_brief)
        stage.info("requirements:fallback_written", path=str(fallback))
    # check success from run_log
    run_log = load_run_log(sysml_dir)
    success = True
    if run_log:
        last = run_log[-1] if isinstance(run_log, list) else run_log
        success = bool(last.get("success", False)) if isinstance(last, dict) else True
    if not success:
        fallback = sysml_dir / "fallback_requirements.sysml"
        write_min_requirements_sysml(fallback, user_brief)
        stage.info("requirements:fallback_written", path=str(fallback))
    stage.info("requirements:done")
    latest_sysml = find_latest_sysml(sysml_dir)
    print(f"Latest SysML: {latest_sysml.name}")

    # Save deliverable copy
    deliver_dir = run_dir / "deliverables"
    deliver_dir.mkdir(exist_ok=True)
    deliver_sysml = deliver_dir / "final.sysml"
    deliver_sysml.write_bytes(latest_sysml.read_bytes())

    # 3) Concepts via LLM
    stage.info("concepts:start")
    print("Generating concepts...")
    target_concepts = max(1, int(args.concepts))
    concepts = gen_concepts(user_brief, latest_sysml, target_concepts, args.model, args.temperature)[:target_concepts]
    concepts_path = run_dir / "concepts" / "auto_concepts.json"
    concepts_path.parent.mkdir(parents=True, exist_ok=True)
    concepts_path.write_text(json.dumps(concepts, indent=2), encoding="utf-8")
    stage.info("concepts:done", count=len(concepts))

    if len(concepts) != target_concepts:
        raise RuntimeError(f"Expected {target_concepts} concepts, got {len(concepts)}")

    requirements_text = latest_sysml.read_text(encoding="utf-8")
    targets = parse_targets(user_brief, requirements_text)

    # 4) Optimization per concept
    stage.info("optimize:start")
    parallel_concepts = resolve_parallel_concept_limit(args.max_parallel_concepts, len(concepts))
    print(f"Running optimization for {len(concepts)} concepts with parallelism={parallel_concepts}...")
    ensure_optimizer_dependencies(sys.executable)
    optimization_results = run_concept_optimizations(
        concepts=concepts,
        targets=targets,
        run_dir=run_dir,
        model=args.model,
        decision_mode=args.optimizer_decision_mode,
        decision_model=args.optimizer_decision_model,
        max_parallel=parallel_concepts,
    )
    optimize_success = sum(1 for r in optimization_results if r.get("status") == "success")
    stage.info("optimize:done", total=len(optimization_results), success=optimize_success, failed=len(optimization_results) - optimize_success)

    # 5) Part selection driven by optimized attributes
    stage.info("parts:start")
    stage.info("part_select:start")
    print("Selecting parts from optimized attributes...")
    parts_dir = run_dir / "parts"
    parts_dir.mkdir(exist_ok=True)
    part_timeout = int(os.environ.get("PART_SEARCH_TIMEOUT_SEC", "180"))

    opt_by_idx = {int(r["concept_index"]): r for r in optimization_results if "concept_index" in r}
    optimized_bom_rows: List[Dict[str, Any]] = []
    total_searches = 0
    total_selected = 0

    for ci, concept in enumerate(concepts, 1):
        opt = opt_by_idx.get(ci, {})
        optimized_values = opt.get("optimized_values") or {}
        slots = concept.get("slots") or [{"slot": "primary", "search_queries": concept.get("search_queries", [])}]
        if args.parts_per_concept > 0:
            slots = list(slots)[: args.parts_per_concept]
        for slot in slots:
            slot_name = str(slot.get("slot") or slot.get("name") or "slot")
            slot_slug = safe_slug(slot_name)
            logfile = parts_dir / f"auto_c{ci}_s{slot_slug}_q1.log"

            if opt.get("status") != "success":
                search_input = {"slot": slot_slug, "keywords": [slot_name, str(concept.get("name", f"Concept {ci}"))]}
                search_result: Dict[str, Any] = {
                    "status": "skipped",
                    "count": 0,
                    "results": [],
                    "error": "optimization_failed",
                }
                picked = {
                    "status": "not_found",
                    "reason": "optimization_failed",
                    "constraint_match_score": 0,
                    "stock": None,
                    "unitPrice": None,
                    "supplier": None,
                    "manufacturer": None,
                    "manufacturerPartNumber": None,
                    "description": None,
                    "url": None,
                    "provider": None,
                    "attributes": {},
                }
                search_input_used = dict(search_input)
                search_attempts: List[Dict[str, Any]] = []
            else:
                search_input = build_slot_search_input(concept, slot, optimized_values, targets, user_brief)
                search_attempts = []
                search_input_used = dict(search_input)

                configurator_result: Dict[str, Any] = {
                    "status": "error",
                    "count": 0,
                    "results": [],
                    "error": "configurator_picker_disabled",
                }
                if use_configurator_picker:
                    configurator_bundle = run_configurator_part_picker_with_relaxation(
                        search_input=search_input,
                        slot_name=slot_name,
                        requirements_sysml=latest_sysml,
                        timeout_sec=part_timeout,
                        sites=configurator_sites,
                    )
                    configurator_result = configurator_bundle["search_result"]
                    search_input_used = configurator_bundle["used_input"]
                    for attempt in configurator_bundle["attempts"]:
                        search_attempts.append({"source": "configurator_chatgpt", **attempt})

                if _search_count(configurator_result) > 0:
                    search_result = configurator_result
                else:
                    if use_existing_picker_fallback:
                        search_bundle = run_structured_part_search_with_relaxation(
                            search_input,
                            args.search_limit,
                            providers,
                            part_timeout,
                        )
                        search_result = search_bundle["search_result"]
                        search_input_used = search_bundle["used_input"]
                        for attempt in search_bundle["attempts"]:
                            search_attempts.append({"source": "existing_picker_cli", **attempt})
                    else:
                        search_result = {
                            "status": "not_found",
                            "count": 0,
                            "results": [],
                            "error": "configurator_no_results_no_fallback",
                        }
                picked = pick_best_part(search_result, search_input)
                total_searches += 1
                if picked.get("status") == "selected":
                    total_selected += 1

            write_search_log(logfile, search_input, search_input_used, search_result, picked, search_attempts)

            title = "not found"
            if picked.get("status") == "selected":
                part_num = picked.get("manufacturerPartNumber") or "unknown"
                mfr = picked.get("manufacturer") or "unknown"
                title = f"{part_num} ({mfr})"
            elif picked.get("reason"):
                title = str(picked["reason"])

            optimized_bom_rows.append(
                {
                    "concept_index": ci,
                    "concept": concept.get("name", f"Concept {ci}"),
                    "slot": slot_name,
                    "slot_slug": slot_slug,
                    "title": title,
                    "status": picked.get("status", "not_found"),
                    "reason": picked.get("reason"),
                    "url": picked.get("url"),
                    "stock": picked.get("stock"),
                    "unitPrice": picked.get("unitPrice"),
                    "supplier": picked.get("supplier"),
                    "provider": picked.get("provider"),
                    "constraint_match_score": picked.get("constraint_match_score", 0),
                    "query_input": search_input,
                    "query_input_used": search_input_used,
                    "search_attempts": search_attempts,
                }
            )

    stage.info(
        "part_select:done",
        searches=total_searches,
        selected=total_selected,
        not_found=len(optimized_bom_rows) - total_selected,
    )
    stage.info("parts:done", searches=total_searches, selected=total_selected)

    # 5b) Constraint validation (sysml-v2-configurator/ConstraintValidation.py)
    constraint_validation_results: List[Dict[str, Any]] = []
    validation_root = run_dir / "validation"
    validation_root.mkdir(exist_ok=True)
    stage.info("constraint_validate:start")
    for ci, concept in enumerate(concepts, 1):
        opt = opt_by_idx.get(ci, {})
        rows = [r for r in optimized_bom_rows if int(r.get("concept_index", 0)) == ci]
        selected_slots = sum(1 for r in rows if r.get("status") == "selected")
        total_slots = len(rows)
        concept_validation_dir = validation_root / f"concept_{ci}"
        concept_validation_dir.mkdir(parents=True, exist_ok=True)
        validation_model_path = concept_validation_dir / "validation_model.sysml"
        validation_output_path = concept_validation_dir / "constraint_validation.json"

        if not use_configurator_validator:
            result = {
                "concept_index": ci,
                "status": "skipped",
                "reason": "configurator_validator_disabled",
                "validation_model_path": str(validation_model_path),
                "validation_output_path": str(validation_output_path),
            }
            validation_output_path.write_text(json.dumps(result, indent=2), encoding="utf-8")
            constraint_validation_results.append(result)
            continue

        if opt.get("status") != "success":
            result = {
                "concept_index": ci,
                "status": "skipped",
                "reason": "optimization_failed",
                "validation_model_path": str(validation_model_path),
                "validation_output_path": str(validation_output_path),
            }
            validation_output_path.write_text(json.dumps(result, indent=2), encoding="utf-8")
            constraint_validation_results.append(result)
            continue

        validation_model = build_constraint_validation_sysml(
            concept=concept,
            concept_idx=ci,
            optimized_values=opt.get("optimized_values") or {},
            targets=targets,
            selected_slots=selected_slots,
            total_slots=total_slots,
        )
        validation_model_path.write_text(validation_model, encoding="utf-8")
        result = run_configurator_constraint_validation(
            validation_sysml_path=validation_model_path,
            output_path=validation_output_path,
            timeout_sec=int(os.environ.get("CONSTRAINT_VALIDATION_TIMEOUT_SEC", "20")),
        )
        constraint_validation_results.append(
            {
                "concept_index": ci,
                "status": result.get("status", "error"),
                "evaluated": result.get("evaluated", 0),
                "passed": result.get("passed", 0),
                "failed": result.get("failed", 0),
                "reason": result.get("error"),
                "validation_model_path": str(validation_model_path),
                "validation_output_path": str(validation_output_path),
            }
        )
    validation_pass = sum(1 for r in constraint_validation_results if r.get("status") == "pass")
    validation_fail = sum(1 for r in constraint_validation_results if r.get("status") in {"fail", "error"})
    stage.info(
        "constraint_validate:done",
        total=len(constraint_validation_results),
        passed=validation_pass,
        failed=validation_fail,
    )

    # 6) Emit legacy + optimized deliverables
    bom_summary: Dict[str, List[Dict[str, str]]] = {}
    for row in optimized_bom_rows:
        ci = int(row.get("concept_index", 0))
        slot_slug = str(row.get("slot_slug", "slot"))
        entry = {
            "title": str(row.get("title", "item")),
            "url": str(row.get("url", "") or ""),
            "supplier": str(row.get("supplier", "") or ""),
            "status": str(row.get("status", "pending")),
            "stock": str(row.get("stock", "") or ""),
        }
        keys = {
            f"{ci}",
            f"c{ci}",
            f"auto_c{ci}",
            f"{ci}:{slot_slug}",
            f"c{ci}:{slot_slug}",
            f"auto_c{ci}:{slot_slug}",
        }
        for key in keys:
            bom_summary.setdefault(key, []).append(entry)

    bom_rows = bom_rows_from_summary(bom_summary)
    design_instances_sysml = run_dir / "deliverables" / "design_instances.sysml"
    design_instances_sysml.parent.mkdir(exist_ok=True)
    write_design_instances_sysml(design_instances_sysml, concepts, bom_summary)
    bom_json_path = run_dir / "deliverables" / "bom.json"
    bom_json_path.write_text(json.dumps(bom_rows, indent=2), encoding="utf-8")

    design_instances_opt_path = run_dir / "deliverables" / "design_instances_optimized.sysml"
    write_optimized_design_instances_sysml(
        design_instances_opt_path,
        concepts,
        optimization_results,
        optimized_bom_rows,
        constraint_validation_results=constraint_validation_results,
    )
    bom_optimized_path = run_dir / "deliverables" / "bom_optimized.json"
    bom_optimized_path.write_text(json.dumps(optimized_bom_rows, indent=2), encoding="utf-8")
    constraint_validation_path = run_dir / "deliverables" / "constraint_validation.json"
    constraint_validation_path.write_text(json.dumps(constraint_validation_results, indent=2), encoding="utf-8")

    val_by_idx = {int(r["concept_index"]): r for r in constraint_validation_results if "concept_index" in r}
    concept_status = []
    for ci, concept in enumerate(concepts, 1):
        opt = opt_by_idx.get(ci, {})
        val = val_by_idx.get(ci, {})
        rows = [r for r in optimized_bom_rows if int(r.get("concept_index", 0)) == ci]
        parts_selected = sum(1 for r in rows if r.get("status") == "selected")
        if opt.get("status") != "success":
            part_selection_status = "optimization_failed"
            design_feasible = False
        elif rows and parts_selected == 0:
            part_selection_status = "infeasible_no_parts"
            design_feasible = False
        elif rows and parts_selected < len(rows):
            part_selection_status = "partial_parts_found"
            design_feasible = True
        elif rows:
            part_selection_status = "all_slots_sourced"
            design_feasible = True
        else:
            part_selection_status = "no_slots_defined"
            design_feasible = False
        constraint_validation_status = str(val.get("status", "unknown"))
        if constraint_validation_status in {"fail", "error"}:
            design_feasible = False
        concept_status.append(
            {
                "concept_index": ci,
                "concept": concept.get("name", f"Concept {ci}"),
                "optimization_status": opt.get("status", "missing"),
                "parts_selected": parts_selected,
                "slots_total": len(rows),
                "part_selection_status": part_selection_status,
                "constraint_validation_status": constraint_validation_status,
                "design_feasible": design_feasible,
                "model_path": relpath_or_self(opt.get("model_path", run_dir / "optimization" / f"concept_{ci}" / "model.sysml"), run_dir),
                "best_solution_path": relpath_or_self(opt.get("best_solution_path", run_dir / "optimization" / f"concept_{ci}" / "best_solution.json"), run_dir),
                "constraint_validation_model_path": relpath_or_self(
                    val.get("validation_model_path", run_dir / "validation" / f"concept_{ci}" / "validation_model.sysml"),
                    run_dir,
                ),
                "constraint_validation_output_path": relpath_or_self(
                    val.get("validation_output_path", run_dir / "validation" / f"concept_{ci}" / "constraint_validation.json"),
                    run_dir,
                ),
                "error": opt.get("error"),
            }
        )

    summary = {
        "prompt": prompt_txt,
        "user_brief": user_brief,
        "sysml": latest_sysml.name,
        "concepts_file": str(concepts_path.relative_to(run_dir)),
        "parts_logs": [p.name for p in sorted(parts_dir.glob("auto_c*.log"))],
        "design_instances": str(design_instances_sysml.relative_to(run_dir)),
        "bom_rows": str(bom_json_path.relative_to(run_dir)),
        "optimized_design_instances": str(design_instances_opt_path.relative_to(run_dir)),
        "optimized_bom": str(bom_optimized_path.relative_to(run_dir)),
        "constraint_validation": str(constraint_validation_path.relative_to(run_dir)),
        "optimization_targets": targets,
        "concept_count": len(concepts),
        "optimizer_decision_mode": args.optimizer_decision_mode,
        "optimizer_decision_model": args.optimizer_decision_model,
        "max_parallel_concepts": parallel_concepts,
        "part_picker": {
            "configurator_chatgpt_enabled": use_configurator_picker,
            "configurator_gemini_enabled": use_configurator_picker,
            "configurator_sites": configurator_sites,
            "existing_picker_fallback_enabled": use_existing_picker_fallback,
            "fallback_picker_providers": providers,
        },
        "constraint_validator": {
            "configurator_enabled": use_configurator_validator,
        },
        "concept_status": concept_status,
        "infeasible_concepts": [c["concept_index"] for c in concept_status if c.get("part_selection_status") == "infeasible_no_parts"],
    }
    (run_dir / "summary_auto.json").write_text(json.dumps(summary, indent=2), encoding="utf-8")

    # Acceptance checks
    required_artifacts = [
        design_instances_sysml,
        bom_json_path,
        design_instances_opt_path,
        bom_optimized_path,
        constraint_validation_path,
    ] + [run_dir / "optimization" / f"concept_{i}" / "model.sysml" for i in range(1, len(concepts) + 1)] + [
        run_dir / "optimization" / f"concept_{i}" / "best_solution.json" for i in range(1, len(concepts) + 1)
    ] + [
        run_dir / "validation" / f"concept_{i}" / "constraint_validation.json" for i in range(1, len(concepts) + 1)
    ]
    missing = [str(p) for p in required_artifacts if not p.exists()]
    if missing:
        raise RuntimeError(f"Missing expected artifacts: {missing}")

    stage.info("run:complete")
    print(f"Done. Run directory: {run_dir}")


if __name__ == "__main__":
    main()
