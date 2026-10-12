import Neoplatonic.RHGeometry
import Neoplatonic.Models

/-! Explicit counterinterpretations preserve the genuine arithmetic theory.
    RH is a hypothesis, never an added global axiom. -/

namespace Neoplatonic

/-- Even granting RH, an infinite well-founded grounding interpretation
    can have many roots and no universal first principle. -/
theorem rh_compatible_with_no_first_principle (_rh : RiemannHypothesis) :
    WellFounded emptyPrior ∧ ¬ ∃ g : ℕ, FirstPrinciple emptyPrior g := by
  refine ⟨empty_prior_well_founded, ?_⟩
  rintro ⟨g, hg⟩
  apply empty_prior_lacks_common_origin
  intro x y
  exact ⟨g, hg.2 x, hg.2 y⟩

/-- A universal first principle guarantees the bridge's output outright.
    The spectral premise is unnecessary in this direction. -/
theorem first_principle_supplies_spectral_bridge {α : Type*}
    {r : α → α → Prop} (h : ∃ g, FirstPrinciple r g) :
    SpectralAligned → ∀ x y, ∃ z, Reach r z x ∧ Reach r z y := by
  rintro _ x y
  obtain ⟨g, hg⟩ := h
  exact ⟨g, hg.2 x, hg.2 y⟩

end Neoplatonic
