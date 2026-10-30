# The One from the Many? A conditional research program in Lean

Lean **4.24.0**, Mathlib **f897ebcf72cd16f89ab4577d0c826cd14afaafc7**.

The grounding library has **18 modules and 86 theorem declarations**, including
five new bridge theorems. The standalone `Unveiling.lean` adds **60 theorems**.
The combined inventory is **146 theorem declarations**, an increase of 65 over
the original 81-theorem grounding development.

## Tower of Unveiling extension

Read **UNVEILING.md** for the definitions, mathematical interpretation,
assumption audit, and precise implementation boundaries.

The main access theorem is:

```
All admissible information states are sound
∧ admissibility is closed under adjoining any true fact
→ (maximal admissible state ↔ complete state)
```

A fixed source/mediator/learner ontology supports a capped disclosure policy
with a reachable terminal state and an open policy with no terminal state.
`Neoplatonic/UnveilingBridge.lean` proves this ontology satisfies the existing
`GroundTheory` interface and has its unique first principle.

The standalone file also proves repeated-knowledge stabilization, a known
existential with no uniformly known witness, Lob's rule from explicit
fixed-point and derivability conditions, a conditional reflection progression,
and existence and uniqueness of a coherent limit of finite binary views.

The arithmetic theorem is at the provability-interface level. Instantiating
that interface with arithmetized Peano arithmetic remains further work.
The binary inverse limit supplies an explicit mathematical example; cohesive
homotopy type theory and a Postnikov tower are outside this implementation.

### Verification records

The standalone gate writes `verification/unveiling/summary.json` and
`verification/unveiling/axioms.log`. The integration gate writes
`verification/summary.json` and `verification/axioms.log`.

GitHub Actions attaches the current outputs as **unveiling-proof-certificate**
and **neoplatonic-integration-certificate**. Each result must be read against
its checked source revision. Committed logs from earlier audits are historical
records, and may cover an older inventory.

Run both verification scripts to audit both namespaces. Structure fields and
parameters remain explicit hypotheses even when a theorem has no additional
kernel-axiom dependencies.

## Grounding research

Read **AUDIT.md** for the original 81-theorem inventory, premise audit,
dependency map, compilation repairs, model counts, and trust boundary.
Read **RESEARCH.md** for its proofs and further research gates.

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
equivalences needed to audit whether premises repackage the target.

The displayed conjecture without nonemptiness is false on the empty
carrier; the original source already required a seed. Counterexamples
also show why well-foundedness, coherence, and connectivity cannot simply
be omitted. `DiamondModel.lean` supplies immediate cover edges
with both branching and merging.

## Interpretation and scope

All results are conditional mathematics or explicit model facts. They do
not establish that reality satisfies the grounding premises. Under
well-foundedness and nonemptiness, common ancestry is equivalent to a
unique universal root; independent justification of that premise remains
necessary. The target carries no consciousness, agency, goodness,
personal deity, or modal necessity predicate.

Additional results concern well-founded meet-semilattices, bottom and
complete-lattice structures, compact lower-directed partial orders with
closed principal lower sets, and initiality in the thin reachability
category. Each result exposes its structural assumptions.

The RH branch uses Mathlib `RiemannHypothesis` as an explicit
hypothesis. RH and a nontrivial-zero witness uniquely characterize the
shared real coordinate `1/2`. The separate spectral-to-ancestry bridge is
an unsupported premise. `RHIndependence.lean` gives a well-founded
infinite grounding counterinterpretation with no universal root even
under an RH hypothesis. This is not an independence result for RH in a
foundational theory.

## Reproduce

Install the Lean toolchain in `lean-toolchain` and ensure `lean`, `lake`, Git
and Python 3.10+ are on PATH. The standalone unveiling development needs only
the bundled Lean library:

```sh
python3 verify_unveiling.py
python3 audit_unveiling.py
```

For the integrated grounding library:

```sh
lake exe cache get Mathlib.Logic.Relation Mathlib.Data.Int.Basic Mathlib.Tactic.Basic Mathlib.NumberTheory.LSeries.RiemannZeta Mathlib.Order.CompleteLattice.Defs Mathlib.Topology.Compactness.Compact Mathlib.CategoryTheory.Category.Preorder Mathlib.CategoryTheory.Limits.Shapes.IsTerminal
python3 verify.py
```

On Windows without Lean installed, `bootstrap.ps1` downloads and hashes
Lean into `.toolchain/` inside this project, then fetches dependencies
and runs the integrated grounding gate. It does not install into the user
home. Run the standalone scripts as well with the toolchain on PATH.

```powershell
powershell -ExecutionPolicy Bypass -File .\bootstrap.ps1
python .\verify_unveiling.py
python .\audit_unveiling.py
```

Keep `lake-manifest.json`; it locks Mathlib and all transitive packages.
The verification scripts build the libraries, print theorem types and
transitive axiom dependencies, and reject incomplete proofs and unexpected
axioms. Only Lean's standard `propext`, `Classical.choice`, and `Quot.sound`
are permitted. Native-decision proof shortcuts are rejected. The standalone
source is compiled with warnings treated as errors. Dependency caches remain
part of the integrated build's trust boundary.

## Finite audits

The unfolding audit enumerates **66,674** sound information-set families
across all truth predicates on four facts. **298** satisfy one-fact closure;
**1,749** member-state maximality tests satisfy the predicted equivalence.
It also checks **4,290** capped-access cases and **11,520** nested projection
cases over **256** eight-bit streams, plus the two-world awareness example.
These are independent bounded checks supplementing the general Lean proofs.

The original grounding scripts agree on all labeled DAGs through four nodes.
The independent checker additionally enumerates loops and the empty carrier,
testing **66,067** relations total. For four nodes, **543** DAGs exist; **216**
satisfy coherence and common effects; **192** of those have a node with multiple
parents. There are zero nonempty counterexamples. Requiring genuine cover
edges changes those counts to **219**, **36**, and **12**.
