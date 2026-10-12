"""Exhaustive small-model audit for revised grounding axioms.

The finite model test is independent of Lean and checks the exact logical
claim: well-founded + common effect + unique immediate predecessor
implies a unique root with directed reachability to all vertices.
"""
from itertools import product


def closure(n, edges):
    reach = [[i == j for j in range(n)] for i in range(n)]
    for a, b in edges:
        reach[a][b] = True
    for k in range(n):
        for i in range(n):
            for j in range(n):
                reach[i][j] |= reach[i][k] and reach[k][j]
    return reach


def audit(n):
    possible = [(i, j) for i in range(n) for j in range(n) if i != j]
    counts = {"acyclic": 0, "common_effect": 0, "unique_parent": 0,
              "both": 0, "counterexamples": 0}
    merge_example = None
    for bits in range(1 << len(possible)):
        edges = [edge for k, edge in enumerate(possible) if bits & (1 << k)]
        R = closure(n, edges)
        if any(R[b][a] for a, b in edges):
            continue
        counts["acyclic"] += 1
        common_effect = all(any(R[x][z] and R[y][z] for z in range(n))
                            for x in range(n) for y in range(n))
        single_parent = all(sum(b == z for a, b in edges) <= 1
                            for z in range(n))
        counts["common_effect"] += int(common_effect)
        counts["unique_parent"] += int(single_parent)
        if common_effect and single_parent:
            counts["both"] += 1
            roots = [i for i in range(n) if not any(b == i for a, b in edges)]
            one = [r for r in roots if all(R[r][j] for j in range(n))]
            if len(one) != 1:
                counts["counterexamples"] += 1
                print("FOUND COUNTEREXAMPLE", n, edges, roots, one)
        if common_effect and not single_parent and merge_example is None:
            roots = [i for i in range(n) if not any(b == i for a, b in edges)]
            if len(roots) > 1:
                merge_example = {"edges": edges, "roots": roots}
    return counts, merge_example


if __name__ == "__main__":
    for n in range(1, 5):
        print(n, *audit(n))
