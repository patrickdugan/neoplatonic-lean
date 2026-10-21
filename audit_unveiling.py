"""Independent bounded checks of the unveiling models. Standard library only.

These are falsification tests and do not replace the Lean proofs.
"""
from pathlib import Path
import itertools
import json


def subset(a, b):
    return a & b == a


def check_families():
    checked = closed_count = maximal_cases = 0
    for truth in range(16):
        states = [s for s in range(16) if subset(s, truth)]
        true_bits = [1 << p for p in range(4) if truth & (1 << p)]
        for mask in range(1 << len(states)):
            family = {s for i, s in enumerate(states) if mask & (1 << i)}
            checked += 1
            closed = all((s | bit) in family for s in family for bit in true_bits)
            if not closed:
                continue
            closed_count += 1
            for a in family:
                maximal = not any(a != b and subset(a, b) for b in family)
                complete = a == truth
                assert maximal == complete, (truth, family, a)
                maximal_cases += 1
            if family:
                assert truth in family
    assert checked == 66674, checked
    assert closed_count == 298, closed_count
    return dict(sound_families_checked=checked, one_fact_closed_families=closed_count,
                maximality_cases=maximal_cases)


def check_awareness():
    worlds = [False, True]
    for current in worlds:
        known_existential = all(any(v != p for p in worlds) for v in worlds)
        known_witness = any(all(v != p for v in worlds) for p in worlds)
        assert known_existential and not known_witness, current
    return {'awareness_worlds_checked': len(worlds)}


def check_access():
    tests = 0
    for cap in range(65):
        for s in range(66):
            possible = [t for t in range(67) if s < t and t <= cap]
            assert (not possible) == (cap <= s)
            assert s < s + 1
            prefix_s = set(range(s))
            assert prefix_s < set(range(s + 1))
            assert s not in prefix_s
            tests += 1
    return {'capped_access_cases': tests}


def check_projections():
    tests = 0
    for x in itertools.product([False, True], repeat=8):
        def trunc(n, y):
            return tuple(v if i < n else False for i, v in enumerate(y))
        for n in range(9):
            assert trunc(n, trunc(n, x)) == trunc(n, x)
            assert (trunc(n, x) == x) == all(not x[i] for i in range(n, 8))
            for m in range(n + 1):
                assert trunc(m, trunc(n, x)) == trunc(m, x)
                tests += 1
        recovered = tuple(trunc(i + 1, x)[i] for i in range(8))
        assert recovered == x
    return {'projection_nested_cases': tests, 'streams_checked': 256}


def main():
    result = {'status': 'passed', **check_families(), **check_awareness(),
              **check_access(), **check_projections()}
    out = Path(__file__).resolve().parent / 'verification' / 'unveiling'
    out.mkdir(parents=True, exist_ok=True)
    (out / 'finite-audit.json').write_text(json.dumps(result, indent=2) + '\n')
    print(json.dumps(result, indent=2))


if __name__ == '__main__':
    main()
