# Formalization roadmap

## Milestone 0: a reproducible foundation

1. **Done:** pin Lean and mathlib, resolve and commit `lake-manifest.json`, and obtain a successful CI build.
2. **Done for the current 26 declarations:** check axioms and bind audit results to exact source hashes.
3. Independently review Definitions 1–3; prove the ENNReal/real representation bridge and the trade-off range and feasible-test nonemptiness facts.
4. **Reader built and tested:** publish the split-pane reader with statuses derived from build evidence.

## Milestone 1: hypothesis testing

Develop the genuine randomized testing API on measurable probability spaces: zero and constant tests, [0,1] bounds, antitonicity in type-I budget, identical-distribution trade-off, and invariance under measurable equivalence. State endpoint conventions explicitly.

Then formalize generalized inverses (Appendix A.4), forward data processing, and comparison principles. Any Blackwell converse must carry the exact measurable-space regularity required by its source; arbitrary measurable spaces must not be assumed adequate without proof.

## Milestone 2: finite-dimensional Gaussian geometry

Separate the probability reduction from geometry. First prove the feasible-set description in the correct Mahalanobis metric, with explicit positive definiteness and α, ε domains. Prove nonemptiness, full-ball and Pareto claims with α=0 and coincident-center cases handled separately. Connect the geometry to the actual Gaussian trade-off only after that bridge is proved.

## Milestone 3: composition and downstream guarantees

Prove product-testing comparisons, well-defined tensor composition, and the distributional-unlearning composition lemma. Establish downstream guarantees using actual Markov kernels, not a postulated monotonicity axiom. Track dependencies on Neyman–Pearson and Blackwell results.

## Milestone 4: other population families

Treat log-concave location families, Poisson, and multiple populations. Resolve support/identifiability and union-of-interval issues first. Generalized inverse conventions, discreteness, and distribution orientation require explicit tests. Gaussian white noise and Hilbert-space results need a separate Cameron–Martin development and nontrivial-space cases.

## Milestone 5: algorithms and concentration

Formalize independent sampling and edited-data algorithms before concentration bounds. Audit finite-sample constants, confidence allocation, positive sample sizes, and all denominators. Reconcile the random-removal proof's confidence bookkeeping; direct pooled-Gaussian concentration may supply a cleaner proof.

## Definition of done

A paper result is complete only when its precise source correspondence is reviewed, its Lean declaration compiles at a pinned revision, its full axiom dependency set is allowed, and its website entry links to the actual declaration. Auxiliary lemmas and definitions do not count as completed main paper theorems.
