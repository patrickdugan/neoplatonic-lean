"""Reproduce MRE-1 engineering checks with Lean 4.24.0 and Python 3.10+."""
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
OUT = ROOT / 'verification' / 'mre'
ALLOWED = {'propext', 'Classical.choice', 'Quot.sound'}
UPSTREAM_BLOB = 'ca001494f5b12891c305023498b7e819613a691d'


def strip_comments(text: str) -> str:
    output, pos, depth = [], 0, 0
    while pos < len(text):
        if text.startswith('/-', pos):
            depth += 1
            pos += 2
        elif depth and text.startswith('-/', pos):
            depth -= 1
            pos += 2
        elif depth:
            output.append('\n' if text[pos] == '\n' else ' ')
            pos += 1
        elif text.startswith('--', pos):
            end = text.find('\n', pos)
            pos = len(text) if end < 0 else end
        else:
            output.append(text[pos])
            pos += 1
    if depth:
        raise ValueError('unclosed Lean comment')
    return ''.join(output)


def run(args: list[str], log_name: str, cwd: Path = ROOT, env=None) -> str:
    result = subprocess.run(args, cwd=cwd, env=env, text=True,
                            stdout=subprocess.PIPE, stderr=subprocess.STDOUT,
                            timeout=180, check=False)
    (OUT / log_name).write_text(result.stdout, encoding='utf-8')
    print(result.stdout, end='', flush=True)
    if result.returncode:
        raise RuntimeError(f'{log_name}: exit {result.returncode}')
    return result.stdout


def main() -> None:
    OUT.mkdir(parents=True, exist_ok=True)
    (OUT / 'summary.json').unlink(missing_ok=True)
    lean = shutil.which('lean')
    if lean is None:
        raise RuntimeError('Install the pinned Lean 4.24.0 toolchain and put lean on PATH')
    version = run([lean, '--version'], 'lean-version.log')
    if not re.search(r'version 4\.24\.0[,)]', version):
        raise RuntimeError('unexpected Lean toolchain')
    raw = (ROOT / 'Unveiling.lean').read_bytes()
    git_blob = hashlib.sha1(f'blob {len(raw)}\0'.encode() + raw).hexdigest()
    if git_blob != UPSTREAM_BLOB:
        raise RuntimeError('upstream Unveiling source differs from the reviewed pinned blob')
    source = (HERE / 'MRE.lean').read_text(encoding='utf-8')
    code = strip_comments(source)
    forbidden = re.findall(r'\b(?:sorry|admit|axiom|unsafe|native_decide|implemented_by)\b', code)
    if forbidden:
        raise RuntimeError(f'proof escape: {forbidden}')
    names = ['MoralEpistemics.' + n for n in re.findall(r'^theorem\s+(\w+)', code, re.M)]
    if not names:
        raise RuntimeError('empty theorem inventory')
    compiled = OUT / 'compiled'
    compiled.mkdir(exist_ok=True)
    run([lean, '-DwarningAsError=true', '-o', str(compiled / 'Unveiling.olean'),
         'Unveiling.lean'], 'upstream-build.log')
    env = dict(os.environ)
    env['LEAN_PATH'] = str(compiled)
    run([lean, '-DwarningAsError=true', '-o', str(compiled / 'MRE.olean'),
         'MRE.lean'], 'mre-build.log', HERE, env)
    report = 'import MRE\n\n' + '\n'.join('#check ' + n + '\n#print axioms ' + n for n in names) + '\n'
    (compiled / 'AxiomReport.lean').write_text(report, encoding='utf-8')
    (OUT / 'AxiomReport.lean').write_text(report, encoding='utf-8')
    printed = run([lean, 'AxiomReport.lean'], 'axioms.log', compiled, env)
    axioms = {}
    for name in names:
        quoted = re.escape("'" + name + "'")
        found = re.search(quoted + r' depends on axioms:\s*\[([^\]]*)\]', printed)
        if found:
            dependencies = {x.strip() for x in found.group(1).split(',') if x.strip()}
        elif re.search(quoted + r' does not depend on any axioms', printed):
            dependencies = set()
        else:
            raise RuntimeError('missing axiom inventory: ' + name)
        if dependencies - ALLOWED:
            raise RuntimeError('unexpected kernel axioms: ' + repr(dependencies - ALLOWED))
        axioms[name] = sorted(dependencies)
    tests = run([sys.executable, '-m', 'unittest', '-v', 'test_mre'], 'python-tests.log', HERE)
    count = re.search(r'Ran (\d+) tests?', tests)
    if not count:
        raise RuntimeError('missing unittest count')
    run([sys.executable, str(HERE / 'mre.py'), 'demo', '--out', str(OUT)], 'scripted-checks.log')
    files = [p for p in HERE.iterdir() if p.is_file()]
    files += [ROOT / 'Unveiling.lean', ROOT / 'lean-toolchain', ROOT / '.github' / 'workflows' / 'mre.yml']
    summary = {
        'status': 'engineering_checks_passed',
        'lean_version': version.strip(),
        'git_sha': os.environ.get('GITHUB_SHA'),
        'upstream_git_blob': git_blob,
        'lean_theorem_count': len(names),
        'python_test_count': int(count.group(1)),
        'model_calls': 0,
        'training_steps': 0,
        'empirical_alignment_claim': False,
        'axioms': axioms,
        'source_sha256': {str(p.relative_to(ROOT)): hashlib.sha256(p.read_bytes()).hexdigest() for p in files},
    }
    (OUT / 'summary.json').write_text(json.dumps(summary, indent=2) + '\n', encoding='utf-8')
    print(f"PASS: {len(names)} Lean theorems, {count.group(1)} Python tests; model calls 0, training steps 0.")


if __name__ == '__main__':
    main()
