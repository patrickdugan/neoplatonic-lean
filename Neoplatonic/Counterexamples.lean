import Neoplatonic.Orders
import Neoplatonic.MergeModel
import Neoplatonic.Models

/-! Premise separation, including strict weakening of common effects. -/
namespace Neoplatonic

theorem merge_not_locally_coherent : ¬ LocallyCoherent MergePrior := by
  intro lc
  obtain ⟨w, hwl, hwr⟩ := lc .left .right .apex .fromLeft .fromRight
  have hl := ancestor_of_root_eq merge_left_root hwl
  have hr := ancestor_of_root_eq merge_right_root hwr
  have impossible : MergeNode.left = .right := hl.symm.trans hr
  cases impossible

theorem merge_connected_counterexample :
    WellFounded MergePrior ∧ CommonEffects MergePrior ∧ Connected MergePrior ∧
    ¬ ∃ g, FirstPrinciple MergePrior g :=
  ⟨merge_well_founded, merge_common_effect,
    common_effects_connected merge_common_effect, merge_no_universal_one⟩

theorem empty_prior_local_counterexample :
    WellFounded emptyPrior ∧ LocallyCoherent emptyPrior ∧
    ¬ ∃ g : ℕ, FirstPrinciple emptyPrior g := by
  refine ⟨empty_prior_well_founded, ?_, ?_⟩
  · intro x y z hx
    exact False.elim hx
  · rintro ⟨g, hg⟩
    apply empty_prior_lacks_common_origin
    intro x y
    exact ⟨g, hg.2 x, hg.2 y⟩

theorem integers_not_well_founded :
    ¬ WellFounded (fun x y : ℤ => x < y) := by
  intro wf
  exact integers_have_no_root (exists_root _ wf 0)

/-- Acyclicity and connectedness cannot replace termination on infinite domains. -/
theorem integers_local_directed_without_root :
    LocallyCoherent (fun x y : ℤ => x < y) ∧
    CommonEffects (fun x y : ℤ => x < y) ∧
    Connected (fun x y : ℤ => x < y) ∧
    ¬ ∃ g : ℤ, FirstPrinciple (fun x y => x < y) g := by
  have ce : CommonEffects (fun x y : ℤ => x < y) := by
    intro x y
    exact ⟨max x y, reach_lt_iff_le.mpr (le_max_left _ _),
      reach_lt_iff_le.mpr (le_max_right _ _)⟩
  refine ⟨?_, ce, common_effects_connected ce, ?_⟩
  · intro x y z _ _
    exact ⟨min x y, reach_lt_iff_le.mpr (min_le_left _ _),
      reach_lt_iff_le.mpr (min_le_right _ _)⟩
  · rintro ⟨g, hg⟩
    exact integers_have_no_root ⟨g, hg.1⟩

def ForkPrior (x y : MergeNode) : Prop := MergePrior y x

theorem fork_reach_reverse {x y : MergeNode} :
    Reach ForkPrior x y ↔ Reach MergePrior y x := by
  exact reach_iff_reflTransGen.trans reverse_reach_iff

theorem fork_apex_first_principle : FirstPrinciple ForkPrior .apex := by
  constructor
  · rintro ⟨x, hx⟩
    cases hx
  · intro x
    exact fork_reach_reverse.mpr (merge_reaches_apex x)

theorem fork_well_founded : WellFounded ForkPrior := by
  let rank : MergeNode → ℕ := fun x => match x with
    | .apex => 0
    | .left | .right => 1
  have sub : Subrelation ForkPrior (fun x y => rank x < rank y) := by
    intro x y h
    cases h <;> decide
  exact Subrelation.wf sub (InvImage.wf rank Nat.lt_wfRel.wf)

/-- The connected theorem is a strict strengthening: this model has no
    common effect for its two terminal branches. -/
theorem fork_connected_not_common_effects :
    WellFounded ForkPrior ∧ LocallyCoherent ForkPrior ∧ Connected ForkPrior ∧
    ¬ CommonEffects ForkPrior := by
  have fp : ∃! g, FirstPrinciple ForkPrior g := by
    refine ⟨.apex, fork_apex_first_principle, ?_⟩
    intro g hg
    exact (ancestor_of_root_eq hg.1 (fork_apex_first_principle.2 g)).symm
  have props := (local_connected_iff_first_principle ForkPrior fork_well_founded
    MergeNode.apex).mpr fp
  refine ⟨fork_well_founded, props.1, props.2, ?_⟩
  intro ce
  obtain ⟨z, hl, hr⟩ := ce .left .right
  have zl := ancestor_of_root_eq merge_left_root (fork_reach_reverse.mp hl)
  have zr := ancestor_of_root_eq merge_right_root (fork_reach_reverse.mp hr)
  have impossible : MergeNode.left = .right := zl.symm.trans zr
  cases impossible

end Neoplatonic
