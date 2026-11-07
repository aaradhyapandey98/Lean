# Axiom reference and proof validation

Researched 2026-11-06. These are observations from primary sources, not an independent audit of Axiom's mathematical library. No Axiom tool has yet checked this project's proofs.

## Reader design: observed features

The accessible [Stacks site root](https://stacks.axiommath.ai/) documents a searchable tag library, per-declaration code tabs when several declarations share one source tag, links to Lean source and graph, dependencies and reverse dependencies, and separate natural-language citations. Its graph exposes both Lean and natural-language edges, declaration-type filters, and chapter/section navigation.

The exact requested deep link, <https://stacks.axiommath.ai/library?tag=0CY1>, failed retrieval in both the web lookup and direct HTTP (403). Consequently, the precise layout and content of tag `0CY1` were **not** visually inspected. Axiom's [release article](https://axiommath.ai/research/the-stacks-project-formalized/) explicitly describes original text alongside corresponding Lean code and an interactive dependency graph. It also emphasizes clean abstractions, stable interfaces and coordinated integration for parallel formalization.

**Design recommendations (our choices, not claims about the reference):** use stable paper IDs rather than mutable line positions; keep mathematical text on the left and the selected declaration on the right; give each result a permalink; show a persistent verification-status label and assumptions drawer; display an honest placeholder when no formal declaration exists; use source excerpts generated from the checked Lean files rather than hand-copied code. On a narrow screen, use Text / Lean tabs. Preserve accessible contrast, keyboard navigation and readable mathematical typography.

## Separate proof checking from mathematical review

[AxiomMath/Stacks README](https://github.com/AxiomMath/Stacks) distinguishes human-reviewed `StacksCore` from AI-generated `StacksFrontier`. It says both tiers have kernel-checked proofs and claims no `sorry` or `native_decide`. Human review concerns correspondence to the source and library quality as well as proof acceptance. This project should keep **kernel status** and **statement review status** as separate fields; an AI-written accepted proof is not evidence that its statement faithfully expresses the paper.

For a paper result, record the paper version and locator, formal statement, explicit hypotheses, Lean declaration, direct dependencies, computed axiom set, build evidence and statement-review status. Never use a percentage of small helper lemmas as the percentage of the paper verified.

## Lean's documented validation ladder

The [official Lean validation reference](https://lean-lang.org/doc/reference/latest/ValidatingProofs/) distinguishes validity of a formal proof from the meaning of its statement. Recommended project checks:

1. Build the relevant modules without errors or warnings.
2. Run `#print axioms` on each published result and inspect transitive dependencies. Allow only `propext`, `Classical.choice`, and `Quot.sound` under the initial policy; reject `sorryAx` and every other axiom.
3. Add `lean4checker --fresh` in CI when supported by the pinned toolchain. It replays stored proofs through Lean's kernel.
4. Consider comparator and an external checker for stronger independent checks after the formal statements have been reviewed.

Native evaluation's audit signature varies with Lean version. Since 4.29, native computation introduces dedicated axioms, often with `_native` in the name; `Lean.trustCompiler` was removed in 4.35. An explicit three-axiom allowlist is more reliable than searching only for the old name. Do not claim external checker completion before running it.

## AXLE: useful, optional infrastructure

[AXLE documentation](https://api.axle.axiommath.ai/v1/docs/) exposes proof verification, declaration extraction, proof-state extraction, renaming and proof manipulation through Python, CLI and HTTP. Its [release announcement](https://axiommath.ai/research/releasing-axle/) presents it as a hosted service. It is a possible development aid; a reproducible locally pinned Lean project should remain the primary deliverable.

[`verify_proof`](https://api.axle.axiommath.ai/v1/docs/tools/verify_proof/) compares candidate declarations with an independently supplied formal statement and checks completeness and axiom use. Its documented defaults allow only Lean's standard three axioms. Keep `permitted_sorries` empty and `allow_statement_axioms` / `allow_bv_decide` false. Pin the environment and retain returned processed code, because default import handling may replace imports. The tool explicitly documents limitations against adversarial metaprogramming and recommends additional checking for untrusted proofs. Its formal statement may contain proof placeholders, but such placeholders must never enter this project's accepted proof library.

[`check`](https://api.axle.axiommath.ai/v1/docs/tools/check/) reports compilation. Its `okay: true` can coexist with `sorry`, disallowed axioms, or unsafe definitions. Therefore that boolean alone must never produce a verified badge. Prefer `verify_proof` for a pass/fail decision, and preserve exact output and environment when it is used.

## Scope of this research

These notes establish documented workflows and information architecture. They do not establish that every Axiom declaration matches its informal source, that proprietary AxiomProver is available here, or that Axiom's entire system has been reproduced. No account creation, external upload or service integration was performed.
