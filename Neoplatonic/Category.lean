import Neoplatonic.Orders
import Mathlib.CategoryTheory.Category.Preorder
import Mathlib.CategoryTheory.Limits.Shapes.IsTerminal

/-! The initial-object interpretation is exact for the thin reachability
    category. No claim about existence in arbitrary categories is assumed. -/
namespace Neoplatonic
universe u

/-- In a thin category from a partial order, initiality is leastness. -/
theorem least_iff_initial {α : Type u} [PartialOrder α] (g : α) :
    (∀ x : α, g ≤ x) ↔ Nonempty (CategoryTheory.Limits.IsInitial g) := by
  constructor
  · intro least
    exact ⟨CategoryTheory.Limits.IsInitial.ofUniqueHom
      (fun x => CategoryTheory.homOfLE (least x))
      (fun _ _ => Subsingleton.elim _ _)⟩
  · rintro ⟨initial⟩ x
    exact CategoryTheory.leOfHom (initial.to x)

theorem first_principle_iff_initial {α : Type u} [PartialOrder α] (g : α) :
    FirstPrinciple (fun a b : α => a < b) g ↔
    Nonempty (CategoryTheory.Limits.IsInitial g) :=
  (first_principle_iff_least g).trans (least_iff_initial g)

/-- For the reachability order of well-founded grounding, initiality
    is exactly the original target. The local instance exposes the order. -/
theorem grounding_first_principle_iff_initial {α : Type u}
    (r : α → α → Prop) (wf : WellFounded r) (g : α) :
    letI : PartialOrder α := groundingPartialOrder r wf
    FirstPrinciple r g ↔ Nonempty (CategoryTheory.Limits.IsInitial g) := by
  letI : PartialOrder α := groundingPartialOrder r wf
  constructor
  · intro hg
    exact (least_iff_initial g).mp hg.2
  · intro hi
    have least : ∀ x : α, Reach r g x := (least_iff_initial g).mpr hi
    refine ⟨?_, least⟩
    rintro ⟨y, edge⟩
    have eq := reach_antisymm wf (least y) (Reach.step (Reach.refl y) edge)
    subst y
    exact wf.asymmetric g g edge edge

end Neoplatonic
