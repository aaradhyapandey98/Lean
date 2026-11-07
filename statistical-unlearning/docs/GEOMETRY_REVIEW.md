# Independent review of the metric geometry module

Review date: 6 November 2026. Reviewed `StatisticalUnlearning/Geometry.lean`, SHA-256 `dacd896f55c441d6f586ec2b567fd0494b5bfd8f734e387f5bea47097311fb8c`.

**Verdict:** the definition and all six theorem statements are mathematically correct. The hypotheses do not conceal a Gaussian theorem or the desired conclusion. This is an independent source and proof-script review, **not a compiler or kernel certificate**. No local `lean` or `lake` executable was available to this reviewer.

## Statements and assumptions

The ambient assumptions are a type and `PseudoMetricSpace` instance. This appropriately supplies nonnegative symmetric real distances and the triangle inequality. Distinct points need not have positive distance, and no vector-space, dimension, measure, or probability hypotheses are introduced. The real thresholds are unrestricted; each proof remains valid for negative thresholds.

| Declaration | Mathematical content | Review |
| --- | --- | --- |
| `mem_geometricFeasibleRegion` | Membership is the conjunction used in the definition. | Correct by definitional equality; not a substantive statistical result. |
| `geometricFeasibleRegion_subset_closedBall` | Every feasible point satisfies the preservation constraint. | Correct projection of the second conjunct. |
| `geometricFeasibleRegion_zero_removal` | At removal threshold zero, the region equals the retained closed ball. | Correct by distance nonnegativity, also when the preservation radius is negative and both sets are empty. |
| `removal_le_separation_add_preservation` | A feasible point implies the triangle bound. | Correct from `dist x unwanted ≤ dist x retained + dist retained unwanted`, symmetry, and the two constraints. |
| `geometricFeasibleRegion_nonempty_implies_bound` | A nonempty region implies that same bound. | Correct extraction of a feasible point; no converse is asserted. |
| `geometricFeasibleRegion_eq_closedBall_of_add_le` | Separation at least the sum of thresholds makes the retained ball feasible. | Correct from `dist unwanted retained ≤ dist unwanted x + dist x retained`. Its separation hypothesis is a sufficient condition, not advertised as necessary. |

The proof scripts use direct unfolding, conjunctions, symmetry, triangle inequalities and linear arithmetic in the expected directions. I found no apparent proof-script error on inspection. Compilation must still establish the relevant names, elaboration, and imported API behavior.

## Relationship to the paper

Source target: [Proposition 3, Section 3.1, equations (7)–(8)](https://arxiv.org/html/2605.16645v1#S3.SS1), plus its geometric discussion. The module properly distinguishes metric prerequisites from the unproved bridge identifying Gaussian trade-off comparisons with Mahalanobis distance comparisons.

The zero-removal theorem isolates the valid boundary behavior that the printed whole-ball equivalence misses. The final theorem proves only its valid sufficient direction. The necessary nonemptiness bound does not claim full Proposition 3: arbitrary pseudometric spaces need not provide extremizers. For example, a singleton with both centers equal, removal threshold `1/2`, and preservation threshold `1` satisfies the numerical triangle bound but has an empty feasible region.

Mahalanobis geometry requires a separate metric instance or a proved whitening correspondence before this module can be applied to general positive-definite covariance matrices. Neither that construction nor any Gaussian probability calculation is implemented here.

## Integration requirements

Import the module from `StatisticalUnlearning.lean`, register each declaration in the project manifest, generate its axiom queries, compile the complete library, and bind the resulting evidence to the exact source/configuration hashes. These are pending integration checks, not objections to the mathematical statements. Until they pass, the website should display these entries as unverified source.
