import Neoplatonic.Amalgamation

/-!
# The One as a common normal form: a Newman-style theorem

Instead of postulating common origins, suppose:
  * grounding is well-founded;
  * every two beings can participate in a common effect;
  * whenever two immediate grounds support the same effect, their
    grounding histories meet further upstream (local backward confluence).

Under these assumptions all beings have the same ungrounded root.
This permits many immediate co-grounds, branching, and merging.
The proof parallels the termination + local confluence argument
behind Newman's lemma in abstract rewriting systems.
-/

namespace Neoplatonic

universe u

/-- A compositionality lemma for grounding paths. -/
theorem reach_trans {α : Type u} {prior : α → α → Prop}
    {x y z : α} (hxy : Reach prior x y) (hyz : Reach prior y z) :
    Reach prior x z := by
  induction hyz with
  | refl => exact hxy
  | step hyw hwz ih => exact Reach.step ih hwz

/-- A *local* assumption on pairs of immediate grounds of the same thing:
    their histories possess a common earlier ground. It says nothing
    directly about arbitrary pairs of beings. -/
def LocallyCoherent {α : Type u} (prior : α → α → Prop) : Prop :=
  ∀ x y z : α, prior x z → prior y z →
    ∃ w : α, Reach prior w x ∧ Reach prior w y

/-- A Newman-style uniqueness lemma: every descendant has at most
    one ultimate root provided backwards descent terminates and
    pairs of immediate causes have ancestrally coherent histories. -/
theorem local_coherence_unique_root {α : Type u}
    (prior : α → α → Prop) (wf : WellFounded prior)
    (lc : LocallyCoherent prior) :
    ∀ z r s : α, Root prior r → Root prior s →
      Reach prior r z → Reach prior s z → r = s := by
  intro z
  induction z using wf.induction with
  | h z ih =>
      intro r s hr hs hrz hsz
      cases hrz with
      | refl =>
          exact (ancestor_of_root_eq hr hsz).symm
      | @step x _ hrx hxz =>
          cases hsz with
          | refl =>
              exact False.elim (hs ⟨x, hxz⟩)
          | @step y _ hsy hyz =>
              obtain ⟨w, hwx, hwy⟩ := lc x y z hxz hyz
              obtain ⟨u, hu, huw⟩ := exists_root_ancestor prior wf w
              have hux : Reach prior u x := reach_trans huw hwx
              have huy : Reach prior u y := reach_trans huw hwy
              have hru : r = u := ih x hxz r u hr hu hrx hux
              have hsu : s = u := ih y hyz s u hs hu hsy huy
              exact hru.trans hsu.symm

/-- The structural premises can be stated locally and as upward
    directedness, instead of assuming a universal first ancestor. -/
structure ConfluentGroundTheory (α : Type u) where
  prior : α → α → Prop
  wf : WellFounded prior
  commonEffect : ∀ x y : α,
    ∃ z : α, Reach prior x z ∧ Reach prior y z
  localCoherence : LocallyCoherent prior

/-- Derive global common ancestry from termination, local coherence,
    and the ability of beings to have a common consequence. -/
def ConfluentGroundTheory.toGroundTheory {α : Type u}
    (theory : ConfluentGroundTheory α) : GroundTheory α where
  prior := theory.prior
  wf := theory.wf
  commonPrior := by
    intro x y
    obtain ⟨rx, hrx, hrx_x⟩ := exists_root_ancestor theory.prior theory.wf x
    obtain ⟨ry, hry, hry_y⟩ := exists_root_ancestor theory.prior theory.wf y
    obtain ⟨z, hxz, hyz⟩ := theory.commonEffect x y
    have hrx_z : Reach theory.prior rx z := reach_trans hrx_x hxz
    have hry_z : Reach theory.prior ry z := reach_trans hry_y hyz
    have eq : rx = ry := local_coherence_unique_root
      theory.prior theory.wf theory.localCoherence z rx ry
      hrx hry hrx_z hry_z
    subst ry
    exact ⟨rx, hrx_x, hry_y⟩

/-- A non-linear, locally formulated first-principle theorem.
    The intended metaphysics still resides in the interpretation and
    justification of the axioms, not in Lean's deductive steps. -/
theorem confluent_unique_first_principle {α : Type u}
    (theory : ConfluentGroundTheory α) (seed : α) :
    ∃! g : α, FirstPrinciple theory.prior g :=
  unique_first_principle theory.toGroundTheory seed

end Neoplatonic
