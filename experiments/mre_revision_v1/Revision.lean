import MRE

/-!
# Nonvacuous endorsement and dependency-sensitive decision certificates

All normative adequacy assumptions remain theorem parameters. Context values
are abstract identifiers; no collision-resistance or production refinement is
proved. The Python implementation is tested separately.
-/
namespace MoralRevision

universe u v w

def Supported {T : Type u} {A : Type v}
    (candidates : T → Prop) (permits : T → A → Prop) (action : A) : Prop :=
  (∃ t, candidates t) ∧ MoralEpistemics.Robust candidates permits action

theorem empty_agreement_is_vacuous {T : Type u} {A : Type v}
    (permits : T → A → Prop) (action : A) :
    MoralEpistemics.Robust (fun _ : T => False) permits action := by
  intro _ h
  exact False.elim h

theorem empty_candidates_cannot_support {T : Type u} {A : Type v}
    (permits : T → A → Prop) (action : A) :
    ¬ Supported (fun _ : T => False) permits action := by
  rintro ⟨⟨_, h⟩, _⟩
  exact h

theorem supported_requires_candidate {T : Type u} {A : Type v}
    (candidates : T → Prop) (permits : T → A → Prop) (action : A)
    (h : Supported candidates permits action) : ∃ t, candidates t := h.1

/-- The substantive coverage assumption is that the correct interpretation is represented. -/
theorem supported_sound_given_coverage {T : Type u} {A : Type v}
    (candidates : T → Prop) (permits : T → A → Prop) (action : A)
    (correct : T) (coverage : candidates correct)
    (h : Supported candidates permits action) : permits correct action :=
  h.2 correct coverage

theorem nonempty_agreement_can_omit_correct_interpretation :
    Supported (fun t : Bool => t = true) (fun t (_ : Unit) => t = true) () ∧
    ¬ ((fun t : Bool => t = true) false) ∧
    ¬ ((fun t : Bool => fun _ : Unit => t = true) false ()) := by
  constructor
  · exact ⟨⟨true, rfl⟩, fun _ h => h⟩
  · constructor <;> intro h <;> cases h

theorem filtering_preserves_support_with_nonemptiness {T : Type u} {A : Type v}
    (old new : T → Prop) (permits : T → A → Prop) (action : A)
    (subset : ∀ t, new t → old t) (nonempty : ∃ t, new t)
    (supported : Supported old permits action) : Supported new permits action :=
  ⟨nonempty, MoralEpistemics.robustness_survives_candidate_filtering
    old new permits action subset supported.2⟩

/-- Edges point from a dependent claim toward a premise. -/
inductive Depends {F : Type u} (edge : F → F → Prop) : F → F → Prop where
  | direct {a b} : edge a b → Depends edge a b
  | trans {a b c} : Depends edge a b → Depends edge b c → Depends edge a c

def AfterRetraction {F : Type u} (active : F → Prop)
    (edge : F → F → Prop) (revoked : F) (fact : F) : Prop :=
  active fact ∧ fact ≠ revoked ∧ ¬ Depends edge fact revoked

theorem retraction_only_removes {F : Type u} (active : F → Prop)
    (edge : F → F → Prop) (revoked fact : F)
    (h : AfterRetraction active edge revoked fact) : active fact := h.1

theorem revoked_claim_inactive {F : Type u} (active : F → Prop)
    (edge : F → F → Prop) (revoked : F) :
    ¬ AfterRetraction active edge revoked revoked := by
  intro h
  exact h.2.1 rfl

theorem dependent_claim_inactive {F : Type u} (active : F → Prop)
    (edge : F → F → Prop) (revoked fact : F) (h : Depends edge fact revoked) :
    ¬ AfterRetraction active edge revoked fact := by
  intro kept
  exact kept.2.2 h

theorem transitive_dependent_inactive {F : Type u} (active : F → Prop)
    (edge : F → F → Prop) (revoked middle fact : F)
    (hm : Depends edge middle revoked) (hf : Depends edge fact middle) :
    ¬ AfterRetraction active edge revoked fact :=
  dependent_claim_inactive active edge revoked fact (Depends.trans hf hm)

theorem unrelated_claim_survives {F : Type u} (active : F → Prop)
    (edge : F → F → Prop) (revoked fact : F) (h : active fact)
    (hne : fact ≠ revoked) (hind : ¬ Depends edge fact revoked) :
    AfterRetraction active edge revoked fact := ⟨h, hne, hind⟩

structure Context where
  environment : Nat
  constitution : Nat
  grantEpoch : Nat

structure State (F : Type u) (A : Type v) where
  active : F → Prop
  grants : A → Prop
  context : Context

structure Certificate (F : Type u) (A : Type v) where
  action : A
  premises : F → Prop
  context : Context

def Valid {F : Type u} {A : Type v} (s : State F A) (c : Certificate F A) : Prop :=
  s.context = c.context ∧ ∀ p, c.premises p → s.active p

def Retract {F : Type u} {A : Type v}
    (s : State F A) (edge : F → F → Prop) (revoked : F) : State F A :=
  { s with active := AfterRetraction s.active edge revoked }

def Accepts {F : Type u} {A : Type v} {T : Type w}
    (s : State F A) (c : Certificate F A) (requested : A)
    (candidates : T → Prop) (permits : T → A → Prop) : Prop :=
  c.action = requested ∧ s.grants requested ∧ Valid s c ∧
  Supported candidates permits requested

theorem stale_context_invalid {F : Type u} {A : Type v}
    (s : State F A) (c : Certificate F A) (changed : s.context ≠ c.context) :
    ¬ Valid s c := fun h => changed h.1

theorem revoked_premise_invalidates {F : Type u} {A : Type v}
    (s : State F A) (c : Certificate F A) (edge : F → F → Prop)
    (p : F) (required : c.premises p) : ¬ Valid (Retract s edge p) c := by
  intro h
  exact revoked_claim_inactive s.active edge p (h.2 p required)

theorem dependent_premise_invalidates {F : Type u} {A : Type v}
    (s : State F A) (c : Certificate F A) (edge : F → F → Prop)
    (p d : F) (required : c.premises d) (hd : Depends edge d p) :
    ¬ Valid (Retract s edge p) c := by
  intro h
  exact dependent_claim_inactive s.active edge p d hd (h.2 d required)

theorem unrelated_retraction_preserves_certificate {F : Type u} {A : Type v}
    (s : State F A) (c : Certificate F A) (edge : F → F → Prop)
    (p : F) (valid : Valid s c)
    (separate : ∀ d, c.premises d → d ≠ p ∧ ¬ Depends edge d p) :
    Valid (Retract s edge p) c := by
  constructor
  · exact valid.1
  · intro d hd
    exact ⟨valid.2 d hd, (separate d hd).1, (separate d hd).2⟩

theorem retraction_preserves_authority {F : Type u} {A : Type v}
    (s : State F A) (edge : F → F → Prop) (p : F) :
    (Retract s edge p).grants = s.grants := rfl

theorem accepted_is_authorized {F : Type u} {A : Type v} {T : Type w}
    (s : State F A) (c : Certificate F A) (a : A)
    (candidates : T → Prop) (permits : T → A → Prop)
    (h : Accepts s c a candidates permits) : s.grants a := h.2.1

theorem accepted_is_justified_given_coverage {F : Type u} {A : Type v} {T : Type w}
    (s : State F A) (c : Certificate F A) (a : A)
    (candidates : T → Prop) (permits : T → A → Prop)
    (correct : T) (coverage : candidates correct)
    (h : Accepts s c a candidates permits) : permits correct a :=
  supported_sound_given_coverage candidates permits a correct coverage h.2.2.2

theorem wrong_action_binding_rejected {F : Type u} {A : Type v} {T : Type w}
    (s : State F A) (c : Certificate F A) (a : A)
    (candidates : T → Prop) (permits : T → A → Prop)
    (different : c.action ≠ a) : ¬ Accepts s c a candidates permits :=
  fun h => different h.1

end MoralRevision
