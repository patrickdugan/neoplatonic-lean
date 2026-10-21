import Lean

/-!
# Tower of unveiling

A dependency-light formal core for the October 2026 research note.
All hypotheses are explicit arguments or structure fields. Information sets
are not implicitly deductively closed theories. The arithmetic connection
is an interface to the derivability conditions and diagonal lemma; no
arithmetization of Peano arithmetic is claimed here. Binary projections
provide an inverse-limit example, not a construction in homotopy type theory.
-/

namespace Unveiling
universe u v

abbrev KnowledgeSet (F : Type u) := F → Prop

def Included {F : Type u} (a b : KnowledgeSet F) : Prop := ∀ p, a p → b p

def StrictlyIncluded {F : Type u} (a b : KnowledgeSet F) : Prop :=
  Included a b ∧ ∃ p, b p ∧ ¬ a p

def Complete {F : Type u} (truth a : KnowledgeSet F) : Prop := Included truth a

def Sound {F : Type u} (truth a : KnowledgeSet F) : Prop := Included a truth

def Missing {F : Type u} (truth a : KnowledgeSet F) : Prop := ∃ p, truth p ∧ ¬ a p

def AddFact {F : Type u} (a : KnowledgeSet F) (p : F) : KnowledgeSet F :=
  fun q => a q ∨ q = p

def MaximalIn {F : Type u} (allowed : KnowledgeSet F → Prop)
    (a : KnowledgeSet F) : Prop := ¬ ∃ b, allowed b ∧ StrictlyIncluded a b

/-- Every true one-fact enlargement of an admissible state is admissible. -/
def OneFactClosed {F : Type u} (truth : KnowledgeSet F)
    (allowed : KnowledgeSet F → Prop) : Prop :=
  ∀ a, allowed a → ∀ p, truth p → allowed (AddFact a p)

theorem included_refl {F : Type u} (a : KnowledgeSet F) : Included a a := fun _ h => h

theorem included_trans {F : Type u} {a b c : KnowledgeSet F}
    (hab : Included a b) (hbc : Included b c) : Included a c :=
  fun p h => hbc p (hab p h)

theorem strict_irrefl {F : Type u} (a : KnowledgeSet F) : ¬ StrictlyIncluded a a := by
  rintro ⟨_, p, hp, hnp⟩
  exact hnp hp

theorem strict_trans {F : Type u} {a b c : KnowledgeSet F}
    (hab : StrictlyIncluded a b) (hbc : StrictlyIncluded b c) :
    StrictlyIncluded a c := by
  refine ⟨included_trans hab.1 hbc.1, ?_⟩
  obtain ⟨p, hp, hnp⟩ := hab.2
  exact ⟨p, hbc.1 p hp, hnp⟩

theorem addFact_includes {F : Type u} (a : KnowledgeSet F) (p : F) :
    Included a (AddFact a p) := fun _ h => Or.inl h

theorem addFact_contains {F : Type u} (a : KnowledgeSet F) (p : F) :
    AddFact a p p := Or.inr rfl

theorem addFact_strict {F : Type u} {a : KnowledgeSet F} {p : F}
    (hp : ¬ a p) : StrictlyIncluded a (AddFact a p) :=
  ⟨addFact_includes a p, p, addFact_contains a p, hp⟩

theorem addFact_sound {F : Type u} {truth a : KnowledgeSet F} {p : F}
    (ha : Sound truth a) (hp : truth p) : Sound truth (AddFact a p) := by
  intro q hq
  rcases hq with hq | hq
  · exact ha q hq
  · subst q
    exact hp

theorem complete_iff_no_missing {F : Type u} (truth a : KnowledgeSet F) :
    Complete truth a ↔ ¬ Missing truth a := by
  classical
  constructor
  · intro h ⟨p, hp, hnp⟩
    exact hnp (h p hp)
  · intro h p hp
    by_cases ha : a p
    · exact ha
    · exact False.elim (h ⟨p, hp, ha⟩)

/-- Exact closure criterion for maximality, with sound alternatives. -/
theorem maximal_iff_complete {F : Type u}
    (truth : KnowledgeSet F) (allowed : KnowledgeSet F → Prop)
    (hall : ∀ a, allowed a → Sound truth a)
    (hclosed : OneFactClosed truth allowed)
    {a : KnowledgeSet F} (ha : allowed a) :
    MaximalIn allowed a ↔ Complete truth a := by
  classical
  constructor
  · intro hmax p hp
    by_cases hknown : a p
    · exact hknown
    · exact False.elim (hmax
        ⟨AddFact a p, hclosed a ha p hp, addFact_strict hknown⟩)
  · intro hcomplete ⟨b, hb, _, p, hbp, hnap⟩
    exact hnap (hcomplete p (hall b hb p hbp))

theorem no_maximal_of_missing_and_closure {F : Type u}
    (truth : KnowledgeSet F) (allowed : KnowledgeSet F → Prop)
    (hclosed : OneFactClosed truth allowed)
    (hmissing : ∀ a, allowed a → Missing truth a) :
    ∀ a, allowed a → ¬ MaximalIn allowed a := by
  intro a ha hmax
  obtain ⟨p, hp, hnp⟩ := hmissing a ha
  exact hmax ⟨AddFact a p, hclosed a ha p hp, addFact_strict hnp⟩

def Terminal {S : Type u} {F : Type v}
    (knows : S → KnowledgeSet F) (access : S → S → Prop) (s : S) : Prop :=
  ¬ ∃ t, access s t ∧ StrictlyIncluded (knows s) (knows t)

theorem bounded_rank_forbids_infinite_path {S : Type u}
    (rank : S → Nat) (path : Nat → S) (bound : Nat)
    (hbound : ∀ n, rank (path n) ≤ bound)
    (hstep : ∀ n, rank (path n) < rank (path (n + 1))) : False := by
  have hlower : ∀ n, n ≤ rank (path n) := by
    intro n
    induction n with
    | zero => exact Nat.zero_le _
    | succ n ih =>
      have hs := hstep n
      omega
  have h1 := hlower (bound + 1)
  have h2 := hbound (bound + 1)
  omega

/-! ## Epistemic introspection and unknown unknowns -/

structure EpistemicFrame (World : Type u) where
  access : World → World → Prop
  reflexive : ∀ w, access w w
  transitive : ∀ {a b c}, access a b → access b c → access a c

def Knows {W : Type u} (M : EpistemicFrame W) (p : W → Prop) : W → Prop :=
  fun w => ∀ v, M.access w v → p v

theorem knows_factive {W : Type u} (M : EpistemicFrame W)
    (p : W → Prop) (w : W) : Knows M p w → p w :=
  fun h => h w (M.reflexive w)

theorem knows_positive_introspection {W : Type u} (M : EpistemicFrame W)
    (p : W → Prop) (w : W) : Knows M p w → Knows M (Knows M p) w := by
  intro h v hwv z hvz
  exact h z (M.transitive hwv hvz)

theorem knows_idempotent {W : Type u} (M : EpistemicFrame W)
    (p : W → Prop) (w : W) : Knows M (Knows M p) w ↔ Knows M p w :=
  ⟨knows_factive M (Knows M p) w, knows_positive_introspection M p w⟩

def IterateKnowledge {W : Type u} (M : EpistemicFrame W)
    (p : W → Prop) : Nat → W → Prop
  | 0 => p
  | n + 1 => Knows M (IterateKnowledge M p n)

theorem iterate_knowledge_stabilizes {W : Type u} (M : EpistemicFrame W)
    (p : W → Prop) (n : Nat) (w : W) :
    IterateKnowledge M p (n + 1) w ↔ Knows M p w := by
  induction n generalizing w with
  | zero => exact Iff.rfl
  | succ n ih =>
    change Knows M (IterateKnowledge M p (n + 1)) w ↔ Knows M p w
    constructor
    · intro h
      apply (knows_idempotent M p w).mp
      intro v hwv
      exact (ih v).mp (h v hwv)
    · intro h v hwv
      apply (ih v).mpr
      exact knows_positive_introspection M p w h v hwv

def twoWorldFrame : EpistemicFrame Bool where
  access := fun _ _ => True
  reflexive := fun _ => True.intro
  transitive := fun _ _ => True.intro

def AtomAware (world atom : Bool) : Prop := world = atom

theorem every_world_omits_an_atom (w : Bool) :
    ∃ p : Bool, ¬ AtomAware w p := by
  cases w
  · exact ⟨true, by decide⟩
  · exact ⟨false, by decide⟩

theorem knows_there_is_an_unknown (w : Bool) :
    Knows twoWorldFrame (fun v => ∃ p : Bool, ¬ AtomAware v p) w := by
  intro v _
  exact every_world_omits_an_atom v

theorem no_identified_uniform_unknown (w : Bool) :
    ¬ ∃ p : Bool, Knows twoWorldFrame (fun v => ¬ AtomAware v p) w := by
  rintro ⟨p, hp⟩
  exact hp p True.intro rfl

theorem known_existence_without_known_witness (w : Bool) :
    Knows twoWorldFrame (fun v => ∃ p : Bool, ¬ AtomAware v p) w ∧
    ¬ ∃ p : Bool, Knows twoWorldFrame (fun v => ¬ AtomAware v p) w :=
  ⟨knows_there_is_an_unknown w, no_identified_uniform_unknown w⟩

/-! ## A fixed grounding structure with opposing access policies -/

inductive Being where
  | source
  | mediator
  | learner (stage : Nat)
  deriving DecidableEq

def Grounds : Being → Being → Prop
  | .source, .mediator => True
  | .mediator, .learner _ => True
  | _, _ => False

def Ungrounded (b : Being) : Prop := ¬ ∃ a, Grounds a b

theorem source_ungrounded : Ungrounded Being.source := by
  rintro ⟨a, ha⟩
  cases a <;> exact ha

theorem mediator_is_grounded : Grounds Being.source Being.mediator := True.intro

theorem learner_is_mediated (n : Nat) :
    Grounds Being.mediator (Being.learner n) := True.intro

theorem ungrounded_iff_source (b : Being) : Ungrounded b ↔ b = Being.source := by
  cases b with
  | source => exact ⟨fun _ => rfl, fun _ => source_ungrounded⟩
  | mediator =>
    constructor
    · intro h
      exact False.elim (h ⟨Being.source, mediator_is_grounded⟩)
    · intro h
      cases h
  | learner n =>
    constructor
    · intro h
      exact False.elim (h ⟨Being.mediator, learner_is_mediated n⟩)
    · intro h
      cases h

theorem source_accessible : Acc Grounds Being.source := by
  constructor
  intro y hy
  cases y <;> exact False.elim hy

theorem mediator_accessible : Acc Grounds Being.mediator := by
  constructor
  intro y hy
  cases y with
  | source => exact source_accessible
  | mediator => exact False.elim hy
  | learner _ => exact False.elim hy

theorem grounding_wellFounded : WellFounded Grounds := by
  constructor
  intro b
  cases b with
  | source => exact source_accessible
  | mediator => exact mediator_accessible
  | learner n =>
    constructor
    intro y hy
    cases y with
    | source => exact False.elim hy
    | mediator => exact mediator_accessible
    | learner _ => exact False.elim hy

def SourceKnows (_ : Nat) : Prop := True

def PrefixKnowledge (n : Nat) : KnowledgeSet Nat := fun p => p < n

def CappedAccess (cap s t : Nat) : Prop := s < t ∧ t ≤ cap

def OpenAccess (s t : Nat) : Prop := s < t

theorem prefix_sound (n : Nat) : Sound SourceKnows (PrefixKnowledge n) :=
  fun _ _ => True.intro

theorem prefix_missing (n : Nat) : Missing SourceKnows (PrefixKnowledge n) :=
  ⟨n, True.intro, Nat.lt_irrefl n⟩

theorem prefix_included_of_le {s t : Nat} (hst : s ≤ t) :
    Included (PrefixKnowledge s) (PrefixKnowledge t) := by
  intro p hp
  exact Nat.lt_of_lt_of_le hp hst

theorem prefix_strict_iff (s t : Nat) :
    StrictlyIncluded (PrefixKnowledge s) (PrefixKnowledge t) ↔ s < t := by
  constructor
  · rintro ⟨_, p, hpt, hnps⟩
    change p < t at hpt
    change ¬ p < s at hnps
    omega
  · intro hst
    exact ⟨prefix_included_of_le (Nat.le_of_lt hst), s, hst, Nat.lt_irrefl s⟩

theorem capped_terminal_iff (cap s : Nat) :
    Terminal PrefixKnowledge (CappedAccess cap) s ↔ cap ≤ s := by
  constructor
  · intro h
    by_cases hs : cap ≤ s
    · exact hs
    · have hsc : s < cap := by omega
      exact False.elim (h ⟨cap, ⟨hsc, Nat.le_refl cap⟩,
        (prefix_strict_iff s cap).mpr hsc⟩)
  · intro hs ⟨t, ⟨hst, htcap⟩, _⟩
    omega

theorem capped_reachable_terminal (cap : Nat) :
    cap ≤ cap ∧ Terminal PrefixKnowledge (CappedAccess cap) cap :=
  ⟨Nat.le_refl cap, (capped_terminal_iff cap cap).mpr (Nat.le_refl cap)⟩

theorem open_no_terminal (s : Nat) : ¬ Terminal PrefixKnowledge OpenAccess s := by
  intro h
  exact h ⟨s + 1, Nat.lt_succ_self s,
    (prefix_strict_iff s (s + 1)).mpr (Nat.lt_succ_self s)⟩

/-- A model-theoretic counterexample pair for the specified grounding premises. -/
theorem common_grounding_opposite_termination (cap : Nat) :
    WellFounded Grounds ∧
    (∀ b, Ungrounded b ↔ b = Being.source) ∧
    (∀ n, Missing SourceKnows (PrefixKnowledge n)) ∧
    Terminal PrefixKnowledge (CappedAccess cap) cap ∧
    (∀ s, ¬ Terminal PrefixKnowledge OpenAccess s) :=
  ⟨grounding_wellFounded, ungrounded_iff_source, prefix_missing,
    (capped_terminal_iff cap cap).mpr (Nat.le_refl cap), open_no_terminal⟩

def CappedAdmissible (cap : Nat) (a : KnowledgeSet Nat) : Prop :=
  ∃ n, n ≤ cap ∧ a = PrefixKnowledge n

theorem capped_admissible_cap (cap : Nat) :
    CappedAdmissible cap (PrefixKnowledge cap) := ⟨cap, Nat.le_refl cap, rfl⟩

theorem capped_access_fails_oneFactClosure (cap : Nat) :
    ¬ OneFactClosed SourceKnows (CappedAdmissible cap) := by
  intro h
  obtain ⟨n, hn, heq⟩ := h (PrefixKnowledge cap)
    (capped_admissible_cap cap) cap True.intro
  have hp : PrefixKnowledge n cap := by
    rw [← heq]
    exact addFact_contains (PrefixKnowledge cap) cap
  change cap < n at hp
  omega

/-! ## Derivability conditions and the logical core of second incompleteness

The fixed-point property is an explicit hypothesis of the presentation.
Instantiating it for arithmetic requires a separate diagonal-lemma and
arithmetization development. Propositional composition and application
below are familiar derived rules, included as interface fields.
-/

structure ProvabilityPresentation (F : Type u) where
  bottom : F
  implies : F → F → F
  box : F → F
  proves : F → Prop
  identity : ∀ p, proves (implies p p)
  compose : ∀ {p q r}, proves (implies p q) → proves (implies q r) →
    proves (implies p r)
  applyUnder : ∀ {p q r}, proves (implies p (implies q r)) →
    proves (implies p q) → proves (implies p r)
  modusPonens : ∀ {p q}, proves (implies p q) → proves p → proves q
  necessitate : ∀ {p}, proves p → proves (box p)
  distribution : ∀ p q, proves (implies (box (implies p q))
    (implies (box p) (box q)))
  positive : ∀ p, proves (implies (box p) (box (box p)))
  diagonal : ∀ p, ∃ d,
    proves (implies d (implies (box d) p)) ∧
    proves (implies (implies (box d) p) d)

def PresentationConsistent {F : Type u} (M : ProvabilityPresentation F) : Prop :=
  ¬ M.proves M.bottom

def ConsistencySentence {F : Type u} (M : ProvabilityPresentation F) : F :=
  M.implies (M.box M.bottom) M.bottom

theorem provability_box_map {F : Type u} (M : ProvabilityPresentation F)
    {p q : F} (h : M.proves (M.implies p q)) :
    M.proves (M.implies (M.box p) (M.box q)) :=
  M.modusPonens (M.distribution p q) (M.necessitate h)

/-- The metatheoretic Lob rule, derived from diagonalization and D1--D3. -/
theorem lob_rule {F : Type u} (M : ProvabilityPresentation F) (p : F)
    (h : M.proves (M.implies (M.box p) p)) : M.proves p := by
  obtain ⟨d, hforward, hbackward⟩ := M.diagonal p
  have h1 := provability_box_map M hforward
  have h2 := M.compose h1 (M.distribution (M.box d) p)
  have h3 := M.applyUnder h2 (M.positive d)
  have h4 := M.compose h3 h
  have hd := M.modusPonens hbackward h4
  exact M.modusPonens h4 (M.necessitate hd)

/-- Second-incompleteness consequence for an explicit provability interface. -/
theorem second_incompleteness_interface {F : Type u} (M : ProvabilityPresentation F)
    (hc : PresentationConsistent M) : ¬ M.proves (ConsistencySentence M) := by
  intro h
  exact hc (lob_rule M M.bottom h)

theorem internal_factivity_conflicts_with_consistency {F : Type u}
    (M : ProvabilityPresentation F) (hc : PresentationConsistent M)
    (hf : ∀ p, M.proves (M.implies (M.box p) p)) : False :=
  hc (lob_rule M M.bottom (hf M.bottom))

/-- A small consistent interpretation showing the interface itself is inhabited.
This degenerate modal algebra is not the arithmetic interpretation.
-/
def simpleProvabilityModel : ProvabilityPresentation Prop where
  bottom := False
  implies := fun p q => p → q
  box := fun _ => True
  proves := fun p => p
  identity := fun _ h => h
  compose := by
    intro p q r hpq hqr hp
    exact hqr (hpq hp)
  applyUnder := by
    intro p q r hpqr hpq hp
    exact hpqr hp (hpq hp)
  modusPonens := by
    intro p q hpq hp
    exact hpq hp
  necessitate := by
    intro p hp
    exact True.intro
  distribution := by
    intro p q h1 h2
    exact True.intro
  positive := by
    intro p hp
    exact True.intro
  diagonal := by
    intro p
    exact ⟨p, (fun hp _ => hp), (fun h => h True.intro)⟩

theorem simple_model_consistent : PresentationConsistent simpleProvabilityModel :=
  fun h => h

theorem simple_model_cannot_prove_consistency :
    ¬ simpleProvabilityModel.proves (ConsistencySentence simpleProvabilityModel) :=
  second_incompleteness_interface simpleProvabilityModel simple_model_consistent

/-! ## Strict reflection progressions -/

structure MarkedProgression (S : Type u) (F : Type v) where
  knows : S → KnowledgeSet F
  admissible : S → Prop
  next : S → S
  marker : S → F
  includes : ∀ s, Included (knows s) (knows (next s))
  adds : ∀ s, knows (next s) (marker s)
  missing : ∀ s, admissible s → ¬ knows s (marker s)
  preserves : ∀ s, admissible s → admissible (next s)

theorem progression_step_strict {S : Type u} {F : Type v}
    (P : MarkedProgression S F) {s : S} (hs : P.admissible s) :
    StrictlyIncluded (P.knows s) (P.knows (P.next s)) :=
  ⟨P.includes s, P.marker s, P.adds s, P.missing s hs⟩

def ProgressionStage {S : Type u} {F : Type v}
    (P : MarkedProgression S F) (s : S) : Nat → S
  | 0 => s
  | n + 1 => P.next (ProgressionStage P s n)

theorem progression_all_admissible {S : Type u} {F : Type v}
    (P : MarkedProgression S F) {s : S} (hs : P.admissible s) (n : Nat) :
    P.admissible (ProgressionStage P s n) := by
  induction n with
  | zero => exact hs
  | succ n ih => exact P.preserves _ ih

theorem progression_strict_at_all_indices {S : Type u} {F : Type v}
    (P : MarkedProgression S F) {s : S} (hs : P.admissible s)
    {m n : Nat} (hmn : m < n) :
    StrictlyIncluded (P.knows (ProgressionStage P s m))
      (P.knows (ProgressionStage P s n)) := by
  induction n with
  | zero => omega
  | succ n ih =>
    have hstep := progression_step_strict P (progression_all_admissible P hs n)
    by_cases heq : m = n
    · subst m
      exact hstep
    · have hlt : m < n := by omega
      exact strict_trans (ih hlt) hstep

theorem progression_has_no_repetitions {S : Type u} {F : Type v}
    (P : MarkedProgression S F) {s : S} (hs : P.admissible s)
    {m n : Nat} (hmn : m < n) :
    ProgressionStage P s m ≠ ProgressionStage P s n := by
  intro heq
  have h := progression_strict_at_all_indices P hs hmn
  rw [heq] at h
  exact strict_irrefl _ h

/-- Arithmetic reflection must additionally preserve the admissibility class.
Consistency preservation is not inferred from consistency alone.
-/
structure ReflectionInterface (S : Type u) (F : Type v) where
  logic : S → ProvabilityPresentation F
  admissible : S → Prop
  next : S → S
  valid_consistent : ∀ s, admissible s → PresentationConsistent (logic s)
  preserves : ∀ s, admissible s → admissible (next s)
  includes : ∀ s, Included (logic s).proves (logic (next s)).proves
  adds_consistency : ∀ s, (logic (next s)).proves (ConsistencySentence (logic s))

def reflectionProgression {S : Type u} {F : Type v}
    (R : ReflectionInterface S F) : MarkedProgression S F where
  knows := fun s => (R.logic s).proves
  admissible := R.admissible
  next := R.next
  marker := fun s => ConsistencySentence (R.logic s)
  includes := R.includes
  adds := R.adds_consistency
  missing := fun s hs => second_incompleteness_interface (R.logic s)
    (R.valid_consistent s hs)
  preserves := R.preserves

theorem reflection_strict_extension {S : Type u} {F : Type v}
    (R : ReflectionInterface S F) {s : S} (hs : R.admissible s) :
    StrictlyIncluded (R.logic s).proves (R.logic (R.next s)).proves :=
  progression_step_strict (reflectionProgression R) hs

theorem reflection_no_maximal_admissible {S : Type u} {F : Type v}
    (R : ReflectionInterface S F) (s : S) (hs : R.admissible s) :
    ∃ t, R.admissible t ∧ StrictlyIncluded (R.logic s).proves (R.logic t).proves :=
  ⟨R.next s, R.preserves s hs, reflection_strict_extension R hs⟩

def prefixProgression : MarkedProgression Nat Nat where
  knows := PrefixKnowledge
  admissible := fun _ => True
  next := fun s => s + 1
  marker := fun s => s
  includes := fun s => prefix_included_of_le (Nat.le_succ s)
  adds := fun s => Nat.lt_succ_self s
  missing := fun s _ => Nat.lt_irrefl s
  preserves := fun _ _ => True.intro

theorem prefix_progression_is_strict (m n : Nat) (hmn : m < n) :
    StrictlyIncluded (prefixProgression.knows (ProgressionStage prefixProgression 0 m))
      (prefixProgression.knows (ProgressionStage prefixProgression 0 n)) :=
  progression_strict_at_all_indices prefixProgression True.intro hmn

/-! ## Finite observations and a complete coherent limit -/

abbrev BitStream := Nat → Bool

def Truncate (n : Nat) (x : BitStream) : BitStream :=
  fun i => if i < n then x i else false

theorem truncate_idempotent (n : Nat) (x : BitStream) :
    Truncate n (Truncate n x) = Truncate n x := by
  funext i
  by_cases hi : i < n <;> simp [Truncate, hi]

theorem truncate_nested (m n : Nat) (hmn : m ≤ n) (x : BitStream) :
    Truncate m (Truncate n x) = Truncate m x := by
  funext i
  by_cases hi : i < m
  · have hin : i < n := Nat.lt_of_lt_of_le hi hmn
    simp [Truncate, hi, hin]
  · simp [Truncate, hi]

def OneBit (n : Nat) : BitStream := fun i => if i = n then true else false

theorem finite_view_loses_information (n : Nat) :
    ∃ x y : BitStream, x ≠ y ∧ Truncate n x = Truncate n y := by
  refine ⟨(fun _ => false), OneBit n, ?_, ?_⟩
  · intro h
    have hi := congrFun h n
    simp [OneBit] at hi
  · funext i
    by_cases hi : i < n
    · have hne : i ≠ n := by omega
      simp [Truncate, OneBit, hi, hne]
    · simp [Truncate, hi]

theorem truncations_jointly_separate (x y : BitStream)
    (h : ∀ n, Truncate n x = Truncate n y) : x = y := by
  funext i
  have hi := congrFun (h (i + 1)) i
  simpa [Truncate, Nat.lt_succ_self] using hi

theorem truncation_fixed_iff_tail_false (n : Nat) (x : BitStream) :
    Truncate n x = x ↔ ∀ i, n ≤ i → x i = false := by
  constructor
  · intro h i hi
    have hni : ¬ i < n := by omega
    have heq := congrFun h i
    simp [Truncate, hni] at heq
    exact heq.symm
  · intro h
    funext i
    by_cases hi : i < n
    · simp [Truncate, hi]
    · have hni : n ≤ i := by omega
      simp [Truncate, hi, h i hni]

theorem all_true_stream_never_stabilizes (n : Nat) :
    Truncate n (fun _ => true) ≠ Truncate (n + 1) (fun _ => true) := by
  intro h
  have hi := congrFun h n
  simp [Truncate, Nat.lt_succ_self] at hi

theorem all_false_stream_is_fixed (n : Nat) :
    Truncate n (fun _ => false) = (fun _ => false) := by
  funext i
  simp [Truncate]

structure CoherentViews where
  view : Nat → BitStream
  compatible : ∀ m n, m ≤ n → Truncate m (view n) = view m

def Reconstructed (V : CoherentViews) : BitStream := fun i => V.view (i + 1) i

theorem reconstruct_recovers_views (V : CoherentViews) (n : Nat) :
    Truncate n (Reconstructed V) = V.view n := by
  funext i
  by_cases hi : i < n
  · have hin : i + 1 ≤ n := by omega
    have h := congrFun (V.compatible (i + 1) n hin) i
    simp only [Truncate, if_pos (Nat.lt_succ_self i)] at h
    simp only [Truncate, Reconstructed, if_pos hi]
    exact h.symm
  · have h := congrFun (V.compatible n n (Nat.le_refl n)) i
    simp only [Truncate, if_neg hi] at h
    simp only [Truncate, if_neg hi]
    exact h

theorem reconstructed_limit_unique (V : CoherentViews) (x : BitStream)
    (hx : ∀ n, Truncate n x = V.view n) : x = Reconstructed V := by
  apply truncations_jointly_separate
  intro n
  exact (hx n).trans (reconstruct_recovers_views V n).symm

theorem coherent_limit_exists_unique (V : CoherentViews) :
    ∃ x : BitStream, (∀ n, Truncate n x = V.view n) ∧
      ∀ y : BitStream, (∀ n, Truncate n y = V.view n) → y = x :=
  ⟨Reconstructed V, reconstruct_recovers_views V,
    fun y hy => reconstructed_limit_unique V y hy⟩

end Unveiling
