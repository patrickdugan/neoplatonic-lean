"""Rebuild the MRE parent, check new proofs, test the dynamic instrument.

Runs only Lean and standard-library Python, including a scripted subprocess
agent. No learned-model inference or training is initiated.
"""
from __future__ import annotations

import hashlib
import json
import os
from pathlib import Path
import re
import shutil
import subprocess
import sys

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[1]
OUT = ROOT / "verification" / "mre_revision"
sys.path.insert(0, str(HERE.parent / "mre_v1"))
from verify import strip_comments

ALLOWED = {"propext", "Classical.choice", "Quot.sound"}
PARENT_BLOBS = {"MRE.lean": "c9279070e2249cc45696ca21767c0525ab8b1cda",
                "mre.py": "0cceeaa6857bd291e108437534bb5077f2ce3769"}


def run(args, name, cwd=ROOT, env=None):
    proc = subprocess.run(args, cwd=cwd, env=env, text=True, stdout=subprocess.PIPE,
                          stderr=subprocess.STDOUT, timeout=240, check=False)
    (OUT / name).write_text(proc.stdout, encoding="utf-8")
    print(f"{name}: exit {proc.returncode}", flush=True)
    if proc.returncode:
        print(proc.stdout)
        raise RuntimeError(f"{name} failed")
    return proc.stdout


def main():
    OUT.mkdir(parents=True, exist_ok=True)
    (OUT / "summary.json").unlink(missing_ok=True)
    lean = shutil.which("lean")
    if lean is None:
        raise RuntimeError("Install lean-toolchain and put lean on PATH")
    version = run([lean, "--version"], "lean-version.log")
    if not re.search(r"version 4\.24\.0[,)]", version):
        raise RuntimeError("unexpected Lean toolchain")
    for name, expected in PARENT_BLOBS.items():
        data = (HERE.parent / "mre_v1" / name).read_bytes()
        actual = hashlib.sha1(f"blob {len(data)}\0".encode() + data).hexdigest()
        if actual != expected:
            raise RuntimeError(f"parent {name} differs from reviewed blob")
    run([sys.executable, str(HERE.parent / "mre_v1" / "verify.py")], "parent-verification.log")
    compiled = OUT / "compiled"
    compiled.mkdir(exist_ok=True)
    env = dict(os.environ)
    env["LEAN_PATH"] = os.pathsep.join([str(compiled), str(ROOT / "verification" / "mre" / "compiled")])
    names = []
    for module in ("Revision", "Observability"):
        source = (HERE / f"{module}.lean").read_text(encoding="utf-8")
        code = strip_comments(source)
        if re.search(r"\b(?:sorry|admit|axiom|unsafe|native_decide|implemented_by)\b", code):
            raise RuntimeError("forbidden proof escape")
        names += ["MoralRevision." + n for n in re.findall(r"^theorem\s+(\w+)", code, re.M)]
        run([lean, "-DwarningAsError=true", "-o", str(compiled / f"{module}.olean"),
             f"{module}.lean"], f"{module}-build.log", HERE, env)
    if not names or len(names) != len(set(names)):
        raise RuntimeError("invalid theorem inventory")
    report = "import Observability\n\n" + "\n".join("#check " + n + "\n#print axioms " + n for n in names)
    report += "\n#print MoralRevision.Supported\n#print MoralRevision.Valid\n#print MoralRevision.Accepts\n"
    (compiled / "AxiomReport.lean").write_text(report, encoding="utf-8")
    (OUT / "AxiomReport.lean").write_text(report, encoding="utf-8")
    printed = run([lean, "AxiomReport.lean"], "axioms.log", compiled, env)
    dependencies = {}
    for name in names:
        quoted = re.escape("'" + name + "'")
        m = re.search(quoted + r" depends on axioms:\s*\[([^\]]*)\]", printed)
        if m:
            found = {s.strip() for s in m.group(1).split(",") if s.strip()}
        elif re.search(quoted + " does not depend on any axioms", printed):
            found = set()
        else:
            raise RuntimeError("missing axiom report: " + name)
        if found - ALLOWED:
            raise RuntimeError("unapproved kernel axioms")
        dependencies[name] = sorted(found)
    tests = run([sys.executable, "-m", "unittest", "-v", "test_revision"], "python-tests.log", HERE)
    count = re.search(r"Ran (\d+) tests?", tests)
    if not count:
        raise RuntimeError("missing test count")
    run([sys.executable, str(HERE / "revision.py"), "demo", "--out", str(OUT)], "scripted-checks.log")
    checks = json.loads((OUT / "scripted_checks.json").read_text())
    for gate in ("full", "permissions_only"):
        reference = checks["conditions"][gate]["reference"]
        if reference["rates"]["decision_correct"] != 1 or reference["rates"]["attempted_violation"] != 0:
            raise RuntimeError("scripted reference failed")
    files = [p for p in HERE.iterdir() if p.is_file()]
    files += [ROOT / "Unveiling.lean", ROOT / "lean-toolchain", ROOT / ".github/workflows/mre_revision.yml"]
    parent = json.loads((ROOT / "verification/mre/summary.json").read_text())
    summary = {"status": "engineering_checks_passed", "git_sha": os.environ.get("GITHUB_SHA"),
               "lean_version": version.strip(), "new_theorems": len(names),
               "new_python_tests": int(count.group(1)),
               "parent_theorems": parent["lean_theorem_count"],
               "parent_python_tests": parent["python_test_count"],
               "independent_dag_retraction_cases": 5120,
               "scripted_episodes": checks["scripted_episodes_total"],
               "model_calls": 0, "training_steps": 0, "empirical_alignment_claim": False,
               "axioms": dependencies,
               "source_sha256": {str(p.relative_to(ROOT)): hashlib.sha256(p.read_bytes()).hexdigest() for p in files}}
    (OUT / "summary.json").write_text(json.dumps(summary, indent=2) + "\n", encoding="utf-8")
    print(json.dumps({k: v for k, v in summary.items() if k not in {"axioms", "source_sha256"}}, indent=2))
    for gate, policies in checks["conditions"].items():
        for policy, result in policies.items():
            print(json.dumps({"gate": gate, "policy": policy,
                              "attempted_violation": result["rates"]["attempted_violation"],
                              "executed_harm": result["rates"]["executed_harm"],
                              "benign_completion": result["benign_completion"],
                              "accuracy": result["rates"]["decision_correct"],
                              "errors": result["errors"]}))


if __name__ == "__main__":
    main()
