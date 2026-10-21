# Tower of Unveiling: access, reflection, and coherent limits

Research implementation, 21 October 2026. Lean 4.24.0.

The development turns the mathematical claims in *Modal Logic, Kashf, and the Tower of Unveiling* into explicit models and conditional theorems. `Unveiling.lean` uses Lean's bundled library. `Neoplatonic/UnveilingBridge.lean` connects its grounding model to this repository's existing first-principle theorem and therefore uses the locked Mathlib environment.

## Main result: what access contributes

Fix a predicate `truth` on a type of facts and a family `allowed` of information sets. Suppose every admissible information set is sound and the family is closed under adjoining any true fact. Then, for every admissible state:

```
MaximalIn allowed state ↔ Complete truth state
```

This is `Unveiling.maximal_iff_complete`. The proof inspects a missing true fact. Closure makes its one-fact extension admissible, and that extension strictly contains the old state. Conversely, soundness of all alternatives prevents any extension from adding something beyond a complete state.

The corollary `no_maximal_of_missing_and_closure` states that a class whose members all omit a true fact has no maximal member when this closure condition holds. That corollary needs no additional soundness hypothesis because its missing-fact premise already supplies the witness needed for growth.

`OneFactClosed` is a sufficient structural access condition. We have not established it as the weakest possible condition. A restricted family can permit some informative extensions while failing closure for particular other facts.

These information sets carry no implicit deduction system. An arithmetic application needs a deductive theory and a proof that its intended extension operation meets the interface.

## A common ontology with both termination behaviors

The carrier has an ungrounded `source`, one `mediator`, and a distinct `learner n` for every natural number n. Grounding edges run from the source to the mediator, then from the mediator to each learner. This relation is well-founded and has exactly one ungrounded entity.

At stage n the learner knows the facts with indices below n. Every atomic fact is designated true. The source's information predicate contains every index, while every learner misses its own index.

Two policies share that entire structure:

* `CappedAccess cap s t` permits s < t ≤ cap.
* `OpenAccess s t` permits s < t.

The capped policy has a terminal state at `cap`. Under the open policy each n has the strict successor n+1. The bridge additionally proves that the capped terminal state is reachable from stage zero using the repository's reflexive-transitive `Reach` relation.

The same carrier satisfies the actual `Neoplatonic.GroundTheory` interface. The existing `unique_first_principle` theorem therefore applies to it. `unveiling_first_principle_does_not_determine_termination` packages the unique source, a reachable capped terminal state, and the open policy's absence of terminal states.

This is a concrete countermodel argument for the stated grounding premises. Its scope is the chosen model class. It does not claim a syntactic independence theorem about a foundational theory, or establish that the carrier describes God or a spiritual event.

`capped_access_fails_oneFactClosure` identifies exactly where the capped example falls outside the sufficient access condition: adding the true fact at the cap produces an unavailable information state.

## Awareness and repeated introspection

For a reflexive, transitive accessibility relation, the usual possible-worlds knowledge operator satisfies K(K(p)) iff K(p). `iterate_knowledge_stabilizes` extends this equivalence to every positive finite iteration. These statements keep the frame and proposition fixed.

A separate two-world model has two atomic facts. At each world one fact falls outside awareness, and its identity varies with the world. The model satisfies knowledge that some fact is outside awareness, while failing the claim that there is one particular fact known to be outside awareness throughout the alternatives. See `known_existence_without_known_witness`.

This is a quantified epistemic example built from explicit predicates. It implements the relevant existential/witness distinction. A full quantified awareness language, including awareness of complex sentences, remains a separate development.

## The provability argument

`ProvabilityPresentation` records a formula type with implication, a falsity symbol, a provability predicate and its object-language box. Its fields expose modus ponens, necessitation, distribution and positive introspection. Propositional composition and application under an antecedent are supplied as derived-rule interfaces.

The diagonal premise supplies, for each p, a sentence d with provable implications in both directions between d and (box d implies p).

From those fields `lob_rule` derives:

```
proves (box p implies p) → proves p
```

Applying the rule to falsity gives `second_incompleteness_interface`: a consistent presentation cannot prove the designated consistency sentence. The result uses the diagonal premise explicitly. The file supplies a small consistent modal interpretation, so the presentation interface is inhabited.

The fixed-point construction for a concrete arithmetic syntax, the representation of proof checking, and the verification of the derivability conditions for Peano arithmetic are outside this implementation. Foundation's incompleteness development is a potential backend; it is not a dependency of this code and has not been imported or compiled here.

`internal_factivity_conflicts_with_consistency` records the consequence of adding unrestricted internally provable factivity to this interface. It is a result about the stated provability structure. It does not show that ordinary epistemic knowledge is inconsistent.

## Reflection progressions

`ReflectionInterface` adds a successor operation on presentations and an admissibility predicate. Every admissible presentation is assumed consistent, successor steps preserve admissibility, old theorems remain provable, and the successor proves the previous stage's consistency sentence.

The unprovability gap is obtained from `second_incompleteness_interface`. It is not a nontermination field in this interface. `reflection_no_maximal_admissible` derives a strict admissible extension of every admissible stage.

`MarkedProgression` isolates the general pattern for iteration. Theorems establish admissibility at every finite stage, strict growth between all indices m < n, and absence of repeated stages. `prefixProgression` gives an explicit mathematical instance of this general pattern.

Admissibility preservation is essential. Merely assuming consistency does not justify treating the consistency-extension step as preserving consistency. For the intended arithmetic application, semantic soundness is one route to proving the preservation field.

The implementation treats natural-number-indexed iteration. It does not implement ordinal notations, effective limit-stage unions, or a transfinite Turing progression. Its conclusions concern possible extensions and explicitly chosen successor paths.

## Finite views and a complete limit

A bit stream is a function from natural numbers to Boolean values. `Truncate n` preserves the first n bits and fills later positions with false.

The projection is idempotent. For every finite n there are different streams with the same projection. All finite projections taken together determine the stream uniquely. A compatible family of finite projections has a uniquely reconstructed stream, proved in `coherent_limit_exists_unique`.

The all-true stream acquires a further visible bit at every finite step. The all-false stream is fixed immediately. `truncation_fixed_iff_tail_false` characterizes exactly when a particular stream is already recovered at a given stage.

This is a fully explicit inverse-limit model. It supplies a mathematical example in which every finite view can lose information and the coherent total limit still exists. Postnikov truncations, homotopy groups, cohesive modalities and string theory require further constructions; none is encoded by the bit index.

## Actual resource bounds

`bounded_rank_forbids_infinite_path` proves that a trajectory whose natural-number resource rank strictly increases cannot remain below a fixed finite bound. The theorem distinguishes possible ongoing extension in an abstract state space from a particular bounded agent's execution.

## Reproduction and trust boundary

For the standalone development, install the toolchain in `lean-toolchain`, put `lean` on PATH, and run:

```sh
python3 verify_unveiling.py
python3 audit_unveiling.py
```

The first gate compiles the entire source with warnings treated as errors, inventories every theorem, and prints each theorem's type and transitive axiom dependencies. It rejects incomplete proofs, extra global axioms and native-decision proof escapes. Only the standard Lean axioms `propext`, `Classical.choice` and `Quot.sound` are allowed. Structure fields remain visible mathematical hypotheses.

The certificate is written to `verification/unveiling/summary.json`; it includes the source SHA-256 values and the CI commit when run in GitHub Actions. The full assumption report is in `verification/unveiling/axioms.log`. A failed run removes any old success summary before checking.

The finite audit independently enumerates all sound information-set families over all truth predicates on four facts. It also checks the awareness example and bounded samples of the access and projection models. Those tests supplement the general Lean proofs.

The full repository bridge uses the original commands documented in README.md:

```sh
lake exe cache get Mathlib.Logic.Relation Mathlib.Data.Int.Basic Mathlib.Tactic.Basic Mathlib.NumberTheory.LSeries.RiemannZeta Mathlib.Order.CompleteLattice.Defs Mathlib.Topology.Compactness.Compact Mathlib.CategoryTheory.Category.Preorder Mathlib.CategoryTheory.Limits.Shapes.IsTerminal
python3 verify.py
```

Run both verification scripts: the legacy script audits the Neoplatonic namespace and the new script audits the standalone Unveiling namespace. CI runs both workflows.

The scope of machine checking is derivability and the explicitly constructed model facts. The interpretation of a source, the identification of divine assistance with an access relation, and claims about particular mystical experiences remain outside the formal proof.

## Sources and next formal interfaces

* The prior research note supplied in this conversation motivates the definitions and questions.
* The existing `Neoplatonic/Core.lean` provides the grounding interface and unique-first-principle theorem.
* Halpern and Rego, *Reasoning about Knowledge of Unawareness*, provides the motivating awareness distinction: https://arxiv.org/abs/cs/0603020.
* FormalizedFormalLogic/Foundation provides an independently maintained arithmetic and incompleteness library: https://github.com/FormalizedFormalLogic/Foundation.
* Rijke, Shulman and Spitters, *Modalities in Homotopy Type Theory*, is relevant to a future geometric implementation: https://arxiv.org/abs/1706.07526.

The arithmetic integration task is to instantiate the presentation and reflection interfaces for a pinned Foundation theory. A geometric integration needs a genuine truncation tower and an explicitly specified comparison with the proof-theoretic progression.
