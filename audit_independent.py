"""Independent finite audit: Kahn cycle detection and per-source DFS.

Enumerates ALL labeled directed relations (including loops), n=0..4.
Cross-checks the supplied Floyd-Warshall predicates on every acyclic case.
No third-party dependencies. Assertions make failures exit nonzero.
"""
from itertools import product
from math import comb
import json
from pathlib import Path
from audit_v2 import closure
from audit_models import inspect
from audit_v2 import audit as audit_parent
from audit_confluence import audit as audit_local


def dfs(start, adj):
    seen, todo = {start}, [start]
    while todo:
        for target in adj[todo.pop()]:
            if target not in seen:
                seen.add(target)
                todo.append(target)
    return seen


def check(n):
    potential = list(product(range(n), repeat=2))
    counts = dict(relations=1 << (n*n), dag=0, common_prior=0,
                  common_effect=0, single_parent=0, locally_coherent=0,
                  connected=0, local_connected=0, both=0, parent_effect=0,
                  multiple_parents=0, cover_dag=0, cover_both=0,
                  cover_both_multiple_parents=0, unique_first_principle=0,
                  empty_premise_failure=0, counterexamples=0)
    for mask in range(1 << len(potential)):
        edges = [e for k, e in enumerate(potential) if mask & (1 << k)]
        adj, rev = [set() for _ in range(n)], [set() for _ in range(n)]
        for a, b in edges:
            adj[a].add(b)
            rev[b].add(a)
        degree = [len(p) for p in rev]
        todo = [v for v in range(n) if not degree[v]]
        processed = 0
        while todo:
            v = todo.pop()
            processed += 1
            for w in adj[v]:
                degree[w] -= 1
                if not degree[w]:
                    todo.append(w)
        if processed != n:
            continue
        counts['dag'] += 1
        descendants = [dfs(v, adj) for v in range(n)]
        ancestors = [dfs(v, rev) for v in range(n)]
        original = closure(n, edges)
        assert all(original[a][b] == (b in descendants[a])
                   for a in range(n) for b in range(n))
        cp = all(ancestors[a] & ancestors[b] for a in range(n) for b in range(n))
        ce = all(descendants[a] & descendants[b] for a in range(n) for b in range(n))
        lc = all(ancestors[a] & ancestors[b] for ps in rev for a in ps for b in ps)
        sp = all(len(ps) <= 1 for ps in rev)
        connected = all(len(dfs(v, [adj[k] | rev[k] for k in range(n)])) == n
                        for v in range(n))
        roots = {v for v in range(n) if not rev[v]}
        first = {r for r in roots if len(descendants[r]) == n}
        unique_per_node = all(len(roots & ancestors[v]) == 1 for v in range(n))
        covers = all(not any(w != a and w != b and w in descendants[a]
                             and b in descendants[w] for w in range(n))
                     for a, b in edges)
        assert lc == unique_per_node
        # Nonemptiness is essential to both equivalences.
        if n:
            assert cp == (len(first) == 1)
            assert (lc and connected) == (len(first) == 1)
        for key, flag in [('common_prior', cp), ('common_effect', ce),
                          ('single_parent', sp), ('locally_coherent', lc),
                          ('connected', connected), ('local_connected', lc and connected),
                          ('both', lc and ce), ('parent_effect', sp and ce),
                          ('multiple_parents', lc and ce and not sp),
                          ('cover_dag', covers), ('cover_both', covers and lc and ce),
                          ('cover_both_multiple_parents', covers and lc and ce and not sp),
                          ('unique_first_principle', len(first) == 1),
                          ('empty_premise_failure', not n and lc and ce and not first)]:
            counts[key] += bool(flag)
        if n and lc and ce and len(first) != 1:
            counts['counterexamples'] += 1
    if n:
        base, _ = inspect(n)
        par, _ = audit_parent(n)
        loc, _ = audit_local(n)
        assert counts['dag'] == base['acyclic'] == par['acyclic'] == loc['dag']
        assert counts['common_prior'] == base['coherent']
        assert counts['both'] == loc['both']
        assert counts['multiple_parents'] == loc['branching_and_merging']
        assert counts['parent_effect'] == par['both']
        assert counts['common_effect'] == par['common_effect'] == loc['common_effect']
        assert counts['locally_coherent'] == loc['locally_coherent']
        assert counts['single_parent'] == par['unique_parent']
        assert base['counterexamples'] == par['counterexamples'] == loc['counterexamples'] == 0
    return counts


def main():
    rows = {str(n): check(n) for n in range(5)}
    # Independent inclusion-exclusion recurrence for labeled DAGs.
    recurrence = [1]
    for n in range(1, 5):
        recurrence.append(sum((-1)**(k+1) * comb(n, k) * 2**(k*(n-k))
                              * recurrence[n-k] for k in range(1, n+1)))
    assert [rows[str(n)]['dag'] for n in range(5)] == recurrence == [1, 1, 3, 25, 543]
    assert rows['0']['empty_premise_failure'] == 1
    assert rows['0']['unique_first_principle'] == 0
    # Weak normalization + local coherence does not replace well-foundedness.
    # Roots 0,1; cycle 2<->3; 0->2 and 1->3. Every node has a root ancestor.
    adj = [{2}, {3}, {3}, {2}]
    rev = [set(), set(), {0, 3}, {1, 2}]
    anc = [dfs(v, rev) for v in range(4)]
    assert all(anc[a] & anc[b] for ps in rev for a in ps for b in ps)
    assert all({0, 1} & anc[v] for v in range(4))
    assert {0, 1} <= anc[2]
    result = {'method': 'all relations; Kahn + DFS; cross-check supplied code',
              'counts': rows, 'dag_recurrence': recurrence,
              'weak_normalization_countermodel': [[0, 2], [1, 3], [2, 3], [3, 2]]}
    Path('verification').mkdir(exist_ok=True)
    Path('verification/models.json').write_text(json.dumps(result, indent=2) + '\n')
    print(json.dumps(result, indent=2))


if __name__ == '__main__':
    main()
