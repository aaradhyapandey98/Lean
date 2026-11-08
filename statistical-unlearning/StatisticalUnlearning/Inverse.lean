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

/-- Generalized inverses take values in the unit interval. -/
theorem leftInverse_nonneg (f : ℝ → ℝ) (t : ℝ) :
    0 ≤ leftInverse f t := by
  apply le_csInf ⟨1, Set.mem_insert 1 _⟩
  intro x hx
  rcases hx with rfl | hx
  · norm_num
  · exact hx.1

theorem leftInverse_le_one (f : ℝ → ℝ) (t : ℝ) :
    leftInverse f t ≤ 1 := by
  exact csInf_le (inverseSublevel_bddBelow f t) (Set.mem_insert 1 _)

/-- Raising the threshold enlarges the sublevel set and lowers its infimum. -/
theorem leftInverse_antitone (f : ℝ → ℝ) : Antitone (leftInverse f) := by
  intro s t hst
  apply csInf_le_csInf (inverseSublevel_bddBelow f t)
  · exact ⟨1, Set.mem_insert 1 _⟩
  · intro x hx
    rcases hx with rfl | hx
    · exact Set.mem_insert 1 _
    · exact Set.mem_insert_of_mem 1 ⟨hx.1, hx.2.1, le_trans hx.2.2 hst⟩

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

/-- The inverse depends only on the function's values on the paper's domain. -/
theorem leftInverse_congr {f g : ℝ → ℝ}
    (h : ∀ x ∈ Set.Icc (0 : ℝ) 1, f x = g x) (t : ℝ) :
    leftInverse f t = leftInverse g t := by
  apply le_antisymm
  · exact leftInverse_mono (fun x hx => le_of_eq (h x hx)) t
  · exact leftInverse_mono (fun x hx => le_of_eq (h x hx).symm) t

/-- The paper's domain `[0,1]`, represented as a subtype. -/
abbrev UnitInterval := Set.Icc (0 : ℝ) 1

/-- Extend a real-valued function on `[0,1]` to `ℝ`; outside values are irrelevant. -/
def unitIntervalExtend (f : UnitInterval → ℝ) (x : ℝ) : ℝ :=
  if hx : x ∈ Set.Icc (0 : ℝ) 1 then f ⟨x, hx⟩ else 0

@[simp] theorem unitIntervalExtend_apply (f : UnitInterval → ℝ) (x : UnitInterval) :
    unitIntervalExtend f x = f x := by
  simp [unitIntervalExtend, x.property]

/-- The real sublevel set used by `leftInverse` is exactly the coercion image of
the paper's subtype-level sublevel set. -/
theorem unitIntervalSublevel_image (f : UnitInterval → UnitInterval) (t : UnitInterval) :
    {x : ℝ | 0 ≤ x ∧ x ≤ 1 ∧
      unitIntervalExtend (fun y => (f y : ℝ)) x ≤ (t : ℝ)} =
      (fun y : UnitInterval => (y : ℝ)) '' {y | f y ≤ t} := by
  ext x
  constructor
  · rintro ⟨hx0, hx1, hfx⟩
    let y : UnitInterval := ⟨x, ⟨hx0, hx1⟩⟩
    refine ⟨y, ?_, rfl⟩
    change (f y : ℝ) ≤ (t : ℝ)
    simpa [unitIntervalExtend, y.property] using hfx
  · rintro ⟨y, hy, rfl⟩
    refine ⟨y.property.1, y.property.2, ?_⟩
    have hy' : (f y : ℝ) ≤ (t : ℝ) := hy
    simpa [unitIntervalExtend, y.property] using hy'

/-- The paper-shaped generalized inverse, with both domain and codomain `[0,1]`. -/
noncomputable def unitIntervalLeftInverse (f : UnitInterval → UnitInterval)
    (t : UnitInterval) : UnitInterval :=
  ⟨leftInverse (unitIntervalExtend fun x => (f x : ℝ)) (t : ℝ),
    leftInverse_nonneg _ _, leftInverse_le_one _ _⟩

/-- For a nonempty sublevel set, the paper-shaped inverse is its real infimum. -/
theorem unitIntervalLeftInverse_eq_sInf_of_nonempty
    (f : UnitInterval → UnitInterval) (t : UnitInterval)
    (hs : {x : UnitInterval | f x ≤ t}.Nonempty) :
    (unitIntervalLeftInverse f t : ℝ) =
      sInf ((fun x : UnitInterval => (x : ℝ)) '' {x | f x ≤ t}) := by
  have hreal :
      {x : ℝ | 0 ≤ x ∧ x ≤ 1 ∧
        unitIntervalExtend (fun y => (f y : ℝ)) x ≤ (t : ℝ)}.Nonempty := by
    rw [unitIntervalSublevel_image]
    exact hs.image fun x => (x : ℝ)
  change leftInverse (unitIntervalExtend fun x => (f x : ℝ)) (t : ℝ) = _
  rw [leftInverse_eq_sInf_of_nonempty _ _ hreal, unitIntervalSublevel_image]

/-- For an empty sublevel set, the paper-shaped inverse has value `1`. -/
theorem unitIntervalLeftInverse_eq_one_of_empty
    (f : UnitInterval → UnitInterval) (t : UnitInterval)
    (hs : {x : UnitInterval | f x ≤ t} = ∅) :
    (unitIntervalLeftInverse f t : ℝ) = 1 := by
  change leftInverse (unitIntervalExtend fun x => (f x : ℝ)) (t : ℝ) = 1
  apply leftInverse_eq_one_of_empty
  rw [unitIntervalSublevel_image, hs, Set.image_empty]

/-- Pointwise order implies inverse order directly on the paper's subtype. -/
theorem unitIntervalLeftInverse_mono {f g : UnitInterval → UnitInterval}
    (h : ∀ x, f x ≤ g x) (t : UnitInterval) :
    unitIntervalLeftInverse f t ≤ unitIntervalLeftInverse g t := by
  change leftInverse (unitIntervalExtend fun x => (f x : ℝ)) (t : ℝ) ≤
    leftInverse (unitIntervalExtend fun x => (g x : ℝ)) (t : ℝ)
  apply leftInverse_mono
  intro x hx
  have h' : (f ⟨x, hx⟩ : ℝ) ≤ (g ⟨x, hx⟩ : ℝ) := h ⟨x, hx⟩
  simpa [unitIntervalExtend, hx] using h'

/-- Lemma 17 exactly in the paper's source shape. The antitonicity assumptions
are retained for fidelity, although the stronger order lemma above does not need them. -/
theorem generalizedInverse_order_paper {f g : UnitInterval → UnitInterval}
    (_hf : Antitone f) (_hg : Antitone g) (h : ∀ x, f x ≤ g x) (t : UnitInterval) :
    unitIntervalLeftInverse f t ≤ unitIntervalLeftInverse g t :=
  unitIntervalLeftInverse_mono h t

end StatisticalUnlearning
