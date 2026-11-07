import Mathlib.Order.ConditionallyCompleteLattice.Basic
import Mathlib.Data.Real.Basic
import Mathlib.Tactic

/-! Generalized left inverses, Appendix A.4, Lemma 17 of arXiv:2605.16645v1.

The point `1` is inserted into each sublevel set to implement the paper's
empty-infimum convention. Every other element lies in `[0,1]`, so this insertion
does not change a nonempty infimum. Monotonicity of the input functions is not
needed for the order implication itself.
-/

set_option autoImplicit false

namespace StatisticalUnlearning

/-- Sublevel set on `[0,1]`, with `1` adjoined as the empty-set convention. -/
def inverseSublevel (f : ℝ → ℝ) (t : ℝ) : Set ℝ :=
  insert 1 {x | 0 ≤ x ∧ x ≤ 1 ∧ f x ≤ t}

/-- The generalized left inverse with the paper's empty-infimum convention. -/
noncomputable def leftInverse (f : ℝ → ℝ) (t : ℝ) : ℝ :=
  sInf (inverseSublevel f t)

theorem inverseSublevel_bddBelow (f : ℝ → ℝ) (t : ℝ) :
    BddBelow (inverseSublevel f t) := by
  refine ⟨0, ?_⟩
  intro x hx
  rcases hx with rfl | hx
  · norm_num
  · exact hx.1

/-- On a nonempty sublevel set, adjoining `1` leaves the infimum unchanged. -/
theorem leftInverse_eq_sInf_of_nonempty (f : ℝ → ℝ) (t : ℝ)
    (hs : {x : ℝ | 0 ≤ x ∧ x ≤ 1 ∧ f x ≤ t}.Nonempty) :
    leftInverse f t = sInf {x : ℝ | 0 ≤ x ∧ x ≤ 1 ∧ f x ≤ t} := by
  have hb : BddBelow {x : ℝ | 0 ≤ x ∧ x ≤ 1 ∧ f x ≤ t} := by
    exact ⟨0, fun _ hx => hx.1⟩
  apply le_antisymm
  · exact csInf_le_csInf (inverseSublevel_bddBelow f t) hs
      (fun _ hx => Set.mem_insert_of_mem 1 hx)
  · apply le_csInf ⟨1, Set.mem_insert 1 _⟩
    intro x hx
    rcases hx with rfl | hx
    · obtain ⟨y, hy⟩ := hs
      exact le_trans (csInf_le hb hy) hy.2.1
    · exact csInf_le hb hx

/-- On an empty sublevel set the generalized inverse is exactly `1`. -/
theorem leftInverse_eq_one_of_empty (f : ℝ → ℝ) (t : ℝ)
    (hs : {x : ℝ | 0 ≤ x ∧ x ≤ 1 ∧ f x ≤ t} = ∅) :
    leftInverse f t = 1 := by
  simp [leftInverse, inverseSublevel, hs]

/-- Lemma 17: pointwise order on `[0,1]` preserves generalized-inverse order. -/
theorem leftInverse_mono {f g : ℝ → ℝ}
    (h : ∀ x ∈ Set.Icc (0 : ℝ) 1, f x ≤ g x) (t : ℝ) :
    leftInverse f t ≤ leftInverse g t := by
  apply csInf_le_csInf (inverseSublevel_bddBelow f t)
  · exact ⟨1, Set.mem_insert 1 _⟩
  · intro x hx
    rcases hx with rfl | hx
    · exact Set.mem_insert 1 _
    · exact Set.mem_insert_of_mem 1 ⟨hx.1, hx.2.1, le_trans (h x ⟨hx.1, hx.2.1⟩) hx.2.2⟩

end StatisticalUnlearning
