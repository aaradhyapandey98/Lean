# Session handoff

Started 6 November 2026 (America/New_York). Continue this project from the repository, not recollections of a chat.

## Repository and layout

Repository: https://github.com/aaradhyapandey98/Lean

Project directory: `statistical-unlearning/`. Workflow: `.github/workflows/unlearning.yml` at the repository root. Development branch: `formalize-statistical-unlearning`.

Paper target: [arXiv:2605.16645v1](https://arxiv.org/abs/2605.16645v1), not an unpinned future revision.

## What exists

- Actual measure-level randomized tests, type-I/type-II errors and an ENNReal trade-off infimum.
- Generalized unlearning and feasible-region predicates, with their source-interface limitations stated explicitly.
- Seven testing/order lemmas, plus six elementary metric geometry lemmas. These are foundations, not completed main paper theorems.
- Declaration registry, strict source scan, transitive axiom-audit parser and source-bound evidence generator.
- A dependency-free paper/proof reader with search, status filters and actual Lean source excerpts.
- Paper inventory, independent statement and geometry reviews, source audit, and research notes from primary Armstrong/Tao/Axiom/Lean sources.

## Build evidence

The initial Testing and Unlearning modules compiled with `lake build --wfail` in [run 42334954883](https://github.com/aaradhyapandey98/Lean/actions/runs/42334954883), source commit `2cb3932b6b7696f1d4b71ec49f9470ff5cf5b745`. That run did not audit axioms or build the later Geometry module.

Lean is pinned to `leanprover/lean4:v4.24.0`, mathlib to `f897ebcf72cd16f89ab4577d0c826cd14afaafc7`, with the actual CI-generated `lake-manifest.json` retained. A later complete build/audit must be recorded below before claiming more.

The initial authoring environment has no Lean executable, and its toolchain/CDN requests return 403. Remote GitHub Actions successfully provided the Lean build. Site syntax and functional DOM tests passed; no pixel-level browser layout test has been performed.

## Next mathematical work

1. Prove the ENNReal ↔ real-valued test, expectation and infimum bridges. Add the source-facing admissible-baseline and family-membership interface.
2. Prove the identical-distribution trade-off and forward data processing using actual measures and kernels.
3. Develop the Gaussian testing identity and Mahalanobis correspondence; only then identify the geometric model with the paper's feasible region.
4. Formalize reviewed boundary corrections and finite counterexamples before adopting affected printed claims.

Read `PAPER_AUDIT.md`, `INDEPENDENT_REVIEW.md`, `STATEMENT_REVIEW.md` and `GEOMETRY_REVIEW.md` before extending statements. Several source issues were independently confirmed informally. Do not silently correct them or advertise those informal counterexamples as Lean-checked.

## Continuation protocol

From the repository root, `cd statistical-unlearning`. Read `AGENTS.md`, build the exact revision, regenerate the audit from `declarations.json`, and inspect every transitive axiom report. Use the README commands. A site badge is permitted only when the evidence source snapshot matches exactly.

Assign disjoint modules to agents and arrange independent statement review. Commit source, lockfile, evidence, generated reader and an updated handoff together after successful checks. Avoid upgrading the toolchain at the same time as a mathematical extension unless necessary.

## Latest complete verification

**Latest draft PR #2:** [run 42339473157](https://github.com/aaradhyapandey98/Lean/actions/runs/42339473157), source revision `03f521a85499a43d07b631b1bfda35aa929be95c`, built all four library modules and audited 35 registered declarations with only `propext`, `Classical.choice`, and `Quot.sound`. The inverse ordering and the empty/nonempty infimum cases compile. An independent source-fidelity review of the new declarations remains outstanding. The website manifest and `verification/last-audit.json` were refreshed from that run; the source hashes must still match before a reader badge is trusted.

**Passed:** [GitHub Actions run 42335449513](https://github.com/aaradhyapandey98/Lean/actions/runs/42335449513), source revision `7233527933bdea3d5b46b1228ea7a55c2bb31684`.

- All three library modules compiled with `lake build --wfail`: 13 elementary lemmas.
- All 26 registry entries passed `#print axioms` inspection; the union of their dependencies is exactly `propext`, `Classical.choice`, `Quot.sound`.
- Source hygiene, 18 integrity unit tests, JavaScript syntax checks and the 24-entry reader's functional DOM tests passed.
- Retained evidence: `verification/last-audit.json`, extracted verbatim from the successful run. The checked reader is generated from this evidence and actual Lean files.
- The complete paper remains unverified; the real/ENNReal correspondence and source-facing interface are the immediate next tasks. Geometry remains separate from the unproved Gaussian testing correspondence.

The publication commit may differ from the checked source revision because it adds evidence, generated reader data and this handoff. The evidence hashes bind every Lean file, toolchain, Lake configuration, lockfile and declaration registry. Do not treat a changed Lean file as covered by this result.

## Real and encoded randomized tests — draft

Branch `testing-real-representation` starts from PR #7 head `192f3dade235fbc50658612c69f1bdac9c96d9bc`. It proposes real-to-ENNReal and ENNReal-to-real pointwise conversions for measurable tests valued in [0,1]. CI must check the exact revision before either direction is regarded as proved; source fidelity and independent review are outstanding. These statements do not establish expectation, type-I constraint, infimum, or trade-off equivalence, the Blackwell converse, divergence ordering, tensor properties, or composition. Local Lean is unavailable; use PR-triggered GitHub Actions for the pinned build and axiom audit. Existing evidence must not certify changed sources.

The two test conversions passed [CI run 42379758110](https://github.com/aaradhyapandey98/Lean/actions/runs/42379758110) on PR head `e4386cd13ce54306a350a9fe6b58d15b315e4fc1`, including the transitive-axiom audit. Subsequent changes propose real integral correspondences for both errors; those later declarations need their own build and audit. Full infimum correspondence remains open.

**Verified progress:** [CI run 42380026409](https://github.com/aaradhyapandey98/Lean/actions/runs/42380026409), PR head `d3967d950b6a121a447d5710a87bd2dd5078b068` (tested merge `2792e088326c856384b3eac3005ab513144c54b9`), passed the full Lean build, structural checks and axiom audit for 57 declarations. Newly checked: `real_test_to_encoded`, `encoded_test_to_real`, `typeIError_real`, `typeIIError_real`. The expectation equalities assume a real measurable [0,1]-valued test and its pointwise representation; the conversion theorems establish representations in both directions. A literal constrained-infimum bridge, source interface, independent review, Blackwell converse, divergence result, tensor, and composition remain unfinished. The reader and retained audit evidence are from the linked CI run and are bound to the Lean/configuration snapshot, not to subsequent source changes. No target-1 paper theorem is claimed complete by these results.

## Integration checkpoint — 7 November 2026

Branch `statistical-unlearning-integrated-proofs` integrates the proof content of draft PRs #2, #3, #4, #6, #7, #9 and #10 with the website and tests from main `77413e267795be6aa55b5dee72895f9653e02d12`. It retains the distinctions in their descriptions: real geometry is not a statistical region theorem; the inverse congruence is a supporting fact; testing bridges do not prove constrained-infimum correspondence or the Blackwell converse. This is an integration checkpoint, not a claim that these results have completed independent source review. CI and a new audit on this combined Lean snapshot are required. The previous source-bound evidence is stale for this combined source until regenerated. MathJax draft PR #8 is not integrated; its documented rendering and missing-asset errors remain unresolved.

**Combined CI:** [run 42382449741](https://github.com/aaradhyapandey98/Lean/actions/runs/42382449741) passed `lake build --wfail`, structural and site checks, and the transitive-axiom audit on PR head `4031505013e6450700fde18d040ca9c0011da2b4` (tested merge `2072f714b7edfcaa722fd29767ab806f261dff86`): 61 declarations, only `propext`, `Classical.choice`, and `Quot.sound`. Merge commit `1802deb5daa382afa95ff5aaf18e1f89a46fbd5e` preserved the same source tree and records the geometry, inverse-congruence, and main histories. The retained evidence and generated reader are taken from the linked run and bound to the Lean and configuration files by hash. Source-fidelity review remains outstanding; the integration branch is not a claim of paper completeness. PR #8's MathJax issues remain unresolved. No separate PR has been marked merged or published on main.

## Testing feasibility bridge — draft

Branch `testing-feasibility-bridge`, based on integrated head `9fa123328dba09fb9c7692e29a4e8941f8e195ed`, proposes bounds on both testing errors and equivalence of real and encoded type-I feasibility for corresponding tests. These changes require their own Lean build, axiom audit and source review. The complete constrained-infimum correspondence, Blackwell converse, divergence ordering, tensor properties and composition remain open. The prior audit is stale for the altered Lean snapshot.

The error bounds and feasibility equivalence passed [CI run 42385437049](https://github.com/aaradhyapandey98/Lean/actions/runs/42385437049) for head `8bfc67e634ef6ecf68c121f1bd6340cf8981e8c8`. A subsequent proposed theorem rewrites the encoded trade-off as a real infimum indexed by encoded feasible tests; that additional declaration needs a new Lean build and audit. Identifying the result with a separately defined real-test infimum, source review, and the target 1 paper theorems remain open.

The real infimum over encoded feasible tests passed [CI run 42385666913](https://github.com/aaradhyapandey98/Lean/actions/runs/42385666913) for head `c0aa67342125be7824aec65f1d4c956c4af941ad`. The subsequent proposed source-facing theorem equating that infimum to the real-test Definition 1 set needs a fresh build and audit. Independent review and all the major comparison, divergence, tensor, and composition obligations remain open.
