# A conditional first-principle research program

## What the mathematical target says

Let `r a b` mean that `a` grounds `b`. Write `a ≤ᵣ b` for its
reflexive-transitive closure. A root has no incoming `r` edge. The target
`FirstPrinciple r g` says that `g` is a root and `g ≤ᵣ x` for every object.
It is relative to the chosen domain and relation. It does not express
necessary existence, existence outside the model, simplicity, agency,
consciousness, goodness, or divinity.

If `r` really means immediate grounding, coverhood needs a separate
condition. The original three-node triangle contains an edge with an
alternative two-step path. `DiamondModel.lean` gives a genuine cover
relation allowing both branching and merging.

## Corrected conjecture and stronger theorem

The displayed conjecture in the request is false for an empty domain.
The original code already supplied a seed, and therefore avoided this
problem. With `Nonempty α`, or equivalently a seed parameter, the stated
well-foundedness + local coherence + common effects implication is valid.

There is a stronger theorem:

**For a nonempty domain, well-founded grounding and local backward
confluence, undirected connectedness suffices for a unique universal root.**

Connectedness means that any two objects can be joined by a finite zigzag
of grounding arrows, traversed in either direction. It is the universal
property `∀ x y, Relation.EqvGen r x y`, not a claim about a topology.
Common effects imply this property. The reverse implication fails: a
root with two incomparable terminal children is connected but those
children have no common effect.

The proof is implemented in `Structure.lean`:

1. Well-founded induction gives a root ancestor of each object.
2. Local coherence makes two root ancestors of the same object equal.
3. Therefore any two ancestors of an object have a common ancestor:
   take their root ancestors, which agree at that object.
4. Common ancestry is then transitive across a shared endpoint, so it
   propagates along each finite undirected zigzag.
5. The root ancestor of a seed is consequently an ancestor of every object.
   Any universal root must equal it.

Step 3 is full backward confluence. The theorem does not assume finite
branching, finiteness of the domain, a numerical ranking, transitivity of
the immediate relation, or a bound on grounding depth. Well-foundedness
permits arbitrarily long finite histories and transfinite ranks.

## Newman’s lemma, with the orientation made explicit

Define rewriting by `z → x` iff `r x z`: an effect rewrites to a ground.
Then:

| Grounding language | Rewriting language |
|---|---|
| `WellFounded r` | Termination of `→` (well-foundedness of its converse) |
| `Reach r x z` | `z →* x` |
| `Root r x` | `x` is a normal form |
| local ancestral coherence of co-grounds | Local confluence of `→` |
| common ancestor of `x,y` | Joinability of `x,y` under `→*` |
| backward confluence | Confluence of `→` |

`reverse_reach_iff` proves the closure correspondence. `backward_newman`
proves the full confluence statement, and `newman_rewriting` states it
using Mathlib's `Relation.ReflTransGen` and `Relation.Join` APIs.
This is a proof of the relevant form of Newman’s lemma, not an invocation
of a vaguely similar theorem. In the pinned Mathlib version,
`Relation.church_rosser` assumes a stronger asymmetric one-step joining
condition; the present proof does not misapply it to ordinary local confluence.

Termination is essential to Newman’s implication. A weakly normalizing
counterexample has roots `a,b`, edges `a→x`, `b→y` in the grounding
orientation, and `x→y`, `y→x`. Every object has a root ancestor, and each
pair of immediate co-grounds has a common ancestor. Yet `x` has both
roots. The independent Python checker validates this four-node model;
this particular counterexample is a finite computation, not a Lean theorem.

## Where circularity would enter

The following equivalences are proved in Lean. The first, third and
fourth use well-foundedness; the first and third additionally take a seed.

| Candidate premise | Exact consequence / equivalent characterization |
|---|---|
| global common ancestry | existence of a unique universal root |
| local coherence, under well-foundedness | each object has a unique root ancestor |
| local coherence + connectedness | existence of a unique universal root |
| existence of exactly one root, under well-foundedness | existence of a unique universal root |

These equivalences are useful mathematics and an audit of explanatory
strength. Logical equivalence is not by itself proof of argumentative
circularity: an equivalent premise could have independent evidence.
However, merely relabeling the conclusion as common ancestry, a bottom
element, or an initial object supplies no independent evidence. Any
metaphysical application must justify its structural premises without
assuming the unity it aims to explain.

Local coherence has content beyond graph connectedness. The merger
`a→z←b` is finite, well-founded, connected, and has common effects, but
has two independent roots. `MergeModel.lean` verifies this obstruction.
Conversely, a disjoint union of two rooted systems is terminating and
locally coherent; it has no global root. `Models.lean` supplies an infinite
instance using the empty relation on naturals.

## Order, lattice, and completeness routes

`Orders.lean` proves that well-founded grounding makes `≤ᵣ` antisymmetric,
so reachability defines a partial order. Extra acyclicity and antisymmetry
assumptions are unnecessary in the main theorem. In infinite systems,
acyclicity alone is insufficient: the strict integer order is acyclic,
connected, locally coherent, and has common effects, but has no root.
`integers_have_no_root` proves the last assertion.

For a pre-existing partial order, if **every strict comparison** is an
edge, `FirstPrinciple (<) g` is equivalent to `∀ x, g ≤ x`. This explicit
comparison-edge assumption matters: the cover relation on a dense order
can be empty, so replacing `<` with covers would invalidate the statement.

The following conditional routes are formalized:

- A nonempty well-founded meet-semilattice has a least element. Binary
  meets provide common lower bounds; well-foundedness supplies a minimal
  point, and lower directedness makes it least.
- An `OrderBot` structure supplies a universal root under `<` without
  well-foundedness. It already includes the desired bottom element.
- A `CompleteLattice` has this property because its structure includes
  bottom. Arbitrary infima, in particular the infimum of the whole carrier,
  are a substantive completeness assumption.

These other mathematical observations are analytic research notes here,
not additional Lean certifications:

- **Upper directedness** gives common consequences, not common causes.
  The merger countermodel shows why it cannot replace coherence.
- **Directed completeness** usually means suprema of nonempty directed
  subsets. It need not provide bottom: the three-element merger poset
  has all such suprema and is upper directed, but has two minimal points.
  A convention that includes the empty directed set changes the premise.
- **Conditional completeness** need not give a global least point.
  The usual real line supplies all bounded nonempty infima and has no
  least element. Binary meets alone also fail there without well-foundedness.
- **Chain lower bounds + Zorn** can yield minimal points. A unique least
  point still needs a lower-directedness or compatibility condition.
  The extra order-completeness and choice commitments must be exposed.

## Compactness and connectedness

Topological properties cannot constrain an arbitrary grounding relation
without a compatibility axiom. A finite set with the indiscrete topology
is compact and connected; put the two-root merger relation on three
points. It is also well-founded and upper directed, but lacks a least
point. Thus bare topological compactness and connectedness do not close
the gap. This example is described mathematically; the topology is not
formalized in this repository.

A meaningful compactness route is proved in `Compactness.lean`:

Let `X` be a nonempty compact space with a partial order. Assume every
principal lower set `↓x = {y | y ≤ x}` is closed, and that the order is
lower directed. Then there is a least element. Indeed, the family of
closed principal lower sets has the finite intersection property:
inductively choose common lower bounds for any finite list. Compactness
gives a point in the intersection over all `x`; that point is below all
objects, and antisymmetry makes it unique.

Here lower directedness is still common ancestry, now for the order.
Compactness replaces well-foundedness as the existence mechanism; it
does not create explanatory unity by itself. Any attempted physical use
must justify both the topology/order compatibility and lower directedness.

Logical compactness also has a sharp limitation. Adding a constant `g`
and asking for `r* g x` for every named object may produce a model in an
extension, rather than a root in the original structure. Finite-path
reachability is not uniformly first-order definable in arbitrary graphs,
and ordinary first-order well-foundedness is not preserved by compactness.
For example, finite subsets of the axioms for an infinite descending
chain can be modeled by finite chains; their compactness model is not
well-founded. A compactness argument cannot silently retain that property.

## Category-theoretic formulation

The reachability partial order gives a thin category with a unique
morphism `a → b` exactly when `a ≤ᵣ b`. A universal root is an initial
object. Thinness makes the uniqueness of a morphism automatic; the work
lies in existence of an arrow from the candidate to every object.
Antisymmetry upgrades uniqueness up to isomorphism to equality of points.
For arbitrary categories, initial objects are only unique up to unique
isomorphism, and common ancestors say nothing about uniqueness of arrows.

Assuming the existence of an empty coproduct, or all small colimits,
already assumes an initial object. Assuming binary products in a thin
category assumes meets, giving lower directedness; adding termination
then invokes the formalized semilattice route. These translations clarify
assumptions rather than derive ontology from bare category axioms.
`Category.lean` proves leastness equivalent to initiality for partial
orders, and proves the exact equivalence for the grounding reachability
category. No existence theorem for arbitrary categories is asserted.

## What RH contributes, and what it does not

`RH.lean` uses the actual pinned Mathlib definition of `RiemannHypothesis`.
RH implies all nontrivial zeta zeros have real part `1/2`. A witness of a
nontrivial zero then makes this shared real coordinate uniquely
characterized (`rh_unique_spectral_axis`). Without a witness, an empty
zero set would make every coordinate satisfy the universal property.

The unique coordinate is a real number, not an ontological ground. The
field `spectralAlignmentToCommonPrior` supplies the entire passage from
analysis to common ancestry. Under well-foundedness and a seed, its
consequent is equivalent to the desired first-principle conclusion.
The `realizesNat_injective` field is not used in the proof; the realization
map is used only to obtain a seed. Neither infinitude nor injectivity
does explanatory work in this argument.

`RHIndependence.lean` proves that even with an RH hypothesis, the empty
grounding relation on `ℕ` is well-founded and has no universal root.
This is an explicit counterinterpretation for an unconstrained grounding
relation; it is **not** a proof that RH is logically independent of ZFC,
Lean, or a specified nontrivial bridge theory. RH's consistency is not
proved or presumed by the theorem, which is an implication.

A defensible arithmetic extension must first define the candidate
domain and grounding relation without inserting common ancestry, and
then state a precise analytic-to-structural theorem. An RH conditional
that merely assumes the required bridge remains a conditional theorem.
No known conjecture here strengthens the unrestricted ontological result.

## Next research gates

1. Develop a separately justified grounding semantics, with the distinction
   between immediate edges, cover edges, and transitive dependence explicit.
2. Investigate naturally occurring terminating confluent systems. Their
   unique normal forms are domain-relative; compare examples where distinct
   connected components have different normal forms.
3. Identify examples of the formalized compact closed-lower-set theorem in
   which compactness and lower directedness have independent mathematical
   content; seek weaker compatibility assumptions.
4. Extend the formalized thin-category correspondence while keeping it
   separate from claims about arbitrary categories or physical explanation.
5. If pursuing RH, remove the opaque bridge field, specify a concrete
   construction, and search for countermodels before attempting a proof.
6. For metaphysical application, provide independent arguments for
   well-foundedness, local coherence, domain nonemptiness, and connectedness.
   State what would falsify each argument.

The current deliverable establishes conditional mathematics and makes its
interpretive burden explicit. It supplies no unconditional inference from
the existence of mathematics to a unique ontological foundation.

## Primary implementation references

- [Pinned Mathlib relation closures and Church–Rosser theorem](https://github.com/leanprover-community/mathlib4/blob/f897ebcf72cd16f89ab4577d0c826cd14afaafc7/Mathlib/Logic/Relation.lean).
- [Pinned definition of the genuine Riemann Hypothesis](https://github.com/leanprover-community/mathlib4/blob/f897ebcf72cd16f89ab4577d0c826cd14afaafc7/Mathlib/NumberTheory/LSeries/RiemannZeta.lean).
- [Pinned compact intersection theorem](https://github.com/leanprover-community/mathlib4/blob/f897ebcf72cd16f89ab4577d0c826cd14afaafc7/Mathlib/Topology/Compactness/Compact.lean).
- [Pinned preorder category implementation](https://github.com/leanprover-community/mathlib4/blob/f897ebcf72cd16f89ab4577d0c826cd14afaafc7/Mathlib/CategoryTheory/Category/Preorder.lean).
- [Official Lean manual installation instructions](https://lean-lang.org/install/manual/).
