import Neoplatonic.LocalConfluence

/-!
# A non-linear model of the local-confluence axioms

 origin ----> branch
    \           |
     \          v
      --------> apex

The node `apex` has TWO distinct immediate grounds (`origin` and
`branch`). The model therefore satisfies local coherence while
violating the rigid single-parent premise of Amalgamation.lean.
-/

namespace Neoplatonic

inductive CoherentNode where
  | origin | branch | apex
  deriving DecidableEq

inductive CoherentPrior : CoherentNode → CoherentNode → Prop where
  | toBranch : CoherentPrior .origin .branch
  | toApex : CoherentPrior .origin .apex
  | branchToApex : CoherentPrior .branch .apex

theorem coherent_well_founded : WellFounded CoherentPrior := by
  refine ⟨?_⟩
  intro x
  cases x with
  | origin =>
      apply Acc.intro
      intro y hy
      cases hy
  | branch =>
      apply Acc.intro
      intro y hy
      cases hy with
      | toBranch =>
          apply Acc.intro
          intro z hz
          cases hz
  | apex =>
      apply Acc.intro
      intro y hy
      cases hy with
      | toApex =>
          apply Acc.intro
          intro z hz
          cases hz
      | branchToApex =>
          apply Acc.intro
          intro z hz
          cases hz with
          | toBranch =>
              apply Acc.intro
              intro q hq
              cases hq

theorem origin_reaches (x : CoherentNode) :
    Reach CoherentPrior .origin x := by
  cases x with
  | origin => exact Reach.refl _
  | branch => exact Reach.step (Reach.refl _) CoherentPrior.toBranch
  | apex => exact Reach.step (Reach.refl _) CoherentPrior.toApex

theorem every_node_reaches_apex (x : CoherentNode) :
    Reach CoherentPrior x .apex := by
  cases x with
  | origin => exact Reach.step (Reach.refl _) CoherentPrior.toApex
  | branch => exact Reach.step (Reach.refl _) CoherentPrior.branchToApex
  | apex => exact Reach.refl _

def coherentTheory : ConfluentGroundTheory CoherentNode where
  prior := CoherentPrior
  wf := coherent_well_founded
  commonEffect := by
    intro x y
    exact ⟨.apex, every_node_reaches_apex x, every_node_reaches_apex y⟩
  localCoherence := by
    intro x y z hx hy
    exact ⟨.origin, origin_reaches x, origin_reaches y⟩

theorem coherent_unique_first_principle :
    ∃! g : CoherentNode, FirstPrinciple CoherentPrior g :=
  confluent_unique_first_principle coherentTheory .origin

theorem coherent_allows_multiple_parents :
    CoherentPrior .origin .apex ∧ CoherentPrior .branch .apex :=
  ⟨CoherentPrior.toApex, CoherentPrior.branchToApex⟩

end Neoplatonic
