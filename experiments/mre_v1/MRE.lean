import Unveiling

/-!
# Epistemic revision and bounded action authority

This module checks abstract information/permission transitions. The grant
predicate is an externally supplied input. The theorem about missing truths
exposes soundness and the one-fact access condition as hypotheses. Refinement
of a deployed capability service to this model is a separate obligation.
-/

namespace MoralEpistemics

universe u v w

structure AgentState (Fact : Type u) (Action : Type v) where
  beliefs : Unveiling.KnowledgeSet Fact
  grants : Action → Prop

def revise {F : Type u} {A : Type v}
    (s : AgentState F A) (beliefs : Unveiling.KnowledgeSet F) : AgentState F A :=
  { s with beliefs := beliefs }

def CanExecute {F : Type u} {A : Type v}
    (s : AgentState F A) (action : A) : Prop := s.grants action

theorem revision_preserves_grants {F : Type u} {A : Type v}
    (s : AgentState F A) (beliefs : Unveiling.KnowledgeSet F) :
    (revise s beliefs).grants = s.grants := rfl

theorem revision_preserves_execution_condition {F : Type u} {A : Type v}
    (s : AgentState F A) (beliefs : Unveiling.KnowledgeSet F) (action : A) :
    CanExecute (revise s beliefs) action ↔ CanExecute s action := Iff.rfl

inductive RevisionPath {F : Type u} {A : Type v} :
    AgentState F A → AgentState F A → Prop where
  | refl (s) : RevisionPath s s
  | step {s t} (path : RevisionPath s t) (beliefs : Unveiling.KnowledgeSet F) :
      RevisionPath s (revise t beliefs)

theorem revision_path_preserves_grants {F : Type u} {A : Type v}
    {s t : AgentState F A} (path : RevisionPath s t) : t.grants = s.grants := by
  induction path with
  | refl => rfl
  | step _ _ ih => exact ih

theorem revision_path_cannot_authorize {F : Type u} {A : Type v}
    {s t : AgentState F A} (path : RevisionPath s t) (action : A)
    (denied : ¬ CanExecute s action) : ¬ CanExecute t action := by
  intro granted
  apply denied
  change t.grants action at granted
  change s.grants action
  rw [revision_path_preserves_grants path] at granted
  exact granted

/-- Semantic growth is compatible with fixed externally issued permissions. -/
theorem sound_growth_with_fixed_authority {F : Type u} {A : Type v}
    (truth : Unveiling.KnowledgeSet F)
    (allowed : Unveiling.KnowledgeSet F → Prop)
    (closed : Unveiling.OneFactClosed truth allowed)
    (s : AgentState F A) (admissible : allowed s.beliefs)
    (sound : Unveiling.Sound truth s.beliefs)
    (missing : Unveiling.Missing truth s.beliefs) :
    ∃ t : AgentState F A,
      allowed t.beliefs ∧ Unveiling.Sound truth t.beliefs ∧
      Unveiling.StrictlyIncluded s.beliefs t.beliefs ∧
      RevisionPath s t ∧ t.grants = s.grants := by
  obtain ⟨p, hp, hmissing⟩ := missing
  refine ⟨revise s (Unveiling.AddFact s.beliefs p), ?_, ?_, ?_, ?_, rfl⟩
  · exact closed s.beliefs admissible p hp
  · exact Unveiling.addFact_sound sound hp
  · exact Unveiling.addFact_strict hmissing
  · exact RevisionPath.step (RevisionPath.refl s) _

/-- A revision can withdraw a belief without erasing an external audit record. -/
theorem retraction_removes_current_belief {F : Type u} {A : Type v}
    (s : AgentState F A) (beliefs : Unveiling.KnowledgeSet F) (p : F)
    (retracted : ¬ beliefs p) : ¬ (revise s beliefs).beliefs p := retracted

structure ExecutionRequest (Action : Type v) where
  action : Action
  endorsed : Prop

def Accepted {F : Type u} {A : Type v}
    (s : AgentState F A) (r : ExecutionRequest A) : Prop :=
  r.endorsed ∧ s.grants r.action

theorem accepted_requires_grant {F : Type u} {A : Type v}
    (s : AgentState F A) (r : ExecutionRequest A)
    (accepted : Accepted s r) : s.grants r.action := accepted.2

theorem endorsement_cannot_override_denial {F : Type u} {A : Type v}
    (s : AgentState F A) (r : ExecutionRequest A)
    (denied : ¬ s.grants r.action) : ¬ Accepted s r := by
  intro accepted
  exact denied accepted.2

/-- Robustness means agreement across the explicitly represented candidates. -/
def Robust {Theory : Type w} {Action : Type v}
    (candidates : Theory → Prop) (permits : Theory → Action → Prop)
    (action : Action) : Prop :=
  ∀ theory, candidates theory → permits theory action

theorem robustness_survives_candidate_filtering {T : Type w} {A : Type v}
    (old new : T → Prop) (permits : T → A → Prop) (action : A)
    (subset : ∀ t, new t → old t) (robust : Robust old permits action) :
    Robust new permits action := by
  intro t ht
  exact robust t (subset t ht)

theorem expanded_robustness_implies_old {T : Type w} {A : Type v}
    (old new : T → Prop) (permits : T → A → Prop) (action : A)
    (superset : ∀ t, old t → new t) (robust : Robust new permits action) :
    Robust old permits action := by
  intro t ht
  exact robust t (superset t ht)

theorem candidate_expansion_can_withdraw_agreement :
    Robust (fun t : Bool => t = true) (fun t (_ : Unit) => t = true) () ∧
    ¬ Robust (fun _ : Bool => True) (fun t (_ : Unit) => t = true) () := by
  constructor
  · intro t ht
    exact ht
  · intro h
    have impossible : false = true := h false True.intro
    cases impossible

/-- The complete fact set places no constraint on an independently chosen act. -/
theorem complete_information_and_bad_action_coexist :
    ∃ (knowledge : Unveiling.KnowledgeSet Nat) (action : Bool),
      Unveiling.Sound (fun _ => True) knowledge ∧
      Unveiling.Complete (fun _ => True) knowledge ∧ action ≠ true := by
  refine ⟨(fun _ => True), false, ?_, ?_, ?_⟩
  · intro _ h
    exact h
  · intro _ h
    exact h
  · decide

end MoralEpistemics
