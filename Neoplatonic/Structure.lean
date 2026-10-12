import Neoplatonic.LocalConfluence

/-! Structural strengthening and an explicit audit of equivalent assumptions.

Grounding arrows point from ground to effect. Rewriting arrows point backwards.
`Connected` is undirected finite-path connectedness, with no topology assumed.
-/

namespace Neoplatonic
universe u

def CommonPrior {α : Type u} (r : α → α → Prop) : Prop :=
  ∀ x y, ∃ w, Reach r w x ∧ Reach r w y

def CommonEffects {α : Type u} (r : α → α → Prop) : Prop :=
  ∀ x y, ∃ z, Reach r x z ∧ Reach r y z

def Connected {α : Type u} (r : α → α → Prop) : Prop :=
  ∀ x y, Relation.EqvGen r x y

def BackwardConfluent {α : Type u} (r : α → α → Prop) : Prop :=
  ∀ z x y, Reach r x z → Reach r y z →
    ∃ w, Reach r w x ∧ Reach r w y

theorem reach_iff_reflTransGen {α : Type u} {r : α → α → Prop} {x y : α} :
    Reach r x y ↔ Relation.ReflTransGen r x y := by
  constructor
  · intro h
    induction h with
    | refl => exact .refl
    | step _ edge ih => exact .tail ih edge
  · intro h
    induction h with
    | refl => exact .refl _
    | tail _ edge ih => exact .step ih edge

theorem reverse_reach_iff {α : Type u} {r : α → α → Prop} {x y : α} :
    Relation.ReflTransGen (fun a b => r b a) x y ↔ Reach r y x := by
  constructor
  · intro h
    induction h with
    | refl => exact .refl _
    | @tail a b hab edge ih =>
      exact reach_trans (.step (.refl _) edge) ih
  · intro h
    induction h with
    | refl => exact .refl
    | step _ edge ih =>
      exact (Relation.ReflTransGen.single (r := fun a b => r b a) edge).trans ih

/-- Termination plus local backward confluence gives full backward confluence. -/
theorem backward_newman {α : Type u} (r : α → α → Prop)
    (wf : WellFounded r) (lc : LocallyCoherent r) : BackwardConfluent r := by
  intro z x y hx hy
  obtain ⟨a, ha, hax⟩ := exists_root_ancestor r wf x
  obtain ⟨b, hb, hby⟩ := exists_root_ancestor r wf y
  have eq := local_coherence_unique_root r wf lc z a b ha hb
    (reach_trans hax hx) (reach_trans hby hy)
  subst b
  exact ⟨a, hax, hby⟩

/-- Newman in Mathlib's rewriting closure API, for the reversed relation. -/
theorem newman_rewriting {α : Type u} (r : α → α → Prop)
    (wf : WellFounded r) (lc : LocallyCoherent r)
    {z x y : α}
    (hx : Relation.ReflTransGen (fun a b => r b a) z x)
    (hy : Relation.ReflTransGen (fun a b => r b a) z y) :
    Relation.Join (Relation.ReflTransGen (fun a b => r b a)) x y := by
  obtain ⟨w, hwx, hwy⟩ := backward_newman r wf lc z x y
    (reverse_reach_iff.mp hx) (reverse_reach_iff.mp hy)
  exact ⟨w, reverse_reach_iff.mpr hwx, reverse_reach_iff.mpr hwy⟩

/-- Under termination, local coherence is equivalent to unique root ancestry
    at every object. This equivalence identifies its philosophical strength. -/
theorem local_coherence_iff_unique_root_ancestor {α : Type u}
    (r : α → α → Prop) (wf : WellFounded r) :
    LocallyCoherent r ↔ ∀ z, ∃! a, Root r a ∧ Reach r a z := by
  constructor
  · intro lc z
    obtain ⟨a, ha, haz⟩ := exists_root_ancestor r wf z
    refine ⟨a, ⟨ha, haz⟩, ?_⟩
    intro b hb
    exact local_coherence_unique_root r wf lc z b a hb.1 ha hb.2 haz
  · intro unique x y z hx hy
    obtain ⟨a, ha, hax⟩ := exists_root_ancestor r wf x
    obtain ⟨b, hb, hby⟩ := exists_root_ancestor r wf y
    obtain ⟨c, hc, only⟩ := unique z
    have hac : a = c := only a ⟨ha, .step hax hx⟩
    have hbc : b = c := only b ⟨hb, .step hby hy⟩
    have eq : a = b := hac.trans hbc.symm
    exact ⟨a, hax, eq.symm ▸ hby⟩

theorem reach_eqvGen {α : Type u} {r : α → α → Prop} {x y : α}
    (h : Reach r x y) : Relation.EqvGen r x y := by
  induction h with
  | refl => exact .refl _
  | @step y z _ edge ih => exact .trans x y z ih (.rel y z edge)

theorem common_effects_connected {α : Type u} {r : α → α → Prop}
    (ce : CommonEffects r) : Connected r := by
  intro x y
  obtain ⟨z, hxz, hyz⟩ := ce x y
  exact .trans x z y (reach_eqvGen hxz) (.symm y z (reach_eqvGen hyz))

/-- Common ancestry propagates across a zigzag, because it is transitive
    under backward confluence. -/
theorem connected_common_prior {α : Type u} (r : α → α → Prop)
    (wf : WellFounded r) (lc : LocallyCoherent r)
    (conn : Connected r) : CommonPrior r := by
  intro x y
  induction conn x y with
  | rel a b edge => exact ⟨a, .refl a, .step (.refl a) edge⟩
  | refl a => exact ⟨a, .refl a, .refl a⟩
  | symm a b _ ih =>
    obtain ⟨w, hwa, hwb⟩ := ih
    exact ⟨w, hwb, hwa⟩
  | trans a b c _ _ ihab ihbc =>
    obtain ⟨v, hva, hvb⟩ := ihab
    obtain ⟨w, hwb, hwc⟩ := ihbc
    obtain ⟨t, htv, htw⟩ := backward_newman r wf lc b v w hvb hwb
    exact ⟨t, reach_trans htv hva, reach_trans htw hwc⟩

/-- Stronger than the submitted theorem: common effects can be replaced
    by undirected connectedness. Nonemptiness is expressed by `seed`. -/
theorem connected_unique_first_principle {α : Type u}
    (r : α → α → Prop) (wf : WellFounded r)
    (lc : LocallyCoherent r) (conn : Connected r) (seed : α) :
    ∃! g, FirstPrinciple r g :=
  unique_first_principle ⟨r, wf, connected_common_prior r wf lc conn⟩ seed

/-- Global common ancestry already amounts to the target under termination. -/
theorem common_prior_iff_first_principle {α : Type u}
    (r : α → α → Prop) (wf : WellFounded r) (seed : α) :
    CommonPrior r ↔ ∃! g, FirstPrinciple r g := by
  constructor
  · intro cp
    exact unique_first_principle ⟨r, wf, cp⟩ seed
  · rintro ⟨g, hg, _⟩ x y
    exact ⟨g, hg.2 x, hg.2 y⟩

/-- Exact characterization relative to well-foundedness and nonemptiness.
    Equivalent characterizations need independent justification as premises. -/
theorem local_connected_iff_first_principle {α : Type u}
    (r : α → α → Prop) (wf : WellFounded r) (seed : α) :
    (LocallyCoherent r ∧ Connected r) ↔ ∃! g, FirstPrinciple r g := by
  constructor
  · rintro ⟨lc, conn⟩
    exact connected_unique_first_principle r wf lc conn seed
  · rintro ⟨g, hg, _⟩
    constructor
    · intro x y z _ _
      exact ⟨g, hg.2 x, hg.2 y⟩
    · intro x y
      exact .trans x g y (.symm g x (reach_eqvGen (hg.2 x))) (reach_eqvGen (hg.2 y))

/-- Uniqueness of an ungrounded object alone suffices under termination. -/
theorem unique_root_iff_first_principle {α : Type u}
    (r : α → α → Prop) (wf : WellFounded r) :
    (∃! g, Root r g) ↔ ∃! g, FirstPrinciple r g := by
  constructor
  · rintro ⟨g, hg, only⟩
    have all : ∀ x, Reach r g x := by
      intro x
      obtain ⟨a, ha, hax⟩ := exists_root_ancestor r wf x
      simpa [only a ha] using hax
    exact ⟨g, ⟨hg, all⟩, fun x hx => only x hx.1⟩
  · rintro ⟨g, hg, _⟩
    exact ⟨g, hg.1, fun x hx => (ancestor_of_root_eq hx (hg.2 x)).symm⟩

/-- The displayed conjecture needs a nonempty carrier. -/
theorem empty_domain_counterexample :
    WellFounded (fun _ _ : Empty => False) ∧
    LocallyCoherent (fun _ _ : Empty => False) ∧
    CommonEffects (fun _ _ : Empty => False) ∧
    ¬ ∃ g : Empty, FirstPrinciple (fun _ _ => False) g := by
  refine ⟨⟨fun x => nomatch x⟩, ?_, ?_, ?_⟩
  · intro x
    exact nomatch x
  · intro x
    exact nomatch x
  · rintro ⟨g, _⟩
    exact nomatch g

end Neoplatonic
