import Neoplatonic.Amalgamation

/-!
# A concrete countermodel for the amalgamation theorem

All objects have a common effect, and the dependency relation is
well-founded. Yet two distinct roots feed one merger. This shows
why a no-independent-merging premise is indispensable in the
alternative derivation.
-/

namespace Neoplatonic

inductive MergeNode where
  | left | right | apex
  deriving DecidableEq

inductive MergePrior : MergeNode → MergeNode → Prop where
  | fromLeft : MergePrior .left .apex
  | fromRight : MergePrior .right .apex

theorem merge_left_root : Root MergePrior .left := by
  rintro ⟨x, hx⟩
  cases hx

theorem merge_right_root : Root MergePrior .right := by
  rintro ⟨x, hx⟩
  cases hx

theorem merge_well_founded : WellFounded MergePrior := by
  refine ⟨?_⟩
  intro x
  cases x with
  | left =>
      apply Acc.intro
      intro y hy
      cases hy
  | right =>
      apply Acc.intro
      intro y hy
      cases hy
  | apex =>
      apply Acc.intro
      intro y hy
      cases hy with
      | fromLeft =>
          apply Acc.intro
          intro z hz
          cases hz
      | fromRight =>
          apply Acc.intro
          intro z hz
          cases hz

theorem merge_reaches_apex (x : MergeNode) : Reach MergePrior x .apex := by
  cases x with
  | left => exact Reach.step (Reach.refl _) MergePrior.fromLeft
  | right => exact Reach.step (Reach.refl _) MergePrior.fromRight
  | apex => exact Reach.refl _

theorem merge_common_effect (x y : MergeNode) :
    ∃ z : MergeNode, Reach MergePrior x z ∧ Reach MergePrior y z :=
  ⟨.apex, merge_reaches_apex x, merge_reaches_apex y⟩

/-- The two roots cannot both be upstream of each other. -/
theorem merge_no_universal_one :
    ¬ ∃ g : MergeNode, FirstPrinciple MergePrior g := by
  rintro ⟨g, hg⟩
  have hl : g = .left :=
    ancestor_of_root_eq merge_left_root (hg.2 .left)
  have hr : g = .right :=
    ancestor_of_root_eq merge_right_root (hg.2 .right)
  have absurd : MergeNode.left = .right := hl.symm.trans hr
  cases absurd

/-- Explicit failure of the unique-immediate-parent premise. -/
theorem merge_not_single_parent :
    ¬ (∀ x y z : MergeNode, MergePrior x z → MergePrior y z → x = y) := by
  intro h
  have absurd : MergeNode.left = .right :=
    h .left .right .apex MergePrior.fromLeft MergePrior.fromRight
  cases absurd

end Neoplatonic
