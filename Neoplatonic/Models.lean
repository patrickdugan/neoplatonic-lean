import Neoplatonic.Core

/-!
# Countermodel and premise audit

With infinitely many abstract beings and no grounding edges,
well-foundedness holds, but there are multiple first-level beings.
This refutes any claim that arithmetic infinitude plus well-foundedness
alone imply a unique One.
-/

namespace Neoplatonic

/-- The empty relation on the natural numbers. -/
def emptyPrior : ℕ → ℕ → Prop := fun _ _ => False

theorem empty_prior_well_founded : WellFounded emptyPrior := by
  refine ⟨?_⟩
  intro x
  apply Acc.intro
  intro y h
  exact False.elim h

theorem every_nat_is_root_of_empty_prior (n : ℕ) : Root emptyPrior n := by
  rintro ⟨y, h⟩
  exact h

/-- Unity fails in a perfectly good, infinitely populated,
    well-founded model. -/
theorem empty_prior_lacks_common_origin :
    ¬ (∀ x y : ℕ, ∃ z : ℕ,
      Reach emptyPrior z x ∧ Reach emptyPrior z y) := by
  intro hcommon
  obtain ⟨z, hz0, hz1⟩ := hcommon 0 1
  have h0 : z = 0 :=
    ancestor_of_root_eq (every_nat_is_root_of_empty_prior 0) hz0
  have h1 : z = 1 :=
    ancestor_of_root_eq (every_nat_is_root_of_empty_prior 1) hz1
  have absurd_eq : (0 : ℕ) = 1 := h0.symm.trans h1
  cases absurd_eq

end Neoplatonic
