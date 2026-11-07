# Independent statement review

Review date: 6 November 2026. Target source: [arXiv:2605.16645v1](https://arxiv.org/html/2605.16645v1), Definitions 1–3 and the consistency paragraph following Definition 2. This review is separate from proof authorship and compilation.

## Source interface

Definition 1 uses measurable randomized tests on a common measurable space with values in the real interval `[0,1]`. Its trade-off at a significance level in `[0,1]` is the infimum of type-II error under a type-I constraint. The order of its probability distributions matters: type-I error is under the first distribution; type-II error is under the second.

Definition 2 compares the edited-to-unwanted trade-off from above against the removal baseline, and the edited-to-retained trade-off from below against the preservation baseline. Both baselines are themselves trade-off functions. Definition 3 additionally restricts the edited distribution to the specified family.

The consistency observation weakens these requirements by increasing the removal baseline or decreasing the preservation baseline.

## Reviewed declarations and verdict

Reviewed `StatisticalUnlearning/Testing.lean` and `StatisticalUnlearning/Unlearning.lean` independently of their author. This is a source/semantics review; it does not supply a compiler or kernel-replay result.

**Verdict:** the definitions correctly express a nonnegative extended-real testing problem and a generalized unlearning predicate. The displayed proofs do not add assumptions that conceal mathematical obligations. Full equivalence with the paper's real-valued Definition 1 and the admissible baseline interface is **not yet formalized**. The complete paper is not verified.

| Checked feature | Observation |
| --- | --- |
| Probability distributions | `ProbabilityMeasure Ω` supplies the probability-measure requirement on one measurable space. No extraneous topological or countability assumptions appear. |
| Tests | `RandomizedTest` requires measurability and a pointwise upper bound of one. Nonnegativity is built into `ℝ≥0∞`; the upper bound excludes infinity. |
| Significance | `SignificanceLevel` is the interval from zero to one in `ℝ≥0∞`. There is no assertion about off-source significance levels. |
| Error orientation | `typeIError P φ` integrates rejection under `P`; `typeIIError Q φ` integrates acceptance under `Q`. The order agrees with the source. |
| Infimum | `tradeOff P Q α` takes the infimum over all tests and their type-I feasibility proofs. This encodes an infimum over a constraint set. |
| Nonempty constraint set | `typeIError_zero` shows that the never-reject test is feasible for each significance level. |
| Finite trade-off value | `tradeOff_le_one` uses that test to prove an upper bound of one. Nonnegativity follows from the codomain. Thus the trade-off value itself is finite. |
| Removal/preservation order | `Unlearns` uses `tradeOff p unwanted ≤ removal` and `preservation ≤ tradeOff p retained`, in the correct directions. |
| Family restriction | `feasibleRegion` includes `p ∈ family`. Membership of the two reference distributions in that family is not part of this generalized predicate; a literal source interface must supply it externally or restrict its inputs. |
| Baseline restriction | `Baseline` is an arbitrary extended-real curve. The file explicitly records that no realizability property is enforced. |

## Inputs of the proved elementary statements

The following is an assumption review, not a substitute for running Lean. Implicit carrier and measurable-space inputs are typing data. `ProbabilityMeasure` inputs match the source's distribution requirement.

| Declaration | Logical premises beyond typing/distribution data | Assessment |
| --- | --- | --- |
| `typeIError_zero` | None | Direct evaluation of the defined integral. |
| `typeIIError_zero` | None | Direct evaluation under a probability measure. |
| `tradeOff_antitone` | None | Proves antitonicity of the encoded infimum; does not assume an optimum exists. |
| `tradeOff_le_one` | None | Proves the bound from a feasible test; does not assume it. |
| `Unlearns.mono` | Existing unlearning, increased removal baseline, decreased preservation baseline | These are precisely the inputs of the source's consistency observation. |
| `mem_feasibleRegion` | None | Definitional unfolding, not an independent statistical theorem. |
| `feasibleRegion_mono` | Increased removal baseline, decreased preservation baseline | Valid elementary consequence of the generalized predicate. |

No convexity, continuity, Gaussian formula, Blackwell theorem, or main feasible-region characterization is established by these declarations.

## Representation obligations to check

A nonnegative extended-real encoding can be useful for an infimum of nonnegative errors, but it requires explicit bridges before it is identified with the paper's real-valued function:

1. Correspondence of measurable tests valued in `[0,1]` with measurable `ℝ≥0∞`-valued functions bounded by one, in both directions.
2. Equality between real expectations and the nonnegative integrals used for both errors, including compatibility of `1 - φ` with truncated subtraction.
3. A nonempty feasible test set at every allowed significance level, with errors bounded by one and finite.
4. Compatibility of the two infimum constructions and their orders after conversion; a result about the encoded infimum is not itself that bridge.
5. Restriction of the significance parameter to `[0,1]` when comparing to the original statement. Values outside the source domain should be treated as an extension.
6. Baseline admissibility: predicates accepting arbitrary functions may be useful generalizations, but the original source-facing definition requires baselines that arise as trade-off functions.
7. The chosen family and relevant probability-measure hypotheses must remain explicit at the source interface.

These are representation and correspondence obligations, not identified errors in the paper. A first Lean library can honestly prove useful encoded statements while listing these obligations as outstanding.

## Wording recommendation

When exposing these declarations on the website or in a status table, use **encoded foundation** or **generalized baseline predicate**, and describe the elementary results individually. Restricting arbitrary baselines to realizable ones does not require a new proof of the order lemmas, but identifying the encoded trade-off function with the original one requires the representation bridges above. A brief code docstring naming Definition 2 or 3 should be read together with the file's stated extension; future documentation should make that distinction local to each source-facing declaration.
