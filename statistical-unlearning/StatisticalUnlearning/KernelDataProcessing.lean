import StatisticalUnlearning.DataProcessing
import Mathlib.Probability.Kernel.Composition.MeasureComp
import Mathlib.Probability.Kernel.MeasurableLIntegral

/-! Forward data processing for randomized Markov kernels. This concerns the
ENNReal encoding and the real-valued testing trade-off. The Blackwell
converse is not established here. -/

set_option autoImplicit false
open MeasureTheory ProbabilityTheory
open scoped ENNReal ProbabilityTheory

namespace StatisticalUnlearning
universe u v
variable {Ω : Type u} {Ω' : Type v} [MeasurableSpace Ω] [MeasurableSpace Ω']

/-- Apply a Markov kernel to a probability law. -/
noncomputable def kernelLaw (κ : Kernel Ω Ω') [IsMarkovKernel κ]
    (P : ProbabilityMeasure Ω) : ProbabilityMeasure Ω' :=
  ⟨κ ∘ₘ (P : Measure Ω), inferInstance⟩

/-- Average a randomized test over the Markov kernel. -/
noncomputable def kernelPullbackTest (κ : Kernel Ω Ω') [IsMarkovKernel κ]
    (φ : RandomizedTest Ω') : RandomizedTest Ω where
  toFun := fun x => ∫⁻ y, φ.toFun y ∂κ x
  measurable_toFun := φ.measurable_toFun.lintegral_kernel
  le_one := by
    intro x
    calc
      (∫⁻ y, φ.toFun y ∂κ x) ≤ ∫⁻ _y, (1 : ℝ≥0∞) ∂κ x := lintegral_mono φ.le_one
      _ = 1 := by simp

/-- Kernel randomization preserves type-I error under pullback. -/
theorem typeIError_kernel (κ : Kernel Ω Ω') [IsMarkovKernel κ]
    (P : ProbabilityMeasure Ω) (φ : RandomizedTest Ω') :
    typeIError (kernelLaw κ P) φ = typeIError P (kernelPullbackTest κ φ) := by
  change (∫⁻ y, φ.toFun y ∂((P : Measure Ω).bind κ)) =
    ∫⁻ x, (∫⁻ y, φ.toFun y ∂κ x) ∂(P : Measure Ω)
  exact Measure.lintegral_bind κ.aemeasurable φ.measurable_toFun.aemeasurable

/-- Complementing an averaged test agrees with averaging its complement. -/
theorem kernelPullback_complement (κ : Kernel Ω Ω') [IsMarkovKernel κ]
    (φ : RandomizedTest Ω') (x : Ω) :
    (∫⁻ y, (1 - φ.toFun y) ∂κ x) = 1 - (kernelPullbackTest κ φ).toFun x := by
  have hle : (∫⁻ y, φ.toFun y ∂κ x) ≤ 1 := (kernelPullbackTest κ φ).le_one x
  have hfinite : (∫⁻ y, φ.toFun y ∂κ x) ≠ ∞ :=
    ne_top_of_le_ne_top (by simp) hle
  have hsub := lintegral_sub φ.measurable_toFun hfinite (ae_of_all (κ x) φ.le_one)
  simpa [kernelPullbackTest] using hsub

/-- Kernel randomization preserves type-II error under pullback. -/
theorem typeIIError_kernel (κ : Kernel Ω Ω') [IsMarkovKernel κ]
    (Q : ProbabilityMeasure Ω) (φ : RandomizedTest Ω') :
    typeIIError (kernelLaw κ Q) φ = typeIIError Q (kernelPullbackTest κ φ) := by
  change (∫⁻ y, (1 - φ.toFun y) ∂((Q : Measure Ω).bind κ)) =
    ∫⁻ x, (1 - (kernelPullbackTest κ φ).toFun x) ∂(Q : Measure Ω)
  rw [Measure.lintegral_bind κ.aemeasurable (measurable_const.sub φ.measurable_toFun).aemeasurable]
  simp_rw [kernelPullback_complement]

/-- Markov post-processing cannot decrease the encoded testing trade-off. -/
theorem tradeOff_kernel_ge (κ : Kernel Ω Ω') [IsMarkovKernel κ]
    (P Q : ProbabilityMeasure Ω) (α : SignificanceLevel) :
    tradeOff P Q α ≤ tradeOff (kernelLaw κ P) (kernelLaw κ Q) α := by
  unfold tradeOff
  refine le_iInf fun φ => le_iInf fun hφ => ?_
  have hfeasible : typeIError P (kernelPullbackTest κ φ) ≤ (α : ℝ≥0∞) := by
    rw [← typeIError_kernel κ P φ]
    exact hφ
  calc
    (⨅ (ψ : RandomizedTest Ω) (_ : typeIError P ψ ≤ (α : ℝ≥0∞)), typeIIError Q ψ)
        ≤ typeIIError Q (kernelPullbackTest κ φ) :=
      iInf_le_of_le (kernelPullbackTest κ φ) (iInf_le_of_le hfeasible le_rfl)
    _ = typeIIError (kernelLaw κ Q) φ := (typeIIError_kernel κ Q φ).symm

/-- The kernel-to-order direction of Appendix A.5, Theorem 19, expressed
directly using Definition 1's real-valued tests and expectations.

This does not establish the converse direction of Blackwell ordering. -/
theorem real_tradeOff_kernel_ge (κ : Kernel Ω Ω') [IsMarkovKernel κ]
    (P Q : ProbabilityMeasure Ω) (α : SignificanceLevel) :
    sInf {r : ℝ | ∃ f : Ω → ℝ, Measurable f ∧
      (∀ x, 0 ≤ f x ∧ f x ≤ 1) ∧
      (∫ x, f x ∂(P : Measure Ω)) ≤ (α : ℝ≥0∞).toReal ∧
      r = ∫ x, (1 - f x) ∂(Q : Measure Ω)} ≤
    sInf {r : ℝ | ∃ f : Ω' → ℝ, Measurable f ∧
      (∀ x, 0 ≤ f x ∧ f x ≤ 1) ∧
      (∫ x, f x ∂((kernelLaw κ P) : Measure Ω')) ≤ (α : ℝ≥0∞).toReal ∧
      r = ∫ x, (1 - f x) ∂((kernelLaw κ Q) : Measure Ω')} := by
  rw [← tradeOff_eq_real_test_infimum P Q α,
    ← tradeOff_eq_real_test_infimum (kernelLaw κ P) (kernelLaw κ Q) α]
  exact ENNReal.toReal_mono
    (ne_top_of_le_ne_top (by simp : (1 : ℝ≥0∞) ≠ ∞)
      (tradeOff_le_one (kernelLaw κ P) (kernelLaw κ Q) α))
    (tradeOff_kernel_ge κ P Q α)

end StatisticalUnlearning
