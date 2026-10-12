"""Reproducible acceptance gate. Requires pinned `lake` on PATH and Mathlib cache.

Checks every project theorem's transitive axiom dependencies. Lean's standard
logical axioms are allowed; sorryAx and every other additional axiom fail.
The metaphysical hypotheses remain explicit theorem parameters/structure fields.
"""
from pathlib import Path
import hashlib
import json
import re
import shutil
import subprocess
import sys

ROOT = Path(__file__).resolve().parent
LOG = ROOT / 'verification'
ALLOWED = {'propext', 'Classical.choice', 'Quot.sound'}


def lean_code(text):
    """Strip nested Lean block and line comments, retaining line structure."""
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
        raise RuntimeError('Unclosed Lean comment')
    return ''.join(out)


def run(args, name):
    result = subprocess.run(args, cwd=ROOT, text=True, encoding='utf-8',
                            errors='replace', stdout=subprocess.PIPE,
                            stderr=subprocess.STDOUT)
    (LOG / name).write_text(result.stdout, encoding='utf-8')
    print(f'{name}: exit {result.returncode}', flush=True)
    if result.returncode:
        print(result.stdout)
        raise RuntimeError(f'Failed: {args}')
    return result.stdout


def main():
    LOG.mkdir(exist_ok=True)
    # Never leave a stale success certificate following a failing run.
    (LOG / 'summary.json').unlink(missing_ok=True)
    lake = shutil.which('lake')
    if not lake:
        raise RuntimeError('lake is missing from PATH; install lean-toolchain first')
    modules = sorted((ROOT / 'Neoplatonic').glob('*.lean'))
    declarations = []
    for path in modules:
        code = lean_code(path.read_text(encoding='utf-8'))
        forbidden = re.findall(r'\b(?:sorry|admit|axiom|unsafe|native_decide|implemented_by)\b', code)
        if forbidden:
            raise RuntimeError(f'Forbidden proof escape in {path}: {forbidden}')
        for match in re.finditer(r'^theorem\s+(\w+)', code, re.M):
            declarations.append('Neoplatonic.' + match.group(1))
    lean_version = run([lake, 'env', 'lean', '--version'], 'lean-version.log').strip()
    if not re.search(r'version 4\.24\.0[,)]', lean_version):
        raise RuntimeError(f'Wrong Lean toolchain: {lean_version}')
    manifest = json.loads((ROOT / 'lake-manifest.json').read_text(encoding='utf-8-sig'))
    mathlib = next(p for p in manifest['packages'] if p['name'] == 'mathlib')
    if mathlib['rev'] != 'f897ebcf72cd16f89ab4577d0c826cd14afaafc7':
        raise RuntimeError('Wrong Mathlib revision')
    run([lake, 'build', 'Neoplatonic'], 'build.log')
    # Re-elaborate every source independently even when Lake reports cached jobs.
    for path in modules:
        run([lake, 'env', 'lean', str(path.relative_to(ROOT))], path.stem + '.log')
    report = 'import Neoplatonic\n\n' + '\n'.join(
        '#check ' + name + '\n#print axioms ' + name for name in declarations) + '\n'
    (ROOT / 'AxiomReport.lean').write_text(report, encoding='utf-8')
    axioms = run([lake, 'env', 'lean', 'AxiomReport.lean'], 'axioms.log')
    dependencies = {}
    for name in declarations:
        pattern = re.escape("'" + name + "'")
        match = re.search(pattern + r' depends on axioms:\s*\[([^\]]*)\]', axioms)
        if match:
            found = {s.strip() for s in match.group(1).split(',') if s.strip()}
        elif re.search(pattern + r' does not depend on any axioms', axioms):
            found = set()
        else:
            raise RuntimeError(f'Missing axiom report: {name}')
        if found - ALLOWED:
            raise RuntimeError(f'Unapproved axioms for {name}: {found - ALLOWED}')
        dependencies[name] = sorted(found)
    for script in ['audit_models.py', 'audit_v2.py', 'audit_confluence.py', 'audit_independent.py']:
        run([sys.executable, script], script.removesuffix('.py') + '.log')
    hashes = {str(p.relative_to(ROOT)).replace('\\', '/'):
              hashlib.sha256(p.read_bytes()).hexdigest()
              for p in [*modules, ROOT / 'Neoplatonic.lean', ROOT / 'lean-toolchain',
                        ROOT / 'lake-manifest.json', ROOT / 'lakefile.toml',
                        *sorted(ROOT.glob('audit_*.py')), ROOT / 'verify.py',
                        ROOT / 'AxiomReport.lean']}
    result = dict(status='passed', lean=lean_version, mathlib=mathlib['rev'],
                  modules=len(modules), theorems=len(declarations),
                  axioms=dependencies, source_sha256=hashes)
    (LOG / 'summary.json').write_text(json.dumps(result, indent=2) + '\n', encoding='utf-8')
    print(f'PASS: {len(modules)} modules, {len(declarations)} theorems; all gates passed.')


if __name__ == '__main__':
    main()
