import Mathlib.MeasureTheory.Integral.Lebesgue.Basic
import Mathlib.MeasureTheory.Measure.ProbabilityMeasure

/-!
# Randomized testing: the foundation of Definition 1

Source: Pandey and Kulkarni, arXiv:2605.16645v1, Definition 1, equation (1).

We use `ℝ≥0∞` for error probabilities and the nonnegative integral. Every test
is measurable and bounded by one. This avoids an implicit integrability
assumption and makes the infimum a complete-lattice infimum. Test levels are
restricted to `[0,1]`. A real-valued reformulation and the full characterization
of trade-off functions are future work.
-/

set_option autoImplicit false

open MeasureTheory
open scoped ENNReal

namespace StatisticalUnlearning

universe u

/-- The significance levels in Definition 1. -/
abbrev SignificanceLevel := Set.Icc (0 : ℝ≥0∞) 1

/-- A measurable randomized rejection probability taking values in `[0,1]`. -/
structure RandomizedTest (Ω : Type u) [MeasurableSpace Ω] where
  toFun : Ω → ℝ≥0∞
  measurable_toFun : Measurable toFun
  le_one : ∀ x, toFun x ≤ 1

variable {Ω : Type u} [MeasurableSpace Ω]

/-- The test which never rejects the null hypothesis. -/
def zeroTest : RandomizedTest Ω where
  toFun := fun _ => 0
  measurable_toFun := measurable_const
  le_one := fun _ => zero_le _

/-- Type-I error: the rejection probability under the null distribution. -/
noncomputable def typeIError (P : ProbabilityMeasure Ω) (φ : RandomizedTest Ω) : ℝ≥0∞ :=
  ∫⁻ x, φ.toFun x ∂(P : Measure Ω)

/-- Type-II error: the acceptance probability under the alternative distribution. -/
noncomputable def typeIIError (Q : ProbabilityMeasure Ω) (φ : RandomizedTest Ω) : ℝ≥0∞ :=
  ∫⁻ x, (1 - φ.toFun x) ∂(Q : Measure Ω)

/-- Encoding of Definition 1, equation (1), in nonnegative extended real
arithmetic. The real-valued integral/infimum equivalence is not yet proved. -/
noncomputable def tradeOff (P Q : ProbabilityMeasure Ω)
    (α : SignificanceLevel) : ℝ≥0∞ :=
  ⨅ (φ : RandomizedTest Ω) (_ : typeIError P φ ≤ (α : ℝ≥0∞)), typeIIError Q φ

/-- The never-reject test has zero type-I error. -/
@[simp] theorem typeIError_zero (P : ProbabilityMeasure Ω) :
    typeIError P (zeroTest (Ω := Ω)) = 0 := by
  simp [typeIError, zeroTest]

/-- The never-reject test has unit type-II error under a probability measure. -/
@[simp] theorem typeIIError_zero (Q : ProbabilityMeasure Ω) :
    typeIIError Q (zeroTest (Ω := Ω)) = 1 := by
  simp [typeIIError, zeroTest]

/-- Increasing the allowed type-I error can only decrease the optimal type-II error.
This is one elementary property of Definition 1, not its full characterization. -/
theorem tradeOff_antitone (P Q : ProbabilityMeasure Ω) :
    Antitone (tradeOff P Q) := by
  intro α β hαβ
  unfold tradeOff
  refine le_iInf fun φ => le_iInf fun hφ => ?_
  exact iInf_le_of_le φ (iInf_le_of_le (le_trans hφ hαβ) le_rfl)

/-- The objective of Definition 1 is at most one: the zero test is feasible. -/
theorem tradeOff_le_one (P Q : ProbabilityMeasure Ω) (α : SignificanceLevel) :
    tradeOff P Q α ≤ 1 := by
  have hzero : typeIError P (zeroTest (Ω := Ω)) ≤ (α : ℝ≥0∞) := by simp
  calc
    tradeOff P Q α ≤ typeIIError Q (zeroTest (Ω := Ω)) :=
      iInf_le_of_le (zeroTest (Ω := Ω)) (iInf_le_of_le hzero le_rfl)
    _ = 1 := typeIIError_zero Q

end StatisticalUnlearning
