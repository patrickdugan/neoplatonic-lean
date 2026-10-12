"""Audit the Newman-style ontology through all DAGs of size <= 4.

Relation a->b: a immediately grounds b. Local coherence requires
any two immediate parents of b to have a common ancestor. Common
*effect* means every pair has a joint reachable descendant.
"""
from audit_v2 import closure


def audit(n):
    edges_all = [(a, b) for a in range(n) for b in range(n) if a != b]
    counts = {'dag': 0, 'common_effect': 0, 'locally_coherent': 0,
              'both': 0, 'counterexamples': 0,
              'branching_and_merging': 0}
    example = None
    for bits in range(1 << len(edges_all)):
        edges = [e for i, e in enumerate(edges_all) if bits & (1 << i)]
        R = closure(n, edges)
        if any(R[b][a] for a, b in edges):
            continue
        counts['dag'] += 1
        common_effect = all(any(R[a][c] and R[b][c] for c in range(n))
                            for a in range(n) for b in range(n))
        parents = [[a for a, b in edges if b == z] for z in range(n)]
        local = all(any(R[w][a] and R[w][b] for w in range(n))
                    for par in parents for a in par for b in par)
        counts['common_effect'] += int(common_effect)
        counts['locally_coherent'] += int(local)
        if common_effect and local:
            counts['both'] += 1
            roots = [z for z, par in enumerate(parents) if not par]
            valid = [r for r in roots if all(R[r][x] for x in range(n))]
            if len(valid) != 1:
                counts['counterexamples'] += 1
                print('COUNTEREXAMPLE!', edges, roots, valid)
            if any(len(par) > 1 for par in parents):
                counts['branching_and_merging'] += 1
                if example is None:
                    example = {'edges': edges, 'root': valid}
    return counts, example


if __name__ == '__main__':
    for n in range(1, 5):
        print(n, *audit(n))
