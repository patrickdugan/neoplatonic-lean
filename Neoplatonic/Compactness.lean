import Neoplatonic.Orders
import Mathlib.Topology.Compactness.Compact

/-! Compactness can replace termination, provided common lower bounds and
    closed principal lower sets are separately justified. -/
namespace Neoplatonic
universe u

theorem compact_lower_directed_first_principle {α : Type u}
    [PartialOrder α] [TopologicalSpace α] [CompactSpace α] [Nonempty α]
    (lowerDirected : ∀ x y : α, ∃ z, z ≤ x ∧ z ≤ y)
    (closedLower : ∀ x : α, IsClosed (Set.Iic x)) :
    ∃! g : α, FirstPrinciple (fun a b => a < b) g := by
  have directed : Directed (· ⊇ ·) (fun x : α => Set.Iic x) := by
    intro x y
    obtain ⟨z, hzx, hzy⟩ := lowerDirected x y
    refine ⟨z, ?_, ?_⟩
    · intro a ha
      exact le_trans ha hzx
    · intro a ha
      exact le_trans ha hzy
  obtain ⟨g, hg⟩ := IsCompact.nonempty_iInter_of_directed_nonempty_isCompact_isClosed
    (fun x : α => Set.Iic x) directed (fun x => ⟨x, le_rfl⟩)
    (fun x => (closedLower x).isCompact) closedLower
  have least : ∀ x : α, g ≤ x := fun x => Set.mem_iInter.mp hg x
  refine ⟨g, (first_principle_iff_least g).mpr least, ?_⟩
  intro y hy
  exact le_antisymm ((first_principle_iff_least y).mp hy g) (least y)

end Neoplatonic
