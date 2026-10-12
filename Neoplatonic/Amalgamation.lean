import Neoplatonic.Core

/-!
# Unity from compositional closure and unique immediate grounding

The earlier Core theorem postulates that every pair has a *common origin*.
This experiment replaces that condition with:

* CommonEffect: any two beings can enter a common composite/consequence.
* SingleParent: each being has at most one *immediate* ontological predecessor.

Combined with well-foundedness and a nonempty domain, these imply
that every being has the same root ancestor. The single-parent premise
is metaphysically very demanding: it forbids genuine joint immediate
causation and should be treated as a target of philosophical scrutiny.
-/

namespace Neoplatonic

universe u

/-- A minimal ancestor of a given entity exists under well-foundedness.
    Strengthens `exists_root` by retaining the path from root to entity. -/
theorem exists_root_ancestor {α : Type u}
    (prior : α → α → Prop) (wf : WellFounded prior) (x : α) :
    ∃ r : α, Root prior r ∧ Reach prior r x := by
  classical
  induction x using wf.induction with
  | h x ih =>
    by_cases hp : ∃ y : α, prior y x
    · obtain ⟨y, hyx⟩ := hp
      obtain ⟨r, hr, hry⟩ := ih y hyx
      exact ⟨r, hr, Reach.step hry hyx⟩
    · exact ⟨x, hp, Reach.refl x⟩

/-- If immediate predecessors are unique, any two root ancestors of
    a common descendant coincide. -/
theorem root_ancestors_agree {α : Type u}
    {prior : α → α → Prop}
    (singleParent : ∀ (x y z : α), prior x z → prior y z → x = y)
    {r z : α} (hr : Root prior r) (hrz : Reach prior r z) :
    ∀ s : α, Root prior s → Reach prior s z → r = s := by
  induction hrz with
  | refl =>
      intro s hs hsx
      exact (ancestor_of_root_eq hr hsx).symm
  | @step y z hxy hyz ih =>
      intro s hs hsz
      cases hsz with
      | refl =>
          exact False.elim (hs ⟨y, hyz⟩)
      | @step w _ hsw hwz =>
          have h : y = w := singleParent y w z hyz hwz
          subst w
          exact ih s hs hsw

/-- Ontological assumptions that concern effects rather than common origins. -/
structure AmalgamatedGroundTheory (α : Type u) where
  prior : α → α → Prop
  wf : WellFounded prior
  commonEffect : ∀ x y : α,
    ∃ z : α, Reach prior x z ∧ Reach prior y z
  singleParent : ∀ x y z : α, prior x z → prior y z → x = y

/-- A first principle follows from common-composition and a no-merge law.
    We derive common ancestry instead of assuming it. -/
def AmalgamatedGroundTheory.toGroundTheory {α : Type u}
    (theory : AmalgamatedGroundTheory α) : GroundTheory α where
  prior := theory.prior
  wf := theory.wf
  commonPrior := by
    intro x y
    obtain ⟨rx, hrx, hxx⟩ := exists_root_ancestor theory.prior theory.wf x
    obtain ⟨ry, hry, hyy⟩ := exists_root_ancestor theory.prior theory.wf y
    obtain ⟨c, hxc, hyc⟩ := theory.commonEffect rx ry
    have h : rx = ry :=
      root_ancestors_agree theory.singleParent hrx hxc ry hry hyc
    subst ry
    exact ⟨rx, hxx, hyy⟩

/-- No assumption of pairwise common origin appears in this statement. -/
theorem amalgamation_unique_first_principle {α : Type u}
    (theory : AmalgamatedGroundTheory α) (seed : α) :
    ∃! g : α, FirstPrinciple theory.prior g :=
  unique_first_principle theory.toGroundTheory seed

end Neoplatonic
