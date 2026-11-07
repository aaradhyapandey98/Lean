import Mathlib.Topology.MetricSpace.Basic
import Mathlib.Tactic.Linarith

/-!
# Metric prerequisites for feasible-region geometry

Source: Pandey and Kulkarni, arXiv:2605.16645v1, Proposition 3,
equations (7) and (8), and its geometric discussion.

This file proves only metric geometry. It does not identify Gaussian
trade-off inequalities with distance inequalities. That statistical
correspondence is a separate, currently unproved bridge.

The paper uses Mahalanobis distances, or ordinary distances after whitening.
The statements here apply to any pseudometric space. In particular, they do
not require a vector space, a probability measure, or a Gaussian law.
-/

set_option autoImplicit false

namespace StatisticalUnlearning

universe u

variable {X : Type u} [PseudoMetricSpace X]

/-- The distance constraints underlying the Gaussian feasible region after the
statistical correspondence has been established. No such correspondence is
asserted by this definition. -/
def geometricFeasibleRegion (unwanted retained : X)
    (removal preservation : ℝ) : Set X :=
  {x | removal ≤ dist x unwanted ∧ dist x retained ≤ preservation}

/-- Membership is exactly the two metric inequalities. -/
@[simp] theorem mem_geometricFeasibleRegion
    {x unwanted retained : X} {removal preservation : ℝ} :
    x ∈ geometricFeasibleRegion unwanted retained removal preservation ↔
      removal ≤ dist x unwanted ∧ dist x retained ≤ preservation :=
  Iff.rfl

/-- Every feasible point lies in the retained closed ball. -/
theorem geometricFeasibleRegion_subset_closedBall
    (unwanted retained : X) (removal preservation : ℝ) :
    geometricFeasibleRegion unwanted retained removal preservation ⊆
      Metric.closedBall retained preservation := by
  intro x hx
  exact hx.2

/-- A zero removal threshold imposes no restriction: the entire retained
closed ball is feasible, including when its radius is negative and it is empty.
This covers the zero-threshold boundary omitted by the paper's stated
whole-ball equivalence. -/
theorem geometricFeasibleRegion_zero_removal
    (unwanted retained : X) (preservation : ℝ) :
    geometricFeasibleRegion unwanted retained 0 preservation =
      Metric.closedBall retained preservation := by
  ext x
  change (0 ≤ dist x unwanted ∧ dist x retained ≤ preservation) ↔
    dist x retained ≤ preservation
  constructor
  · intro hx
    exact hx.2
  · intro hx
    exact ⟨dist_nonneg, hx⟩

/-- Triangle inequality gives the necessary removal bound for an individual
feasible point. No sign assumptions on the two thresholds are needed. -/
theorem removal_le_separation_add_preservation
    {x unwanted retained : X} {removal preservation : ℝ}
    (hx : x ∈ geometricFeasibleRegion unwanted retained removal preservation) :
    removal ≤ dist unwanted retained + preservation := by
  have htriangle := dist_triangle x retained unwanted
  rw [dist_comm retained unwanted] at htriangle
  have hremoval : removal ≤ dist x unwanted := hx.1
  have hpreservation : dist x retained ≤ preservation := hx.2
  linarith

/-- A nonempty geometric feasible region necessarily satisfies the triangle
bound. This is the necessary direction of the paper's nonemptiness criterion;
no existence or Gaussian probability claim is made. -/
theorem geometricFeasibleRegion_nonempty_implies_bound
    {unwanted retained : X} {removal preservation : ℝ}
    (h : (geometricFeasibleRegion unwanted retained removal preservation).Nonempty) :
    removal ≤ dist unwanted retained + preservation := by
  rcases h with ⟨x, hx⟩
  exact removal_le_separation_add_preservation hx

/-- If the centers are separated by at least the sum of the thresholds,
every point of the retained closed ball satisfies the removal constraint.
Only sufficiency is claimed; for removal zero the region is the entire ball
without this additional separation condition. -/
theorem geometricFeasibleRegion_eq_closedBall_of_add_le
    {unwanted retained : X} {removal preservation : ℝ}
    (hseparation : removal + preservation ≤ dist unwanted retained) :
    geometricFeasibleRegion unwanted retained removal preservation =
      Metric.closedBall retained preservation := by
  apply Set.Subset.antisymm
  · exact geometricFeasibleRegion_subset_closedBall unwanted retained removal preservation
  · intro x hx
    have hpreservation : dist x retained ≤ preservation := hx
    have htriangle := dist_triangle unwanted x retained
    rw [dist_comm unwanted x] at htriangle
    have hremoval : removal ≤ dist x unwanted := by
      linarith
    exact ⟨hremoval, hpreservation⟩

end StatisticalUnlearning
