# Statistical Unlearning — a Lean companion

An ongoing formalization of **Statistical Unlearning of Distributions: A Hypothesis Testing Approach**, Aaradhya Pandey and Sanjeev Kulkarni, [arXiv:2605.16645v1](https://arxiv.org/abs/2605.16645v1).

This project has two deliverables: a Lean library with explicit assumptions, and an accessible paper/proof reader in `site/`. This is an initial foundation, **not a verification of the complete paper**.

## Current trust status

- Lean source is authored without proof placeholders or project-specific axioms.
- The current proof snapshot compiled in [GitHub Actions run 42396622510](https://github.com/aaradhyapandey98/Lean/actions/runs/42396622510), Lean 4.24.0 with the pinned mathlib revision. All **67 registered declarations** passed the transitive-axiom audit. These include definitions and auxiliary results; independent source-fidelity review of the newer statements is outstanding.
- A green source scan is not a proof certificate. Only a successful Lean build and axiom audit for matching source may set a declaration's site status to **checked**.
- Formal statement fidelity is reviewed separately from compilation. The Definition 1 real-test and infimum bridge has been checked, subject to independent source review. The Blackwell converse, divergence ordering, tensor properties, and composition remain open.
- Suspected and independently reviewed source issues are recorded in `docs/PAPER_AUDIT.md` and `docs/INDEPENDENT_REVIEW.md`. These are mathematical review notes, not machine-checked counterexamples.

## Work on the library

Install [Lean via elan](https://lean-lang.org/install/), then, from this directory:

```sh
lake exe cache get
lake build
python3 scripts/check_integrity.py structural
python3 scripts/check_integrity.py generate-audit --declarations declarations.json --output StatisticalUnlearning/Audit.lean
mkdir -p .audit
lake env lean StatisticalUnlearning/Audit.lean > .audit/axioms.log
python3 scripts/check_integrity.py verify-audit --declarations declarations.json --log .audit/axioms.log --json-output .audit/axioms.json
python3 scripts/build_site.py --evidence .audit/axioms.json
```

The retained result is [verification/last-audit.json](verification/last-audit.json), bound to the exact source/configuration hashes and linked to the successful CI run. To reproduce the checked reader without rebuilding, `python3 scripts/build_site.py --evidence verification/last-audit.json`; this fails if the current Lean sources or pinned configuration differ. Rebuilding and auditing remain the proof-validation steps.

The audit accepts only `propext`, `Classical.choice`, and `Quot.sound`. These are foundational Lean/mathlib axioms, not statistical assumptions. Exact axiom use is displayed per declaration. Statistical hypotheses belong in visible theorem statements, not opaque structures or assumed conclusions.

`lake-manifest.json` was recovered from the successful CI dependency resolution and pins mathlib plus its transitive packages. Use `lake build` for routine work. Run `lake update` deliberately when updating dependencies, review the lockfile diff, and rebuild.

## Read the companion

Open `site/index.html`, or serve the folder locally:

```sh
python3 -m http.server 8000 --directory site
```

The left pane explains a statement and its source; the right pane shows the actual Lean source. Search, status filters, deep links, dependency links, and a mobile reading mode support navigation. Entry counts are not a percentage of paper coverage. Browser layout QA remains pending; syntax, accessibility structure, and functional DOM tests passed.

## Continue across sessions

Start with `docs/SESSION_HANDOFF.md`, `docs/ROADMAP.md`, and `AGENTS.md`. Never infer proof status from a previous chat. Rebuild the exact revision and inspect the generated evidence.

## Sources and reuse

The paper is cited above; its arXiv v1 page states CC BY 4.0. Research notes link the primary Lean, Scott Armstrong, Terence Tao, and Axiom sources that informed the workflow. No endorsement or review by those people or organizations is claimed. Project code is MIT licensed; the original paper and linked third-party materials retain their own licenses.
