"""Kernel-check Unveiling.lean and audit every named theorem.

Run with Python 3.10+ and the repository's pinned Lean on PATH.
This gate uses only Lean's bundled library; Mathlib is not required.
"""
from pathlib import Path
import hashlib
import json
import os
import re
import shutil
import subprocess

ROOT = Path(__file__).resolve().parent
OUT = ROOT / 'verification' / 'unveiling'
ALLOWED = {'propext', 'Classical.choice', 'Quot.sound'}


def strip_comments(text):
    out, i, depth = [], 0, 0
    while i < len(text):
        if text.startswith('/-', i):
            depth += 1
            i += 2
        elif depth and text.startswith('-/', i):
            depth -= 1
            i += 2
        elif depth:
            out.append('\n' if text[i] == '\n' else ' ')
            i += 1
        elif text.startswith('--', i):
            end = text.find('\n', i)
            i = len(text) if end < 0 else end
        else:
            out.append(text[i])
            i += 1
    if depth:
        raise RuntimeError('Unclosed Lean block comment')
    return ''.join(out)


def run(args, log, env=None):
    proc = subprocess.run(args, cwd=ROOT, env=env, text=True,
                          encoding='utf-8', errors='replace',
                          stdout=subprocess.PIPE, stderr=subprocess.STDOUT)
    (OUT / log).write_text(proc.stdout, encoding='utf-8')
    print(proc.stdout, end='', flush=True)
    if proc.returncode:
        raise RuntimeError(f'Command failed ({proc.returncode}): {args}')
    return proc.stdout


def main():
    OUT.mkdir(parents=True, exist_ok=True)
    (OUT / 'summary.json').unlink(missing_ok=True)
    lean = shutil.which('lean')
    if lean is None:
        raise RuntimeError('Lean is missing. Install the pinned lean-toolchain.')
    version = run([lean, '--version'], 'version.log').strip()
    if not re.search(r'version 4\.24\.0[,)]', version):
        raise RuntimeError(f'Unexpected Lean version: {version}')
    source = ROOT / 'Unveiling.lean'
    code = strip_comments(source.read_text(encoding='utf-8'))
    forbidden = re.findall(r'\b(?:sorry|admit|axiom|unsafe|native_decide|implemented_by)\b', code)
    if forbidden:
        raise RuntimeError(f'Forbidden proof escapes: {forbidden}')
    names = ['Unveiling.' + n for n in re.findall(r'^theorem\s+(\w+)', code, re.M)]
    if not names or len(names) != len(set(names)):
        raise RuntimeError('Empty or duplicate theorem inventory')
    if re.findall(r'^import\s+(.+)', code, re.M) != ['Lean']:
        raise RuntimeError('Unexpected import: update the dependency audit deliberately')
    compiled = OUT / 'compiled'
    compiled.mkdir(exist_ok=True)
    run([lean, '-DwarningAsError=true', '-o', str(compiled / 'Unveiling.olean'),
         str(source)], 'build.log')
    report = 'import Unveiling\n\n' + '\n'.join(
        '#check ' + n + '\n#print axioms ' + n for n in names) + '\n'
    report += '\n#print Unveiling.ProvabilityPresentation\n'
    report += '#print Unveiling.ReflectionInterface\n'
    report += '#print Unveiling.MarkedProgression\n'
    report_path = OUT / 'AxiomReport.lean'
    report_path.write_text(report, encoding='utf-8')
    env = dict(os.environ)
    env['LEAN_PATH'] = str(compiled) + (os.pathsep + env['LEAN_PATH'] if env.get('LEAN_PATH') else '')
    output = run([lean, str(report_path)], 'axioms.log', env)
    dependencies = {}
    for name in names:
        pat = re.escape("'" + name + "'")
        match = re.search(pat + r' depends on axioms:\s*\[([^\]]*)\]', output)
        if match:
            found = {p.strip() for p in match.group(1).split(',') if p.strip()}
        elif re.search(pat + r' does not depend on any axioms', output):
            found = set()
        else:
            raise RuntimeError(f'Missing axiom report for {name}')
        if found - ALLOWED:
            raise RuntimeError(f'Unexpected axioms for {name}: {found - ALLOWED}')
        dependencies[name] = sorted(found)
    hashes = {p.name: hashlib.sha256(p.read_bytes()).hexdigest()
              for p in [source, ROOT / 'verify_unveiling.py', ROOT / 'lean-toolchain']}
    result = {'status': 'passed', 'lean': version,
              'theorems': len(names), 'dependencies': ['Lean bundled library'],
              'axioms': dependencies, 'source_sha256': hashes,
              'commit': os.environ.get('GITHUB_SHA'),
              'run_id': os.environ.get('GITHUB_RUN_ID')}
    (OUT / 'summary.json').write_text(json.dumps(result, indent=2) + '\n', encoding='utf-8')
    print(f'PASS: {len(names)} theorem declarations; kernel and axiom gates passed.')


if __name__ == '__main__':
    main()
