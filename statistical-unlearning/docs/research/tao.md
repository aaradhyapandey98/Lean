# Terence Tao: formalization practices to adopt

Reviewed 2026-11-06. This is a source-based workflow note, not an endorsement by Tao or a claim to have acquired all his expertise. Practices below are our adaptation to this project.

## 1. Treat statement fidelity as a separate deliverable

Tao's [Analysis I repository](https://github.com/teorth/analysis/blob/main/README.md) aims to track its source text, while recording changes needed for Mathlib compatibility. It explains, for example, changes in sequence indexing and the use of total functions with values outside the mathematical domain.

For this paper, record each source statement, exact quantifiers, ambient measurable spaces, probability assumptions, and any departure from its notation. Review the Lean theorem type independently of the proof. Examples and counterexamples should test subtle definitions before a large proof depends on them. These are project choices inspired by the source's attention to correspondence; the repository does not prescribe this exact checklist.

The Analysis I companion deliberately leaves exercises as `sorry`. That pedagogical choice is unsuitable for this project's verified library. Keep unfinished work in the blueprint or task ledger, outside the certified target.

## 2. Maintain an explanation linked to actual declarations

The [Equational Theories contribution guide](https://github.com/teorth/equational_theories/blob/main/CONTRIBUTING.md) describes blueprint links (`\lean{...}`), dependencies (`\uses{...}`), and separate `\leanok` markers for statements and proofs. It treats Lean code as the ground truth for equation status and uses CI to compile contributions.

Adopt stable identifiers connecting paper items, prose, Lean declarations, and dependency edges. A declaration having a formal statement and a declaration having a checked proof must be different visible states. The website should extract code from repository files rather than maintain an independently editable proof copy. CI should verify the mapping, build all intended modules, and reject stale status claims. Preserve human-readable explanations when reorganizing code.

## 3. Decompose proofs into reviewable steps

Tao's [2025 line-by-line formalization demonstration](https://www.youtube.com/watch?v=cyyR7j2ChCI), and his own [Lean Zulip explanation](https://leanprover-community.github.io/archive/stream/219941-Machine-Learning-for-Theorem-Proving/topic/Tools.20for.20semi-automated.20line-by-line.20formalization.html), illustrate translating an existing informal argument into small Lean subgoals, then using tactics and manual adjustment.

Our adaptation: split the statistical argument at meaningful mathematical interfaces; assign a precise lemma statement before sending it to an agent; run Lean after small changes; preserve the explanation of why each lemma is needed. Automated tactics may supply proof terms, but the compiler output and reviewed theorem statement determine acceptance. The demonstration's `canonical` tactic is an optional external tool, not a prerequisite or guaranteed part of Mathlib.

## 4. Budget for review and reusable library work

Tao's [official index of his machine-assistance posts](https://terrytao.wordpress.com/mastodon-posts/) points to his June 21, 2026 discussion of review, Mathlib-quality refactoring, and issue design becoming the bottleneck. It also distinguishes proof generation, verification, and digestion. The individual Mastodon pages did not expose useful full text through the retrieval tool, so this note relies only on the descriptions in his official index.

Allocate separate tasks for translating statements, finding existing Mathlib APIs, proving lemmas, reviewing assumptions, and explaining results. Agent throughput must not set the number of results labeled complete. The [PFR repository](https://github.com/teorth/pfr) provides a concrete model combining a blueprint, Lean documentation, build instructions, and work toward upstreaming reusable results to Mathlib.

## Attribution and limits

The October 9, 2026 post [What mathematicians should know about the Lean Theorem Prover: questions of reliability and AI](https://terrytao.wordpress.com/2026/10/09/what-mathematicians-should-know-about-the-lean-theorem-proverquestions-of-reliability-and-ai/) is a **Thomas Hales guest post** hosted on Tao's blog. It distinguishes kernel checking from human review of statement correspondence. Cite Hales for that article, rather than presenting it as authored by Tao. Its broader claims about kernel history are outside this workflow note and have not been independently audited here.
