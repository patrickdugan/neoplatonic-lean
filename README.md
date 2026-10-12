# The One from the Many? A verified conditional research program

Lean 4 **4.24.0**, Mathlib **f897ebcf72cd16f89ab4577d0c826cd14afaafc7**.
The project has **17 modules and 81 theorem declarations**. The ten
exploratory modules have been repaired and extended with seven modules.
The acceptance record is `verification/summary.json`; full types and
axiom reports are in `verification/axioms.log`.

Read **AUDIT.md** for the complete theorem inventory, premise audit,
dependency map, compilation repairs, model counts, and trust boundary.
Read **RESEARCH.md** for proofs, counterexamples, philosophical analysis,
and further research gates.

## Main mathematical result

Let `prior a b` mean that `a` grounds `b`, and `Reach prior` be the
reflexive-transitive closure. A first principle is a root that reaches
every object. For a nonempty carrier:

```
WellFounded prior
∧ LocallyCoherent prior
∧ Connected prior
→ ∃! g, Root prior g ∧ ∀ x, Reach prior g x
```

`Connected` is undirected finite-path connectedness, using `Relation.EqvGen`.
This is strictly weaker than the original common-effect condition.
`Structure.lean` proves the result, full backward confluence (Newman's
lemma), the correspondence with Mathlib's rewriting API, and the exact
equivalences needed to audit whether premises simply repackage the target.

The displayed conjecture without nonemptiness is false on the empty
carrier; the original source already required a seed. Counterexamples
also show why well-foundedness, coherence, and connectivity cannot simply
be omitted. `DiamondModel.lean` supplies genuine immediate cover edges
with both branching and merging.

## What is and is not established

All results are conditional mathematics or explicit model facts. None
shows that reality satisfies the grounding premises. Under
well-foundedness and nonemptiness, common ancestry is equivalent to a
unique universal root; independent justification of that premise remains
necessary. The target carries no consciousness, agency, goodness,
personal deity, or modal necessity predicate.

Additional results concern well-founded meet-semilattices, bottom and
complete-lattice structures, compact lower-directed partial orders with
closed principal lower sets, and initiality in the thin reachability
category. Each result exposes its structural assumptions.

The RH branch uses genuine Mathlib `RiemannHypothesis` as an explicit
hypothesis. RH and a nontrivial-zero witness uniquely characterize the
shared real coordinate `1/2`. The separate spectral-to-ancestry bridge is
an unsupported premise. `RHIndependence.lean` gives a well-founded
infinite grounding counterinterpretation with no universal root even
under an RH hypothesis. This is not an independence result for RH in a
foundational theory.

## Reproduce

Install the Lean toolchain in `lean-toolchain` and ensure `lake`, Git and
Python 3.10+ are on PATH. The checked Python version was 3.12.

```sh
lake exe cache get Mathlib.Logic.Relation Mathlib.Data.Int.Basic Mathlib.Tactic.Basic Mathlib.NumberTheory.LSeries.RiemannZeta Mathlib.Order.CompleteLattice.Defs Mathlib.Topology.Compactness.Compact Mathlib.CategoryTheory.Category.Preorder Mathlib.CategoryTheory.Limits.Shapes.IsTerminal
python verify.py
```

On Windows without Lean installed, `bootstrap.ps1` downloads and hashes
Lean into `.toolchain/` inside this project, then fetches dependencies
and runs the same gate. It does not install into the user home.

```powershell
powershell -ExecutionPolicy Bypass -File .\bootstrap.ps1
```

Keep `lake-manifest.json`; it locks Mathlib and all transitive packages.
The verification script builds the library, re-elaborates every source,
prints every theorem's type and transitive axioms, rejects proof escapes
and unexpected axioms, and reruns all model audits. It allows only Lean's
standard `propext`, `Classical.choice`, and `Quot.sound`. No `sorry`,
`admit`, extra global axioms, or native-decision proof shortcuts occur
in project proof code. Dependency caches are part of the stated trust
boundary. A CI workflow supplies the same gate; it has not been run on
GitHub during this local audit.

## Finite models

The three supplied scripts and a new Kahn/DFS checker agree on all
labeled DAGs through four nodes. The independent checker additionally
enumerates loops and the empty carrier, testing 66,067 relations total.
For four nodes, 543 DAGs exist; 216 satisfy coherence and common effects;
192 of those have a node with multiple parents. There are zero nonempty
counterexamples. Requiring genuine cover edges changes those counts to
219, 36 and 12. Finite enumeration is a falsification check, not the
proof of the general theorem.
