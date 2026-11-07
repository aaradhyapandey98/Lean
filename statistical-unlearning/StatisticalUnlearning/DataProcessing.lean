import StatisticalUnlearning.Testing
import Mathlib.MeasureTheory.Integral.Lebesgue.Map

/-!
# Deterministic data processing for testing trade-offs

This module proves the measurable-function special case of the forward
data-processing direction discussed in Theorem 19 of arXiv:2605.16645v1.
It does not prove the Markov-kernel case or the Blackwell converse.
The real-valued representation bridge for `tradeOff` remains open.
-/

set_option autoImplicit false

open MeasureTheory
open scoped ENNReal

namespace StatisticalUnlearning

universe u v

variable {Ω : Type u} {Ω' : Type v} [MeasurableSpace Ω] [MeasurableSpace Ω']

/-- Pull a randomized test back along a measurable observation map. -/
def pullbackTest (f : Ω → Ω') (hf : Measurable f) (φ : RandomizedTest Ω') :
    RandomizedTest Ω where
  toFun := φ.toFun ∘ f
  measurable_toFun := φ.measurable_toFun.comp hf
  le_one := fun x => φ.le_one (f x)

/-- A test has the same type-I error before and after pulling it back. -/
theorem typeIError_map (P : ProbabilityMeasure Ω) (f : Ω → Ω')
    (hf : Measurable f) (φ : RandomizedTest Ω') :
    typeIError (P.map hf.aemeasurable) φ = typeIError P (pullbackTest f hf φ) := by
  change (∫⁻ y, φ.toFun y ∂Measure.map f (P : Measure Ω)) =
    ∫⁻ x, φ.toFun (f x) ∂(P : Measure Ω)
  exact lintegral_map φ.measurable_toFun hf

/-- A test has the same type-II error before and after pulling it back. -/
theorem typeIIError_map (Q : ProbabilityMeasure Ω) (f : Ω → Ω')
    (hf : Measurable f) (φ : RandomizedTest Ω') :
    typeIIError (Q.map hf.aemeasurable) φ = typeIIError Q (pullbackTest f hf φ) := by
  change (∫⁻ y, (1 - φ.toFun y) ∂Measure.map f (Q : Measure Ω)) =
    ∫⁻ x, (1 - φ.toFun (f x)) ∂(Q : Measure Ω)
  exact lintegral_map (measurable_const.sub φ.measurable_toFun) hf

/-- A measurable transformation cannot make two distributions easier to test. -/
theorem tradeOff_map_ge (P Q : ProbabilityMeasure Ω) (f : Ω → Ω')
    (hf : Measurable f) (α : SignificanceLevel) :
    tradeOff P Q α ≤ tradeOff (P.map hf.aemeasurable) (Q.map hf.aemeasurable) α := by
  unfold tradeOff
  refine le_iInf fun φ => le_iInf fun hφ => ?_
  have hfeasible : typeIError P (pullbackTest f hf φ) ≤ (α : ℝ≥0∞) := by
    rw [← typeIError_map P f hf φ]
    exact hφ
  calc
    (⨅ (ψ : RandomizedTest Ω) (_ : typeIError P ψ ≤ (α : ℝ≥0∞)), typeIIError Q ψ)
        ≤ typeIIError Q (pullbackTest f hf φ) :=
      iInf_le_of_le (pullbackTest f hf φ) (iInf_le_of_le hfeasible le_rfl)
    _ = typeIIError (Q.map hf.aemeasurable) φ := (typeIIError_map Q f hf φ).symm

/-- Measurable relabeling preserves the entire encoded trade-off curve. -/
theorem tradeOff_map_equiv (P Q : ProbabilityMeasure Ω) (e : Ω ≃ᵐ Ω')
    (α : SignificanceLevel) :
    tradeOff (P.map e.measurable.aemeasurable) (Q.map e.measurable.aemeasurable) α =
      tradeOff P Q α := by
  have hP : (P.map e.measurable.aemeasurable).map e.symm.measurable.aemeasurable = P := by
    apply Subtype.ext
    change ((P : Measure Ω).map e).map e.symm = (P : Measure Ω)
    exact Measure.map_symm_map e
  have hQ : (Q.map e.measurable.aemeasurable).map e.symm.measurable.aemeasurable = Q := by
    apply Subtype.ext
    change ((Q : Measure Ω).map e).map e.symm = (Q : Measure Ω)
    exact Measure.map_symm_map e
  apply le_antisymm
  · simpa only [hP, hQ] using
      tradeOff_map_ge (P.map e.measurable.aemeasurable) (Q.map e.measurable.aemeasurable)
        e.symm e.symm.measurable α
  · exact tradeOff_map_ge P Q e e.measurable α

end StatisticalUnlearning
