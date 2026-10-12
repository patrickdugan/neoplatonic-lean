import Neoplatonic.Structure
import Mathlib.Order.CompleteLattice.Defs
import Mathlib.Order.RelClasses

/-! Reachability is a partial order under well-foundedness. Order-theoretic
    bottom assumptions are explicitly separated from proofs of existence. -/

namespace Neoplatonic
universe u

theorem reach_antisymm {α : Type u} {r : α → α → Prop}
    (wf : WellFounded r) {x y : α} (hxy : Reach r x y) (hyx : Reach r y x) :
    x = y := by
  rcases Relation.reflTransGen_iff_eq_or_transGen.mp
    (reach_iff_reflTransGen.mp hxy) with eq | hxy'
  · exact eq.symm
  rcases Relation.reflTransGen_iff_eq_or_transGen.mp
    (reach_iff_reflTransGen.mp hyx) with eq | hyx'
  · exact eq
  exact False.elim (wf.transGen.asymmetric x y hxy' hyx')

/-- The reachability order. This does not assume a bottom element. -/
def groundingPartialOrder {α : Type u} (r : α → α → Prop)
    (wf : WellFounded r) : PartialOrder α where
  le := Reach r
  le_refl := Reach.refl
  le_trans := fun _ _ _ => reach_trans
  le_antisymm := fun _ _ => reach_antisymm wf

theorem reach_lt_iff_le {α : Type u} [PartialOrder α] {x y : α} :
    Reach (fun a b : α => a < b) x y ↔ x ≤ y := by
  constructor
  · intro h
    induction h with
    | refl => exact le_refl _
    | step _ edge ih => exact le_trans ih (le_of_lt edge)
  · intro h
    by_cases eq : x = y
    · subst y
      exact .refl x
    · exact .step (.refl x) (lt_of_le_of_ne h eq)

/-- In an order with all strict comparisons as edges, the target is exactly
    a least element. This statement does not require well-foundedness. -/
theorem first_principle_iff_least {α : Type u} [PartialOrder α] (g : α) :
    FirstPrinciple (fun a b : α => a < b) g ↔ ∀ x, g ≤ x := by
  constructor
  · intro h x
    exact reach_lt_iff_le.mp (h.2 x)
  · intro h
    constructor
    · rintro ⟨y, hy⟩
      exact (not_lt_of_ge (h y)) hy
    · intro x
      exact reach_lt_iff_le.mpr (h x)

/-- OrderBot already provides the desired least point as structure data. -/
theorem order_bot_first_principle {α : Type u} [PartialOrder α] [OrderBot α] :
    ∃! g : α, FirstPrinciple (fun a b => a < b) g := by
  refine ⟨⊥, (first_principle_iff_least _).mpr (fun _ => bot_le), ?_⟩
  intro g hg
  exact le_antisymm ((first_principle_iff_least g).mp hg ⊥) bot_le

/-- Complete lattices include bottom in their axioms; this is not an
    independent derivation of its existence from completeness of nature. -/
theorem complete_lattice_first_principle {α : Type u} [CompleteLattice α] :
    ∃! g : α, FirstPrinciple (fun a b => a < b) g :=
  order_bot_first_principle

/-- Binary meets give lower directedness; termination then supplies bottom. -/
theorem meet_well_founded_first_principle {α : Type u} [SemilatticeInf α]
    (wf : WellFounded (fun a b : α => a < b)) (seed : α) :
    ∃! g : α, FirstPrinciple (fun a b => a < b) g := by
  let theory : GroundTheory α := {
    prior := fun a b => a < b
    wf := wf
    commonPrior := fun x y =>
      ⟨x ⊓ y, reach_lt_iff_le.mpr inf_le_left, reach_lt_iff_le.mpr inf_le_right⟩
  }
  exact unique_first_principle theory seed

end Neoplatonic
