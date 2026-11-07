# Scott Armstrong: practices relevant to this project

Research checked on **6 November 2026**. The person identified is the mathematician Scott Armstrong, whose [official site](https://www.scottnarmstrong.com/) identifies his CNRS–Sorbonne affiliation and links his formalization work. This note records selected practices; it does not certify his repositories, promise a completion time, or claim that every skill has been installed.

## Pinned resources

The official [LeanAutoformalizationSkills repository](https://github.com/scottnarmstrong/LeanAutoformalizationSkills) was inspected at commit [`1837b95b3d5a9fd8d311367603902ad7fe261adf`](https://github.com/scottnarmstrong/LeanAutoformalizationSkills/commit/1837b95b3d5a9fd8d311367603902ad7fe261adf), dated 25 October 2026. Its original instructions and helpers are licensed CC BY 4.0. No files from that collection were installed or vendored by this research task. Any later copying must retain its attribution and license and identify modifications.

| Primary resource | What was learned |
| --- | --- |
| [Skill collection README](https://github.com/scottnarmstrong/LeanAutoformalizationSkills/blob/1837b95b3d5a9fd8d311367603902ad7fe261adf/README.md) | Covers architecture, discovery, proof work, audit, coordination and release; instructions do not themselves install Lean or provide proof search. |
| [Statement audit](https://github.com/scottnarmstrong/LeanAutoformalizationSkills/blob/1837b95b3d5a9fd8d311367603902ad7fe261adf/skills/lean-statement-audit/SKILL.md) | Compare the exact declaration with the source, including all binders and definition bodies. |
| [Orchestrator](https://github.com/scottnarmstrong/LeanAutoformalizationSkills/blob/1837b95b3d5a9fd8d311367603902ad7fe261adf/skills/lean-orchestrator/SKILL.md) | Delegate bounded tasks with owned files, exact targets and explicit validation; separate proving from independent review. |
| [Dependency graph](https://github.com/scottnarmstrong/LeanAutoformalizationSkills/blob/1837b95b3d5a9fd8d311367603902ad7fe261adf/skills/build-proof-dependency-graph/SKILL.md) | Extract mathematical dependencies from pinned source; graph structure does not establish Lean proof status. |
| [Search discovery](https://github.com/scottnarmstrong/LeanAutoformalizationSkills/blob/1837b95b3d5a9fd8d311367603902ad7fe261adf/skills/lean-search-discovery/SKILL.md) | Search Mathlib before reproving results; check the actual type, namespace and import of every candidate. |

## Application to statistical unlearning

1. Maintain a source-to-declaration table. Record the paper version and exact result locator, formal statement, assumptions, known restrictions, and evidence. A theorem with an additional conclusion-shaped premise is only a conditional helper.
2. Audit each explicit, implicit and instance assumption. Armstrong's audit classifies inputs as source premises, standing assumptions, typing information, author rulings, or excess. Reject excess premises in paper-facing results. Inspect bundled structures and aliases so they cannot conceal obligations.
3. Inspect definitions as mathematical objects. A correctly typed arbitrary/default object does not establish that the definition means the paper's object. Check domains, normalization, endpoints, measurability and quantifier scope. When uniqueness is the source's defining characterization, prove existence and uniqueness and export that characterization.
4. Give each worker a small result and disjoint write set; keep shared definitions and integration under one owner. A fresh reviewer checks source correspondence independently of the proof writer. Build and axiom output establish different facts from semantic review; report both.
5. Keep the theorem inventory/dependency plan distinct from a verification ledger. An edge states an obligation, and a file or graph node is not a proof. Label finite-space specializations and infrastructure lemmas explicitly.
6. Use local `rg`, Lean inspection and search tactics to discover library results; verify their full statements. Convert exploratory searches into explicit maintained proof terms.

These are recommendations for this project, not a claim that Armstrong's complete approval, hashing, quarantine or kernel-replay infrastructure is already implemented. His frozen-anchor workflow requires approval of exact Lean declarations and carefully quarantines permitted draft holes; it should only be advertised after those mechanisms exist.

## Context and limits

Armstrong's [4 October 2026 workflow post](https://www.scottnarmstrong.com/2026/10/autoformalization-is-now-very-easy/) describes blueprints, dependency planning, statement freezing, parallel proof workers and cleanup. Its speed and ease assessments are the author's experience, not an estimate for this statistical project. The [CoarseGraining repository](https://github.com/scottnarmstrong/CoarseGraining) is a relevant analysis/probability example, but its proof claims were not independently rebuilt here.

The most useful adopted principle is to require separate evidence for **Lean acceptance**, **exact correspondence to the paper**, and **the assumptions/trust boundary**. None alone establishes all three.
