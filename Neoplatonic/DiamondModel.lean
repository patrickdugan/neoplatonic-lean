import Neoplatonic.Structure

/-! A genuine branching/merging model with no transitively redundant edges.
    Unlike the supplied three-node triangle, these edges can be covers. -/

namespace Neoplatonic

inductive DiamondNode where
  | origin | left | right | apex
  deriving DecidableEq

inductive DiamondPrior : DiamondNode → DiamondNode → Prop where
  | originLeft : DiamondPrior .origin .left
  | originRight : DiamondPrior .origin .right
  | leftApex : DiamondPrior .left .apex
  | rightApex : DiamondPrior .right .apex

def diamondRank : DiamondNode → ℕ
  | .origin => 0
  | .left | .right => 1
  | .apex => 2

theorem diamond_edge_rank {x y : DiamondNode} (h : DiamondPrior x y) :
    diamondRank y = diamondRank x + 1 := by
  cases h <;> rfl

theorem diamond_well_founded : WellFounded DiamondPrior := by
  have sub : Subrelation DiamondPrior (fun x y => diamondRank x < diamondRank y) := by
    intro x y h
    cases h <;> decide
  exact Subrelation.wf sub (InvImage.wf diamondRank Nat.lt_wfRel.wf)

theorem diamond_origin_reaches (x : DiamondNode) : Reach DiamondPrior .origin x := by
  cases x with
  | origin => exact .refl _
  | left => exact .step (.refl _) .originLeft
  | right => exact .step (.refl _) .originRight
  | apex => exact .step (.step (.refl _) .originLeft) .leftApex

theorem diamond_reaches_apex (x : DiamondNode) : Reach DiamondPrior x .apex := by
  cases x with
  | origin => exact .step (.step (.refl _) .originLeft) .leftApex
  | left => exact .step (.refl _) .leftApex
  | right => exact .step (.refl _) .rightApex
  | apex => exact .refl _

def diamondTheory : ConfluentGroundTheory DiamondNode where
  prior := DiamondPrior
  wf := diamond_well_founded
  commonEffect := fun x y => ⟨.apex, diamond_reaches_apex x, diamond_reaches_apex y⟩
  localCoherence := fun x y _ _ _ => ⟨.origin, diamond_origin_reaches x, diamond_origin_reaches y⟩

theorem diamond_unique_first_principle : ∃! g, FirstPrinciple DiamondPrior g :=
  confluent_unique_first_principle diamondTheory .origin

theorem diamond_not_single_parent :
    ¬ (∀ x y z, DiamondPrior x z → DiamondPrior y z → x = y) := by
  intro h
  have impossible := h .left .right .apex .leftApex .rightApex
  cases impossible

theorem diamond_rank_increases {x y : DiamondNode} (h : Reach DiamondPrior x y) :
    x = y ∨ diamondRank x < diamondRank y := by
  induction h with
  | refl => exact Or.inl rfl
  | @step y z _ edge ih =>
    right
    have stepRank := diamond_edge_rank edge
    rcases ih with eq | lt
    · subst y
      omega
    · omega

/-- Each edge is a cover of reachability: no distinct intermediate node. -/
theorem diamond_edges_are_covers {x y : DiamondNode} (edge : DiamondPrior x y) :
    ¬ ∃ z, Reach DiamondPrior x z ∧ Reach DiamondPrior z y ∧ x ≠ z ∧ z ≠ y := by
  rintro ⟨z, hxz, hzy, hne, hne'⟩
  have hx := (diamond_rank_increases hxz).resolve_left hne
  have hy := (diamond_rank_increases hzy).resolve_left hne'
  have stepRank := diamond_edge_rank edge
  omega

end Neoplatonic
