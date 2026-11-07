import Mathlib.MeasureTheory.Integral.Bochner.Basic
import Mathlib.MeasureTheory.Integral.Lebesgue.Basic
import Mathlib.MeasureTheory.Integral.Lebesgue.Sub
import Mathlib.MeasureTheory.Measure.ProbabilityMeasure

/-!
# Randomized testing: the foundation of Definition 1

Source: Pandey and Kulkarni, arXiv:2605.16645v1, Definition 1, equation (1).

We use `ℝ≥0∞` for error probabilities and the nonnegative integral. Every test
is measurable and bounded by one. This avoids an implicit integrability
assumption and makes the infimum a complete-lattice infimum. Test levels are
restricted to `[0,1]`. The real-valued test, error, feasibility and infimum
correspondence is proved below. The full characterization remains future work.
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

/-- A constant randomized test at a permitted significance level. -/
def constantTest (α : SignificanceLevel) : RandomizedTest Ω where
  toFun := fun _ => α
  measurable_toFun := measurable_const
  le_one := fun _ => α.2.2

/-- Type-I error: the rejection probability under the null distribution. -/
noncomputable def typeIError (P : ProbabilityMeasure Ω) (φ : RandomizedTest Ω) : ℝ≥0∞ :=
  ∫⁻ x, φ.toFun x ∂(P : Measure Ω)

/-- Type-II error: the acceptance probability under the alternative distribution. -/
noncomputable def typeIIError (Q : ProbabilityMeasure Ω) (φ : RandomizedTest Ω) : ℝ≥0∞ :=
  ∫⁻ x, (1 - φ.toFun x) ∂(Q : Measure Ω)

/-- Encoding of Definition 1, equation (1), in nonnegative extended real
arithmetic. See `tradeOff_eq_real_test_infimum` for the real-valued formulation. -/
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

@[simp] theorem typeIError_constant (P : ProbabilityMeasure Ω) (α : SignificanceLevel) :
    typeIError P (constantTest (Ω := Ω) α) = α := by
  simp [typeIError, constantTest]

@[simp] theorem typeIIError_constant (Q : ProbabilityMeasure Ω) (α : SignificanceLevel) :
    typeIIError Q (constantTest (Ω := Ω) α) = 1 - (α : ℝ≥0∞) := by
  simp [typeIIError, constantTest]

/-- Every trade-off curve lies below the diagonal, by a constant random test. -/
theorem tradeOff_le_diagonal (P Q : ProbabilityMeasure Ω) (α : SignificanceLevel) :
    tradeOff P Q α ≤ 1 - (α : ℝ≥0∞) := by
  have h : typeIError P (constantTest (Ω := Ω) α) ≤ (α : ℝ≥0∞) := by simp
  calc
    tradeOff P Q α ≤ typeIIError Q (constantTest (Ω := Ω) α) :=
      iInf_le_of_le (constantTest (Ω := Ω) α) (iInf_le_of_le h le_rfl)
    _ = 1 - (α : ℝ≥0∞) := typeIIError_constant Q α

/-- Under identical distributions, the two errors sum to one. -/
theorem typeIIError_eq_one_sub_typeIError (P : ProbabilityMeasure Ω)
    (φ : RandomizedTest Ω) : typeIIError P φ = 1 - typeIError P φ := by
  have hle : (∫⁻ x, φ.toFun x ∂(P : Measure Ω)) ≤ 1 := by
    calc
      (∫⁻ x, φ.toFun x ∂(P : Measure Ω)) ≤ ∫⁻ _x, (1 : ℝ≥0∞) ∂(P : Measure Ω) :=
        lintegral_mono φ.le_one
      _ = 1 := by simp
  have hfinite : (∫⁻ x, φ.toFun x ∂(P : Measure Ω)) ≠ ∞ :=
    ne_top_of_le_ne_top (by simp) hle
  have hsub := lintegral_sub φ.measurable_toFun hfinite
    (ae_of_all (P : Measure Ω) φ.le_one)
  simpa [typeIIError, typeIError] using hsub

/-- The encoded trade-off curve of a distribution with itself is the diagonal. -/
theorem tradeOff_self (P : ProbabilityMeasure Ω) (α : SignificanceLevel) :
    tradeOff P P α = 1 - (α : ℝ≥0∞) := by
  apply le_antisymm (tradeOff_le_diagonal P P α)
  unfold tradeOff
  refine le_iInf fun φ => le_iInf fun hφ => ?_
  rw [typeIIError_eq_one_sub_typeIError]
  exact tsub_le_tsub_left hφ 1

/-- At type-I budget one, zero type-II error is achievable. -/
theorem tradeOff_one (P Q : ProbabilityMeasure Ω) :
    tradeOff P Q ⟨1, by simp⟩ = 0 := by
  apply le_antisymm
  · simpa using tradeOff_le_diagonal P Q ⟨1, by simp⟩
  · exact zero_le _

/-- Every paper-style real measurable test has an encoded counterpart. -/
theorem real_test_to_encoded (f : Ω → ℝ) (hf : Measurable f)
    (hrange : ∀ x, 0 ≤ f x ∧ f x ≤ 1) :
    ∃ φ : RandomizedTest Ω, ∀ x, φ.toFun x = ENNReal.ofReal (f x) := by
  refine ⟨⟨fun x => ENNReal.ofReal (f x),
    ENNReal.measurable_ofReal.comp hf, ?_⟩, fun _ => rfl⟩
  intro x
  simpa using ENNReal.ofReal_le_ofReal (hrange x).2

/-- Every encoded test corresponds pointwise to a measurable real test in [0,1]. -/
theorem encoded_test_to_real (φ : RandomizedTest Ω) :
    ∃ f : Ω → ℝ, Measurable f ∧ (∀ x, 0 ≤ f x ∧ f x ≤ 1) ∧
      ∀ x, ENNReal.ofReal (f x) = φ.toFun x := by
  refine ⟨fun x => (φ.toFun x).toReal,
    ENNReal.measurable_toReal.comp φ.measurable_toFun, ?_, ?_⟩
  · intro x
    exact ⟨ENNReal.toReal_nonneg,
      by simpa using ENNReal.toReal_mono (by simp : (1 : ℝ≥0∞) ≠ ∞) (φ.le_one x)⟩
  · intro x
    exact ENNReal.ofReal_toReal
      (ne_top_of_le_ne_top (by simp : (1 : ℝ≥0∞) ≠ ∞) (φ.le_one x))

/-- The real rejection expectation equals the encoded type-I error. -/
theorem typeIError_real (P : ProbabilityMeasure Ω) (φ : RandomizedTest Ω)
    (f : Ω → ℝ) (hf : Measurable f) (hrange : ∀ x, 0 ≤ f x ∧ f x ≤ 1)
    (hφ : ∀ x, φ.toFun x = ENNReal.ofReal (f x)) :
    (∫ x, f x ∂(P : Measure Ω)) = (typeIError P φ).toReal := by
  have hfun : (fun x => ENNReal.ofReal (f x)) = φ.toFun := by
    funext x
    exact (hφ x).symm
  have hn : 0 ≤ᵐ[(P : Measure Ω)] f := ae_of_all _ (fun x => (hrange x).1)
  simpa only [hfun, typeIError] using
    (integral_eq_lintegral_of_nonneg_ae hn hf.aestronglyMeasurable)

/-- The real acceptance expectation equals the encoded type-II error. -/
theorem typeIIError_real (Q : ProbabilityMeasure Ω) (φ : RandomizedTest Ω)
    (f : Ω → ℝ) (hf : Measurable f) (hrange : ∀ x, 0 ≤ f x ∧ f x ≤ 1)
    (hφ : ∀ x, φ.toFun x = ENNReal.ofReal (f x)) :
    (∫ x, (1 - f x) ∂(Q : Measure Ω)) = (typeIIError Q φ).toReal := by
  have hfun : (fun x => ENNReal.ofReal (1 - f x)) =
      (fun x => 1 - φ.toFun x) := by
    funext x
    rw [ENNReal.ofReal_sub 1 (hrange x).1, ENNReal.ofReal_one, ← hφ x]
  have hn : 0 ≤ᵐ[(Q : Measure Ω)] (fun x => 1 - f x) :=
    ae_of_all _ (fun x => sub_nonneg.mpr (hrange x).2)
  have hm : Measurable (fun x => 1 - f x) := measurable_const.sub hf
  simpa only [hfun, typeIIError] using
    (integral_eq_lintegral_of_nonneg_ae hn hm.aestronglyMeasurable)

/-- A test's type-I error is finite and at most one under a probability law. -/
theorem typeIError_le_one (P : ProbabilityMeasure Ω) (φ : RandomizedTest Ω) :
    typeIError P φ ≤ 1 := by
  calc
    typeIError P φ ≤ ∫⁻ _x, (1 : ℝ≥0∞) ∂(P : Measure Ω) :=
      lintegral_mono φ.le_one
    _ = 1 := by simp

/-- A test's type-II error is finite and at most one under a probability law. -/
theorem typeIIError_le_one (Q : ProbabilityMeasure Ω) (φ : RandomizedTest Ω) :
    typeIIError Q φ ≤ 1 := by
  calc
    typeIIError Q φ ≤ ∫⁻ _x, (1 : ℝ≥0∞) ∂(Q : Measure Ω) :=
      lintegral_mono (fun _ => tsub_le_self)
    _ = 1 := by simp

/-- Corresponding real and encoded tests obey the same type-I constraint. -/
theorem real_test_feasible_iff (P : ProbabilityMeasure Ω) (φ : RandomizedTest Ω)
    (f : Ω → ℝ) (hf : Measurable f) (hrange : ∀ x, 0 ≤ f x ∧ f x ≤ 1)
    (hφ : ∀ x, φ.toFun x = ENNReal.ofReal (f x)) (α : SignificanceLevel) :
    (∫ x, f x ∂(P : Measure Ω)) ≤ (α : ℝ≥0∞).toReal ↔
      typeIError P φ ≤ (α : ℝ≥0∞) := by
  rw [typeIError_real P φ f hf hrange hφ]
  exact ENNReal.toReal_le_toReal
    (ne_top_of_le_ne_top (by simp : (1 : ℝ≥0∞) ≠ ∞) (typeIError_le_one P φ))
    (ne_top_of_le_ne_top (by simp : (1 : ℝ≥0∞) ≠ ∞) α.2.2)

/-- The encoded trade-off, converted to ℝ, is the real infimum over
encoded feasible tests. Identifying this index type with real tests uses the
separate conversion and feasibility correspondence results. -/
theorem tradeOff_toReal_eq_iInf (P Q : ProbabilityMeasure Ω) (α : SignificanceLevel) :
    (tradeOff P Q α).toReal =
      ⨅ φ : {φ : RandomizedTest Ω // typeIError P φ ≤ (α : ℝ≥0∞)},
        (typeIIError Q φ.1).toReal := by
  have h : tradeOff P Q α =
      ⨅ φ : {φ : RandomizedTest Ω // typeIError P φ ≤ (α : ℝ≥0∞)},
        typeIIError Q φ.1 := by
    simp only [tradeOff, iInf_subtype']
  rw [h]
  exact ENNReal.toReal_iInf (fun φ =>
    ne_top_of_le_ne_top (by simp : (1 : ℝ≥0∞) ≠ ∞) (typeIIError_le_one Q φ.1))

/-- Definition 1, equation (1): the encoded curve equals the infimum over
the paper's real measurable randomized tests and their real expectations. -/
theorem tradeOff_eq_real_test_infimum (P Q : ProbabilityMeasure Ω)
    (α : SignificanceLevel) :
    (tradeOff P Q α).toReal =
      sInf {r : ℝ | ∃ f : Ω → ℝ, Measurable f ∧
        (∀ x, 0 ≤ f x ∧ f x ≤ 1) ∧
        (∫ x, f x ∂(P : Measure Ω)) ≤ (α : ℝ≥0∞).toReal ∧
        r = ∫ x, (1 - f x) ∂(Q : Measure Ω)} := by
  rw [tradeOff_toReal_eq_iInf, ← sInf_range]
  congr 1
  ext r
  constructor
  · rintro ⟨⟨φ, hfeas⟩, hval⟩
    obtain ⟨f, hf, hrange, hrep⟩ := encoded_test_to_real φ
    have hφ : ∀ x, φ.toFun x = ENNReal.ofReal (f x) := fun x => (hrep x).symm
    refine ⟨f, hf, hrange, (real_test_feasible_iff P φ f hf hrange hφ α).2 hfeas, ?_⟩
    exact hval.symm.trans (typeIIError_real Q φ f hf hrange hφ).symm
  · rintro ⟨f, hf, hrange, hfeas, hval⟩
    obtain ⟨φ, hφ⟩ := real_test_to_encoded f hf hrange
    refine ⟨⟨φ, (real_test_feasible_iff P φ f hf hrange hφ α).1 hfeas⟩, ?_⟩
    exact (typeIIError_real Q φ f hf hrange hφ).symm.trans hval.symm

end StatisticalUnlearning
