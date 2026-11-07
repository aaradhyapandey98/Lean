# MathJax reader conversion: work in progress

Source: arXiv:2605.16645v1. The versioned archive's text files have been
retrieved and are checked in under `paper-source/arxiv-2605.16645v1/` on this
branch. Figure assets still need to be retrieved. The published reader has not
been replaced.

A direct Pandoc conversion (`pandoc neurips_2026.tex --from=latex --to=html5
--mathjax --citeproc --bibliography=references.bib -s`) is **not suitable for
publication**. Observed problems include:

* It labels `lem:ITOF` Lemma 16 and `thm:Blackwell` Theorem 18; arXiv's v1 HTML
  labels these Lemma 17 and Theorem 19 respectively. The PDF remains the final
  authority; systematic numbering comparison is required.
* References to multiple restated results and equations remain unresolved,
  for example `thm:FFR`, `lem:CDU`, and `eq:dist-unlearning`.
* Citeproc reports `kaushik2020learning` missing from the supplied bibliography.
* Figures, tables, equations, macros, restatements, citations, cross references,
  footnotes, and full wording have not been systematically compared against the
  source PDF. No reader produced by this conversion has been approved.

Next: obtain the complete archive including figures; choose or develop a TeX
conversion that handles the paper's `restatable` declarations and counter
semantics; implement an independent source-to-output fidelity check; integrate
MathJax and paired Lean views; verify desktop/mobile/browser accessibility and
all links; run the repository checks; then merge only after the fidelity checks
pass. Preserve source issues and do not imply the full paper is Lean verified.
