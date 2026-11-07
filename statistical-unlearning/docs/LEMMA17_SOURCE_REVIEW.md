# Lemma 17: source-correspondence review

Target: [arXiv:2605.16645v1, Appendix A.4, Lemma 17](https://arxiv.org/html/2605.16645v1). Reviewed source: `StatisticalUnlearning/Inverse.lean`, blob `83e8edd2bb72902aea97825030a9e05524464fef`, in PR #2 at commit `446b93b4824c523aa5bdcc5e3665ac737087df95`.

**Review status: second pass by the same assistant that authored the proof; not an independent reviewer.** This note records the comparison and its limits. It cannot satisfy the project's independent-review requirement on its own.

## Reconstruction

Let I = [0,1] and A(h,t) = {x ∈ I : h(x) ≤ t}. The source sets the generalized inverse to inf A(h,t) when A(h,t) is nonempty, and to 1 when it is empty. For functions f ≤ g pointwise on I, A(g,t) ⊆ A(f,t). Thus their generalized inverses satisfy f⁻¹(t) ≤ g⁻¹(t). The paper assumes f and g are nonincreasing I → I and restricts t to I.

## Declaration-by-declaration comparison

- `inverseSublevel f t` is {1} ∪ A(f,t); its predicate has both interval endpoints and the correct ≤ threshold.
- `leftInverse_eq_sInf_of_nonempty` establishes that adjoining 1 does not alter the infimum when A(f,t) is nonempty. The reason is that every member of A(f,t) is ≤ 1.
- `leftInverse_eq_one_of_empty` establishes exactly the paper's empty-set convention.
- `leftInverse_mono` assumes f(x) ≤ g(x) for all x ∈ I and concludes the inverse inequality in the source direction. Its type places f and g on all of ℝ and permits all real t. Its definition and premise inspect the functions only on I.
- Every source function I → I can be extended to ℝ → ℝ, for example by assigning 0 outside I. On I, the extension preserves both function values and the source ordering. Such an extension need not be nonincreasing globally, which is harmless: the Lean theorem does not require global or local monotonicity. The independence of the inverse from values outside I follows mathematically from the displayed set definition; a source-facing subtype extension/interface theorem has not yet been added to Lean.
- The source's monotonicity and codomain restrictions are not needed for this set-inclusion implication. Their omission strengthens the result and does not conceal a source hypothesis.
- `leftInverse_nonneg`, `leftInverse_le_one`, and `leftInverse_antitone` are separate general properties; they are not necessary for the proof of the source lemma.

## Evidence and remaining checks

[CI run 42339473157](https://github.com/aaradhyapandey98/Lean/actions/runs/42339473157) compiled the source at `03f521a85499a43d07b631b1bfda35aa929be95c` and checked 35 declarations against the project axiom allowlist. The later evidence and documentation commit does not change the Lean source; its final CI run also succeeded. The proof of Lemma 17 is distinct from Remark 18's unproved trade-off inversion identity.

**Assessment:** the displayed generalized result and the two convention lemmas mathematically imply Lemma 17, via the extension argument above. No incorrect inequality direction, hidden conclusion-shaped premise, or extra mathematical assumption was found in this pass. A formal subtype-facing corollary and an independent source-fidelity review remain desirable before treating this as the final reviewer-facing interface.
