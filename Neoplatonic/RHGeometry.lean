import Neoplatonic.RH

/-!
# A non-decorative RH theorem: uniqueness of the spectral axis

The actual Riemann Hypothesis fixes the real coordinate of every
nontrivial zeta zero at 1/2. If at least one such zero exists,
then the common real coordinate is unique. This claim involves
no metaphysical interpretation of zeta zeros.

The extra witness hypothesis is included so that uniqueness of a
vacuously true property of an empty zero set is not inferred.
-/

namespace Neoplatonic

/-- Under RH and existence of a nontrivial zero, 1/2 is the unique
    real-coordinate projection shared by all nontrivial zeta zeros. -/
theorem rh_unique_spectral_axis
    (rh : RiemannHypothesis)
    (hasNontrivialZero : ∃ s : ℂ, CriticalZero s) :
    ∃! c : ℝ, ∀ s : ℂ, CriticalZero s → s.re = c := by
  obtain ⟨s, hs⟩ := hasNontrivialZero
  refine ⟨(1 / 2 : ℝ), ?_, ?_⟩
  · intro z hz
    exact rh_forces_critical_line rh z hz
  · intro c hc
    have hsline : s.re = (1 / 2 : ℝ) := rh_forces_critical_line rh s hs
    have hsc : s.re = c := hc s hs
    exact hsc.symm.trans hsline

/-- RH's spectral symmetry does not supply a unique ontological root
    for *arbitrary* predicates on the same number domain. The two
    interpretations are explicit. -/
theorem arithmetic_allows_opposed_one_interpretations :
    (∃ God : ℕ → Prop, ∃ n : ℕ, God n) ∧
    (∃ God : ℕ → Prop, ¬ ∃ n : ℕ, God n) := by
  constructor
  · exact ⟨fun n => n = 0, 0, rfl⟩
  · refine ⟨fun _ => False, ?_⟩
    rintro ⟨_, h⟩
    exact h

end Neoplatonic
