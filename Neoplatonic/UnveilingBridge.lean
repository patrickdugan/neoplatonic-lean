import Neoplatonic.Core
import Unveiling

/-!
# Bridge from the existing grounding theorem to disclosure countermodels

The source/mediator/learner ontology satisfies the repository's actual
GroundTheory interface. Both disclosure policies use that same ontology.
-/
namespace Neoplatonic

theorem unveiling_source_reaches (b : Unveiling.Being) :
    Reach Unveiling.Grounds Unveiling.Being.source b := by
  cases b with
  | source => exact Reach.refl _
  | mediator =>
    exact Reach.step (Reach.refl _) Unveiling.mediator_is_grounded
  | learner n =>
    exact Reach.step
      (Reach.step (Reach.refl _) Unveiling.mediator_is_grounded)
      (Unveiling.learner_is_mediated n)

def unveilingGroundTheory : GroundTheory Unveiling.Being where
  prior := Unveiling.Grounds
  wf := Unveiling.grounding_wellFounded
  commonPrior := fun a b =>
    ⟨Unveiling.Being.source, unveiling_source_reaches a, unveiling_source_reaches b⟩

theorem unveiling_source_first_principle :
    FirstPrinciple unveilingGroundTheory.prior Unveiling.Being.source :=
  ⟨Unveiling.source_ungrounded, unveiling_source_reaches⟩

theorem unveiling_unique_first_principle :
    ∃! x : Unveiling.Being, FirstPrinciple unveilingGroundTheory.prior x :=
  unique_first_principle unveilingGroundTheory Unveiling.Being.source

theorem unveiling_capped_terminal_reachable_from_zero (cap : Nat) :
    Reach (Unveiling.CappedAccess cap) 0 cap ∧
    Unveiling.Terminal Unveiling.PrefixKnowledge (Unveiling.CappedAccess cap) cap := by
  constructor
  · cases cap with
    | zero => exact Reach.refl 0
    | succ n => exact Reach.step (Reach.refl 0)
        ⟨Nat.zero_lt_succ n, Nat.le_refl (n + 1)⟩
  · exact (Unveiling.capped_terminal_iff cap cap).mpr (Nat.le_refl cap)

theorem unveiling_first_principle_does_not_determine_termination (cap : Nat) :
    (∃! x : Unveiling.Being, FirstPrinciple unveilingGroundTheory.prior x) ∧
    (Reach (Unveiling.CappedAccess cap) 0 cap ∧
      Unveiling.Terminal Unveiling.PrefixKnowledge (Unveiling.CappedAccess cap) cap) ∧
    (∀ s, ¬ Unveiling.Terminal Unveiling.PrefixKnowledge Unveiling.OpenAccess s) :=
  ⟨unveiling_unique_first_principle,
    unveiling_capped_terminal_reachable_from_zero cap, Unveiling.open_no_terminal⟩

end Neoplatonic
