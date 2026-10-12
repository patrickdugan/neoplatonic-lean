import Mathlib.Logic.Relation
import Mathlib.Data.Int.Basic
import Mathlib.Tactic.Basic

/-!
# A Neoplatonic first-principle theorem

This theorem is conditional on two explicit metaphysical assumptions:
(1) ontological priority is well-founded, and
(2) any two beings admit a common predecessor (possibly themselves).

`FirstPrinciple` means ungrounded and ancestrally prior to all beings.
It does not formalize consciousness, will, goodness, or the God of a religion.

No `sorry` or theorem-level `axiom` declarations are used.
The assumptions are fields of `GroundTheory`.
-/

namespace Neoplatonic

universe u

/-- Reflexive-transitive reachability along ontological-priority edges. -/
inductive Reach {α : Type u} (prior : α → α → Prop) : α → α → Prop where
  | refl (x : α) : Reach prior x x
  | step {x y z : α} : Reach prior x y → prior y z → Reach prior x z

/-- A being has no ontological predecessor. -/
def Root {α : Type u} (prior : α → α → Prop) (x : α) : Prop :=
  ¬ ∃ y : α, prior y x

/-- The minimal formal target: an ungrounded source of everything in the domain. -/
def FirstPrinciple {α : Type u} (prior : α → α → Prop) (x : α) : Prop :=
  Root prior x ∧ ∀ y : α, Reach prior x y

/-- Nothing distinct can be an ancestor of an ungrounded being. -/
theorem ancestor_of_root_eq {α : Type u}
    {prior : α → α → Prop} {x y : α}
    (hy : Root prior y) (h : Reach prior x y) : x = y := by
  cases h with
  | refl => rfl
  | step _ hlast =>
      exact False.elim (hy ⟨_, hlast⟩)

/-- Every entity in a well-founded priority system has a root ancestor.
    For this first lemma, we only need existence of *some* root. -/
theorem exists_root {α : Type u}
    (prior : α → α → Prop) (wf : WellFounded prior) (seed : α) :
    ∃ root : α, Root prior root := by
  classical
  have go : ∀ x : α, Acc prior x → ∃ root : α, Root prior root := by
    intro x hx
    induction hx with
    | intro x previous ih =>
        by_cases h : ∃ y : α, prior y x
        · obtain ⟨y, hy⟩ := h
          exact ih y hy
        · exact ⟨x, h⟩
  exact go seed (wf.apply seed)

/-- The two substantive Neoplatonic bridge assumptions.
    `commonPrior` allows reflexive reachability: the common ancestor
    of x and y may be one of the endpoints. -/
structure GroundTheory (α : Type u) where
  prior : α → α → Prop
  wf : WellFounded prior
  commonPrior : ∀ x y : α,
    ∃ z : α, Reach prior z x ∧ Reach prior z y

/-- Conditional unicity and universal reachability of the One. -/
theorem unique_first_principle {α : Type u}
    (theory : GroundTheory α) (seed : α) :
    ∃! x : α, FirstPrinciple theory.prior x := by
  obtain ⟨root, hroot⟩ := exists_root theory.prior theory.wf seed
  have all : ∀ y : α, Reach theory.prior root y := by
    intro y
    obtain ⟨ancestor, htoRoot, htoY⟩ := theory.commonPrior root y
    have ha : ancestor = root := ancestor_of_root_eq hroot htoRoot
    simpa [ha] using htoY
  refine ⟨root, ⟨hroot, all⟩, ?_⟩
  intro y hy
  exact (ancestor_of_root_eq hy.1 (all y)).symm

/-- Alternative bridge: ontological priority is a strict, total comparison.
    This is mathematically stronger than the common-ancestor condition but
    philosophically easier to compare with a number line. -/
structure LinearGroundTheory (α : Type u) where
  prior : α → α → Prop
  wf : WellFounded prior
  comparable : ∀ x y : α, x = y ∨ prior x y ∨ prior y x

/-- Total comparability supplies a common ancestor for any two beings. -/
def LinearGroundTheory.toGroundTheory {α : Type u}
    (theory : LinearGroundTheory α) : GroundTheory α where
  prior := theory.prior
  wf := theory.wf
  commonPrior := by
    intro x y
    rcases theory.comparable x y with hEq | hXY | hYX
    · subst y
      exact ⟨x, Reach.refl x, Reach.refl x⟩
    · exact ⟨x, Reach.refl x, Reach.step (Reach.refl x) hXY⟩
    · exact ⟨y, Reach.step (Reach.refl y) hYX, Reach.refl y⟩

/-- Well-founded *linear* explanatory order entails a unique One. -/
theorem linear_unique_first_principle {α : Type u}
    (theory : LinearGroundTheory α) (seed : α) :
    ∃! x : α, FirstPrinciple theory.prior x :=
  unique_first_principle theory.toGroundTheory seed

/-- The natural number line exhibits limitless successive multiplicity. -/
theorem nat_unbounded_above (n : ℕ) : ∃ m : ℕ, n < m :=
  ⟨n + 1, Nat.lt_succ_self n⟩

/-- Every natural has 0 as its ancestor under the strict order. -/
theorem nat_reachable_from_zero (n : ℕ) :
    Reach (fun a b : ℕ => a < b) 0 n := by
  cases n with
  | zero => exact Reach.refl 0
  | succ k =>
      exact Reach.step (Reach.refl 0) (Nat.zero_lt_succ k)

/-- A completely mathematical model satisfying the first-principle axioms.
    Here the 'first principle' is literally the number zero. -/
def natTheory : GroundTheory ℕ where
  prior := fun a b => a < b
  wf := Nat.lt_wfRel.wf
  commonPrior := by
    intro a b
    exact ⟨0, nat_reachable_from_zero a, nat_reachable_from_zero b⟩

theorem zero_is_unique_first_principle :
    ∃! x : ℕ, FirstPrinciple natTheory.prior x :=
  unique_first_principle natTheory 0

/-- In contrast, the entire integer line has no first element. -/
theorem integers_have_no_root :
    ¬ ∃ z : ℤ, Root (fun x y : ℤ => x < y) z := by
  rintro ⟨z, hz⟩
  apply hz
  refine ⟨z - 1, ?_⟩
  omega

end Neoplatonic
