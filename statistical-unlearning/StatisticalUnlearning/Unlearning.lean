import StatisticalUnlearning.Testing

/-!
# Distributional unlearning and its feasible region

Source: Pandey and Kulkarni, arXiv:2605.16645v1, Definitions 2 and 3,
equation (2), and the consistency paragraph in Section 2.1.

The order lemmas below use the concrete testing definition from `Testing.lean`.
Their proofs use only transitivity of pointwise order. We permit arbitrary
baseline curves; the paper further restricts them to realizable trade-off
functions. Hence these elementary order lemmas apply, in particular, to every
baseline allowed by the paper. No realizability characterization is claimed.
-/

set_option autoImplicit false

open MeasureTheory
open scoped ENNReal

namespace StatisticalUnlearning

universe u

/-- A baseline curve; realizability as a trade-off function is not asserted. -/
abbrev Baseline := SignificanceLevel → ℝ≥0∞

variable {Ω : Type u} [MeasurableSpace Ω]

/-- The two inequalities of Definition 2, equation (2), generalized to arbitrary
baseline curves. Membership in a distribution family and realizability of the
baselines are not encoded by this predicate. -/
def Unlearns (p unwanted retained : ProbabilityMeasure Ω)
    (removal preservation : Baseline) : Prop :=
  tradeOff p unwanted ≤ removal ∧ preservation ≤ tradeOff p retained

/-- Section 2.1 consistency: weakening both requirements preserves unlearning. -/
theorem Unlearns.mono {p unwanted retained : ProbabilityMeasure Ω}
    {removal preservation removal' preservation' : Baseline}
    (h : Unlearns p unwanted retained removal preservation)
    (hremoval : removal ≤ removal') (hpreservation : preservation' ≤ preservation) :
    Unlearns p unwanted retained removal' preservation' :=
  ⟨le_trans h.1 hremoval, le_trans hpreservation h.2⟩

/-- The edited-distribution membership and inequalities of Definition 3, for
arbitrary baselines. The paper additionally places the reference distributions
in the family and requires realizable trade-off baselines. -/
def feasibleRegion (family : Set (ProbabilityMeasure Ω))
    (unwanted retained : ProbabilityMeasure Ω) (removal preservation : Baseline) :
    Set (ProbabilityMeasure Ω) :=
  {p | p ∈ family ∧ Unlearns p unwanted retained removal preservation}

/-- Membership in the generalized encoded region unfolds to the displayed
family membership and the two trade-off inequalities. -/
@[simp] theorem mem_feasibleRegion {family : Set (ProbabilityMeasure Ω)}
    {p unwanted retained : ProbabilityMeasure Ω} {removal preservation : Baseline} :
    p ∈ feasibleRegion family unwanted retained removal preservation ↔
      p ∈ family ∧ tradeOff p unwanted ≤ removal ∧ preservation ≤ tradeOff p retained :=
  Iff.rfl

/-- Weakening the requirements enlarges Definition 3's feasible region. -/
theorem feasibleRegion_mono {family : Set (ProbabilityMeasure Ω)}
    {unwanted retained : ProbabilityMeasure Ω}
    {removal preservation removal' preservation' : Baseline}
    (hremoval : removal ≤ removal') (hpreservation : preservation' ≤ preservation) :
    feasibleRegion family unwanted retained removal preservation ⊆
      feasibleRegion family unwanted retained removal' preservation' := by
  intro p hp
  exact ⟨hp.1, hp.2.mono hremoval hpreservation⟩

end StatisticalUnlearning
