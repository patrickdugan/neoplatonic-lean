import Neoplatonic.Core

/-!
# A symmetry obstruction to distinguishing the One

Suppose a unary predicate P selects a unique element of a domain.
Any transformation that preserves P must fix that element.
Integer translation n |-> n+1 has no fixed points, so an invariant
predicate cannot select a unique integer. This obstruction is independent
of any arithmetic conjecture, including RH.
-/

namespace Neoplatonic

universe u

/-- Any endomorphism preserving a uniquely realized predicate fixes
    its unique witness. This is the underlying symmetry argument. -/
theorem unique_witness_fixed {α : Type u}
    (P : α → Prop) (f : α → α)
    (invariant : ∀ x, P x → P (f x))
    (unique : ∃! x : α, P x) :
    ∃ x : α, P x ∧ f x = x := by
  obtain ⟨x, hx, hunique⟩ := unique
  exact ⟨x, hx, hunique (f x) (invariant x hx)⟩

/-- No translation-invariant predicate distinguishes exactly one
    point of the integer line. -/
theorem no_translation_invariant_integer_one
    (P : ℤ → Prop)
    (translationInvariant : ∀ n : ℤ, P n → P (n + 1)) :
    ¬ ∃! n : ℤ, P n := by
  intro hunique
  obtain ⟨n, hn, hfix⟩ :=
    unique_witness_fixed P (fun n : ℤ => n + 1) translationInvariant hunique
  omega

/-- A completely translation-invariant mathematical property can
    certainly hold at multiple positions. -/
theorem all_integers_indistinguishable :
    (∀ n : ℤ, True → True) ∧ ¬ ∃! n : ℤ, True := by
  constructor
  · intro _ _
    trivial
  · exact no_translation_invariant_integer_one
      (fun _ : ℤ => True) (by intro _ _; trivial)

/-- Positive example: the natural number line has a distinguished zero
    because restricting the order to naturals breaks translation symmetry. -/
theorem natural_origin_fixed :
    ∃! n : ℕ, n = 0 := by
  exact ⟨0, rfl, by intro n hn; exact hn⟩

end Neoplatonic
