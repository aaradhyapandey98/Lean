# Proof companion

This is a static reader for the formalization. Open `index.html` directly,
serve this directory, or publish it to GitHub Pages. Lean and status data come
from `data/proofs.js`; the paper pane loads the original versioned HTML or PDF
from arXiv and therefore requires network access and, for PDF, a browser viewer.

The PDF is the authoritative paper; the HTML is arXiv's experimental rendering.
Choosing a tracked result navigates to its source section or page. Paper and Lean panes scroll
independently: automatic paragraph-level alignment is not yet implemented.
An external link is provided if the PDF cannot be embedded. No result without
an audited declaration is represented as proved.

The reader displays a mathematical statement beside its actual Lean source. A
tracked statement is not the same as a verified theorem, and the counters do not
claim a percentage of the paper has been formalized.

## Data contract

`data/proofs.js` assigns an object to `window.PROOF_DATA`:

```js
{
  paper: {
    title: "…", authors: ["…"], arxiv: "https://…", version: "2605.16645v1"
  },
  repositoryUrl: "https://github.com/…", // optional
  generatedAt: "…",                    // optional
  build: {
    status: "pending", // checked/passed, pending, blocked/unverified, or failed
    command: "lake build",
    revision: "…",
    toolchain: "…",  // optional
    mathlib: "…"     // optional
  },
  entries: [{
    id: "stable-entry-id",
    kind: "Lemma",
    number: "…",                 // omit for unnumbered observations
    title: "…",
    section: "01 · The framework",
    status: "pending",           // checked, unverified, or pending
    summary: "…",                // optional explanatory prose
    statement: "…",              // plain Unicode; newlines preserved
    assumptions: ["…"],
    dependencies: ["other-entry-id"],
    sourceUrl: "https://arxiv.org/html/…#…",
    notes: "…",                  // optional qualification or correspondence note
    verification: "…",           // optional explicit compiler evidence
    axioms: ["propext", "Classical.choice", "Quot.sound"], // optional actual audit
    lean: {                      // omit when no source exists
      file: "StatisticalUnlearning/…lean",
      declaration: "StatisticalUnlearning.…",
      code: "…",                 // source extracted from the repository
      lines: [1, 20],
      url: "https://github.com/…/blob/<revision>/…#L1-L20"
    }
  }]
}
```

Use `checked` only when the declared verification process has accepted the
displayed source. Use `unverified` for authored source without successful compiler
evidence, and `pending` for formalization targets. A successful project build does
not automatically turn every entry into a checked result. Record mathematical
restrictions and translation choices explicitly under `assumptions` and `notes`.

## Interaction and accessibility

- Search matches titles, section names, statements, and Lean declaration names.
- `/` focuses search; Escape clears it.
- Filters separate checked entries from open work.
- Stable URL fragments select entries and make statements linkable.
- Below 950 px, tabs switch between mathematics and Lean source. Arrow keys move
  between the tabs.
- Code is rendered as text with Lean-aware highlighting and source line numbers.
- The source-copy button copies the original source rather than rendered numbers.
- Reduced motion, keyboard focus, print styling, and mobile overflow are handled
  locally.

The website is a reader, not a Lean compiler. Build and axiom evidence must be
produced by the project's verification workflow.
