import Neoplatonic.Core

/-!
# Modal necessity is not identical to ontological independence

A small model with two possible worlds and two beings illustrates an
important distinction between Gödel-style necessary existence and
Avicenna-style ungrounded necessary existence.

Both beings exist in all worlds, but one is grounded in the other.
Therefore merely existing in every world does not make one a first principle.
-/

namespace Neoplatonic

/-- Toy accessibility-independent existence predicate in two worlds. -/
def existsEverywhere : Bool → Bool → Prop := fun _ _ => True

/-- One distinct being (false) grounds the other (true). -/
def groundsSecond : Bool → Bool → Prop := fun source target =>
  source = false ∧ target = true

/-- A necessary entity can be ontologically dependent. -/
theorem modal_necessity_does_not_imply_ungrounded :
    (∀ w : Bool, existsEverywhere w true) ∧
    ¬ Root groundsSecond true := by
  constructor
  · intro _
    trivial
  · intro hroot
    apply hroot
    exact ⟨false, ⟨rfl, rfl⟩⟩

end Neoplatonic
