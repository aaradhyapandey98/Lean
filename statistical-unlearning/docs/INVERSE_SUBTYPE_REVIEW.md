# Independent review: Lemma 17 subtype interface

Reviewed 8 November 2026 against
[arXiv:2605.16645v1, Appendix A.4, Lemma 17](https://arxiv.org/html/2605.16645v1#A4)
and `StatisticalUnlearning/Inverse.lean` on branch `inverse-paper-interface`.

**Review status:** an independent assistant agent reviewed the statement and proof interface
separately from the implementation pass. This is source-fidelity review, not a Lean kernel
check and not a human peer review.

## Source reconstruction

Let `I = [0,1]`. The source assumes `f g : I → I` are nonincreasing and satisfy
`f x ≤ g x` for every `x : I`. For `t : I`, it defines the generalized inverse of
`h : I → I` as the infimum of `{x : I | h x ≤ t}`, with the explicit convention that
the empty infimum is `1`. The conclusion is `f⁻¹(t) ≤ g⁻¹(t)`.

The proof is the sublevel inclusion
`{x : I | g x ≤ t} ⊆ {x : I | f x ≤ t}`. The inequality direction in the source is
correct. Antitonicity and the codomain restriction are not needed for this inclusion,
but retaining them in the source-facing wrapper makes the correspondence explicit.

## Lean correspondence

- `UnitInterval` is exactly the subtype `Set.Icc (0 : ℝ) 1`.
- `unitIntervalExtend` agrees with its input on that subtype; values outside the interval
  cannot affect `leftInverse`.
- `unitIntervalSublevel_image` identifies the real sublevel set with the coercion image of
  the paper's subtype-level sublevel set.
- `unitIntervalLeftInverse_eq_sInf_of_nonempty` proves the ordinary nonempty-infimum case.
- `unitIntervalLeftInverse_eq_one_of_empty` proves the source's explicit empty-set convention.
- `unitIntervalLeftInverse_mono` proves the stronger order implication without antitonicity.
- `generalizedInverse_order_paper` restores the exact source-shaped hypotheses and domain.

## Assessment and limits

No reversed inequality, omitted source domain, hidden conclusion-shaped hypothesis, or source
error was found. The source-facing corollary is a faithful instance of the stronger core theorem.
Compilation and transitive-axiom results must be recorded separately for the exact final revision.
This review does not establish Remark 18's inverse identity for trade-off functions, Theorem 19's
Blackwell converse, or any later statistical dependency.
