import Revision

namespace MoralRevision

universe u v w

/-- Identical evidence cannot support an always-correct deterministic answer when
    the required actions differ. An inquiry must change the available evidence. -/
theorem identical_observations_obstruct_perfect_policy
    {World : Type u} {Observation : Type v} {Action : Type w}
    (observe : World → Observation) (policy : Observation → Action)
    (required : World → Action) (left right : World)
    (same : observe left = observe right)
    (different : required left ≠ required right) :
    ¬ (policy (observe left) = required left ∧
      policy (observe right) = required right) := by
  intro h
  apply different
  calc
    required left = policy (observe left) := h.1.symm
    _ = policy (observe right) := congrArg policy same
    _ = required right := h.2

/-- The hidden bit becomes distinguishable after an informative query. -/
theorem informative_query_can_resolve_hidden_case :
    (∀ b : Bool, (fun observation : Bool => observation) b = b) ∧
    ¬ (∃ answer : Bool, ∀ b : Bool, answer = b) := by
  constructor
  · intro _
    rfl
  · rintro ⟨answer, h⟩
    have impossible : false = true := (h false).symm.trans (h true)
    cases impossible

end MoralRevision
