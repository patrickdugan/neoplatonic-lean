"""Finite countermodel search for the abstract One theorem (not a proof)."""
from itertools import permutations


def transitive_closure(n, arcs):
    reach = [[i == j for j in range(n)] for i in range(n)]
    for i, j in arcs:
        reach[i][j] = True
    for k in range(n):
        for i in range(n):
            for j in range(n):
                reach[i][j] = reach[i][j] or (reach[i][k] and reach[k][j])
    return reach


def inspect(n):
    edges = [(i, j) for i in range(n) for j in range(n) if i != j]
    totals = dict(acyclic=0, coherent=0, one_found=0, counterexamples=0)
    example_multi = None
    for bits in range(1 << len(edges)):
        arcs = [e for k, e in enumerate(edges) if (bits >> k) & 1]
        reach = transitive_closure(n, arcs)
        # A directed cycle violates finite well-foundedness.
        if any(reach[j][i] for i, j in arcs):
            continue
        totals['acyclic'] += 1
        incoming = [sum(j == node for i, j in arcs) for node in range(n)]
        roots = [i for i in range(n) if incoming[i] == 0]
        common = all(any(reach[z][x] and reach[z][y]
                         for z in range(n))
                     for x in range(n) for y in range(n))
        first = [r for r in roots if all(reach[r][x] for x in range(n))]
        if common:
            totals['coherent'] += 1
            if len(first) != 1:
                totals['counterexamples'] += 1
            else:
                totals['one_found'] += 1
        elif len(roots) > 1 and example_multi is None:
            example_multi = {'arcs': arcs, 'roots': roots}
    return totals, example_multi


if __name__ == '__main__':
    for n in range(1, 5):
        totals, alt = inspect(n)
        print(f'n={n}: {totals}; multi-root countermodel: {alt}')
