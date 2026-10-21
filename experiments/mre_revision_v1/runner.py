"""Run the dynamic instrument through a user-supplied JSON subprocess agent.

The command is an explicitly trusted local program, not sandboxed by this
runner. It reads one JSON request from stdin and emits one command JSON object.
This runner itself has no network/model client. A supplied agent may incur
costs; its owner must configure and approve that backend separately.
"""
from __future__ import annotations

import argparse
import hashlib
import json
import math
from pathlib import Path
import subprocess
import time
from typing import Any

from revision import Episode, generate, summarize, treatment, digest, write_jsonl, HERE


def strict_json(text: str) -> Any:
    def pairs(items):
        obj = {}
        for k, v in items:
            if k in obj:
                raise ValueError("duplicate JSON field")
            obj[k] = v
        return obj
    def invalid_constant(value):
        raise ValueError("nonfinite JSON number: " + value)
    return json.loads(text, object_pairs_hook=pairs, parse_constant=invalid_constant)


def payload(ep: Episode, arm: str, frame: str) -> dict[str, Any]:
    observation = ep.view()
    # Transport identifiers encode the evaluator's case allocation; never send them.
    observation.pop("episode_id")
    text, _ = treatment(arm, frame)
    return {"system": text, "observation": observation}


def run_agent(argv: list[str], out: Path, model_id: str, arm: str, frame: str,
              per_family: int = 1, enforcement: str = "full", max_calls: int = 384,
              timeout: float = 60.0, kind: str = "model") -> dict[str, Any]:
    if not argv or any(not isinstance(x, str) or not x for x in argv):
        raise ValueError("agent command must be a nonempty argv list")
    if not model_id or kind not in {"model", "scripted"}:
        raise ValueError("model identity and valid run kind are required")
    if type(max_calls) is not int or max_calls < 1 or not math.isfinite(timeout) or timeout <= 0:
        raise ValueError("invalid call budget or timeout")
    cases = generate(per_family)
    text, card_hash = treatment(arm, frame)
    out.mkdir(parents=True, exist_ok=False)
    manifest = {"protocol": "mre_revision_v1.1", "kind": kind, "declared_model_id": model_id,
                "backend_identity_independently_verified": False,
                "arm": arm, "frame": frame, "enforcement": enforcement,
                "max_calls": max_calls, "timeout_seconds": timeout,
                "episodes": len(cases), "scenario_sha256": digest([c.__dict__ for c in cases]),
                "card_sha256": card_hash,
                "source_sha256": {p.name: hashlib.sha256(p.read_bytes()).hexdigest()
                                   for p in HERE.iterdir() if p.is_file() and p.suffix in {".py", ".json"}},
                "sealed": False, "tokenizer_length_matched": False}
    (out / "manifest.json").write_text(json.dumps(manifest, indent=2) + "\n", encoding="utf-8")
    rows, calls = [], 0
    with (out / "transcript.jsonl").open("w", encoding="utf-8") as log:
        for case in cases:
            ep = Episode(case, enforcement)
            while not ep.done:
                if calls >= max_calls:
                    ep.fail("global_call_budget_exhausted")
                    break
                request = payload(ep, arm, frame)
                calls += 1
                entry = {"episode_id": case.episode_id, "request": request,
                         "request_sha256": digest(request), "call": calls}
                start = time.monotonic()
                try:
                    completed = subprocess.run(argv, input=json.dumps(request), text=True,
                                               capture_output=True, timeout=timeout, check=False)
                    if completed.returncode:
                        ep.fail("agent_process_error")
                        entry["stderr_excerpt"] = completed.stderr[:2000]
                    elif len(completed.stdout) > 4096:
                        ep.fail("oversized_response")
                    else:
                        entry["raw_response"] = completed.stdout
                        try:
                            response = strict_json(completed.stdout)
                        except (ValueError, json.JSONDecodeError):
                            ep.fail("invalid_json")
                        else:
                            ep.step(response)
                except subprocess.TimeoutExpired:
                    ep.fail("agent_timeout")
                except OSError as exc:
                    ep.fail("agent_launch_error")
                    entry["error"] = type(exc).__name__
                entry["seconds"] = time.monotonic() - start
                log.write(json.dumps(entry, sort_keys=True, allow_nan=False) + "\n")
                log.flush()
            rows.append(ep.result())
    summary = summarize(rows, {c.episode_id for c in cases})
    missing = sum(r["error"] is not None for r in rows)
    worst = sum(r["attempted_violation"] or r["error"] is not None for r in rows)
    summary.update({"agent_calls": calls, "model_calls": calls if kind == "model" else 0,
                    "training_steps": 0, "unknown_or_error_episodes": missing,
                    "attempted_violation_upper_bound_treating_errors_as_failures": worst / len(rows),
                    "empirical_claim_scope": "open_development_only", "kind": kind})
    write_jsonl(out / "results.jsonl", rows)
    (out / "summary.json").write_text(json.dumps(summary, indent=2) + "\n", encoding="utf-8")
    return summary


if __name__ == "__main__":
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument("--agent-json", required=True, help='JSON argv list; shell execution is disabled')
    p.add_argument("--model-id", required=True, help='backend/checkpoint identity for the manifest')
    p.add_argument("--out", type=Path, required=True, help='new output directory')
    p.add_argument("--arm", choices=("C00", "C10", "C01", "C11"), required=True)
    p.add_argument("--frame", choices=("present", "removed"), default="present")
    p.add_argument("--per-family", type=int, default=1)
    p.add_argument("--gate", choices=("full", "permissions_only"), default="full")
    p.add_argument("--max-calls", type=int, required=True)
    p.add_argument("--timeout", type=float, default=60.0)
    p.add_argument("--kind", choices=("model", "scripted"), default="model")
    a = p.parse_args()
    args = strict_json(a.agent_json)
    if not isinstance(args, list):
        p.error('--agent-json must be a JSON list')
    print(json.dumps(run_agent(args, a.out, a.model_id, a.arm, a.frame,
                              a.per_family, a.gate, a.max_calls, a.timeout, a.kind), indent=2))
