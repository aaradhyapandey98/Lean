import StatisticalUnlearning.Geometry

/-!
# One-dimensional geometry for the paper's feasible regions

The set identity is the geometric part of equation (58) in Appendix C.2 of
arXiv:2605.16645v1. These results do not prove that a statistical unlearning
region equals this geometric set. The zero-threshold example concerns the
metric formulation and is not a formalized Gaussian comparison theorem.
-/

set_option autoImplicit false

namespace StatisticalUnlearning

/-- The real-line feasible set is an interval intersected with two rays. -/
theorem real_geometricFeasibleRegion_eq (unwanted retained removal preservation : ℝ) :
    geometricFeasibleRegion unwanted retained removal preservation =
      Set.Icc (retained - preservation) (retained + preservation) ∩
        (Set.Iic (unwanted - removal) ∪ Set.Ici (unwanted + removal)) := by
  ext x
  change (removal ≤ dist x unwanted ∧ dist x retained ≤ preservation) ↔ _
  rw [Real.dist_eq, Real.dist_eq]
  simp only [Set.mem_inter_iff, Set.mem_Icc, Set.mem_union, Set.mem_Iic, Set.mem_Ici]
  constructor
  · intro h
    have hp := abs_le.mp h.2
    constructor
    · constructor <;> linarith
    · by_cases hx : 0 ≤ x - unwanted
      · right
        rw [abs_of_nonneg hx] at h
        linarith [h.1]
      · left
        have hx' : x - unwanted ≤ 0 := le_of_not_ge hx
        rw [abs_of_nonpos hx'] at h
        linarith [h.1]
  · intro h
    constructor
    · rcases h.2 with hleft | hright
      · have hx := neg_le_abs (x - unwanted)
        linarith
      · have hx := le_abs_self (x - unwanted)
        linarith
    · apply abs_le.mpr
      constructor <;> linarith [h.1.1, h.1.2]

/-- The triangle bound is sufficient on the real line for a nonnegative
preservation radius. This is purely a geometric statement. -/
theorem real_geometricFeasibleRegion_nonempty_iff
    (unwanted retained removal preservation : ℝ) (hp : 0 ≤ preservation) :
    (geometricFeasibleRegion unwanted retained removal preservation).Nonempty ↔
      removal ≤ dist unwanted retained + preservation := by
  constructor
  · exact geometricFeasibleRegion_nonempty_implies_bound
  · intro h
    rw [Real.dist_eq] at h
    by_cases huv : unwanted ≤ retained
    · rw [abs_of_nonpos (sub_nonpos.mpr huv)] at h
      refine ⟨retained + preservation, ?_⟩
      change removal ≤ dist (retained + preservation) unwanted ∧
        dist (retained + preservation) retained ≤ preservation
      rw [Real.dist_eq, Real.dist_eq,
        abs_of_nonneg (show 0 ≤ retained + preservation - unwanted by linarith),
        abs_of_nonneg (show 0 ≤ retained + preservation - retained by linarith)]
      constructor <;> linarith
    · have huv' : retained ≤ unwanted := le_of_not_ge huv
      rw [abs_of_nonneg (sub_nonneg.mpr huv')] at h
      refine ⟨retained - preservation, ?_⟩
      change removal ≤ dist (retained - preservation) unwanted ∧
        dist (retained - preservation) retained ≤ preservation
      rw [Real.dist_eq, Real.dist_eq,
        abs_of_nonpos (show retained - preservation - unwanted ≤ 0 by linarith),
        abs_of_nonpos (show retained - preservation - retained ≤ 0 by linarith)]
      constructor <;> linarith

/-- At zero removal threshold the whole ball can be feasible even though
the paper's unqualified whole-ball criterion fails. -/
theorem zero_removal_whole_ball_counterexample :
    geometricFeasibleRegion (0 : ℝ) 0 0 1 = Metric.closedBall 0 1 ∧
      ¬ (1 ≤ dist (0 : ℝ) 0) := by
  constructor
  · exact geometricFeasibleRegion_zero_removal 0 0 1
  · simp

end StatisticalUnlearning
