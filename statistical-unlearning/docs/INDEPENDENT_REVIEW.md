# Independent review of selected source statements

Reviewed 2026-11-06 against [arXiv v1 HTML](https://arxiv.org/html/2605.16645v1) and [PDF](https://arxiv.org/pdf/2605.16645v1). This is an independent mathematical review, **not a Lean-checked proof certificate**. No source statement has been silently corrected. Proposed repairs require author review and later formalization.

| Item | Assessment of concern | Scope |
| --- | --- | --- |
| Proposition 3: zero removal parameter | Confirmed | The printed whole-ball equivalence fails at an allowed boundary value. |
| Proposition 3: covariance geometry | Confirmed ambiguity | The ball must use the Mahalanobis metric, or coordinates must be whitened. |
| Propositions 11 and 12: one-dimensional simplification | Confirmed | A union of excluded intervals is replaced by its hull without a connectedness hypothesis. |
| Lemma 16: order reflection | Confirmed | Bounded-support log-concave noise can yield equal trade-off curves for unequal shifts. |
| Proposition 6 / Lemma 37: confidence notation | Confirmed proof/notation defect | This does not establish that Proposition 6 itself is false; a direct Gaussian proof repairs it. |
| Lemma 35: similarly ordered condition | Confirmed under the ordinary meaning of similarly ordered | Relabeling Bernoulli outcomes gives a counterexample. |

## Proposition 3: zero parameter and covariance geometry

Source: Section 3.1, PDF printed page 5; HTML Proposition 3, equations (7)–(8) and following sentence. The same result is restated in Appendix C.1 with a conflicting displayed proposition number in the PDF, so section and equation references are more reliable identifiers.

Write the geometric set as

\[
R=\{x:\|x-u\|_M\geq a,\ \|x-v\|_M\leq e\},
\qquad \Delta=\|u-v\|_M,
\]

where \(\|z\|_M=\sqrt{z^T\Sigma^{-1}z}\). Assume a positive-dimensional real space, positive definite \(\Sigma\), and \(a,e\geq0\).

Take \(u=v=0\), \(a=0\), and \(e=1\). Every point of the preservation ball satisfies the removal inequality because norms are nonnegative. Thus the entire preservation ball is feasible, although \(\Delta-e=-1\not\geq a\). This directly disproves the printed equivalence at \(a=0\).

The minimum distance from \(u\) to the preservation ball is \(\max(0,\Delta-e)\). Hence the correct condition in this setting is

\[
R=\overline B_M(v,e)\quad\Longleftrightarrow\quad
 a\leq\max(0,\Delta-e).
\]

For \(a>0\), this reduces to the printed condition. The nonemptiness criterion uses the maximum distance \(\Delta+e\), so the zero-parameter counterexample does **not** refute that separate criterion.

An ordinary Euclidean ball is incorrect before whitening. For example, in one dimension let \(\Sigma=4\), \(u=4\), \(v=0\), \(a=e=1\). The preservation set is \([-2,2]\), and every point in it is at Mahalanobis distance at least one from \(u\). Thus \(R=[-2,2]\), whereas the ordinary Euclidean unit ball about zero is \([-1,1]\). Either explicitly use \(B_M\), or transform all means by \(\Sigma^{-1/2}\), as the paper subsequently discusses.

## Propositions 11 and 12: excluded intervals

Source: Appendix C.3; PDF printed pages 22–23; equations (61)–(64) and following one-dimensional descriptions. The HTML and PDF agree on the problematic simplification.

For finite nonempty index sets, put

\[
L=\max_j(\nu_j-\varepsilon_j),\qquad
U=\min_j(\nu_j+\varepsilon_j).
\]

The exact distance constraints give

\[
R=[L,U]\setminus\bigcup_i(\mu_i-\alpha_i,\mu_i+\alpha_i).
\]

The complement of this union generally has internal components. Choose unwanted means \(-2,2\), both removal radii one, and a retained mean zero with preservation radius \(1/2\), with identity covariance. Every \(x\in[-1/2,1/2]\) has distance at least \(3/2\) from each unwanted mean, so the entire retained interval is feasible. The displayed two-tail formula retains only \(x\leq-3\) or \(x\geq3\), and therefore reports an empty intersection.

This also refutes the printed emptiness criterion. The correct general criterion is \(L>U\), or \([L,U]\) is covered by the **actual union** of open excluded intervals. Replacing that union by a single open interval is valid if the union is itself that interval; connectedness of the open union is a sufficient additional hypothesis. Merely having adjacent intervals touch at an endpoint is insufficient, because the touching point is not excluded. Zero removal radii also need explicit treatment, because their open intervals are empty.

For Proposition 12 the same counterexample can use standard Gaussian base noise, which satisfies its stated distributional conditions. Consequently this objection is independent of any additional problems with general log-concave noise.

## Lemma 16: bounded-support saturation

Source: Appendix A.3, PDF printed page 14, equation (27).

Let \(X\) be uniform on \([-1/2,1/2]\). Its density is symmetric and log-concave in the standard definition allowing a density to vanish outside a convex support. Both \(X+1\) and \(X+2\) are mutually singular with \(X\): the possible touching endpoint at shift one has measure zero.

For either shift, a test can be zero almost surely under \(X\) and one almost surely under the shifted law. Its two errors are both zero. Since type-II errors are nonnegative, both trade-off curves are identically zero on \([0,1]\).

Set \(\varepsilon_1=2\), \(\varepsilon_2=1\). The pointwise curve inequality holds by equality, while \(\varepsilon_1\leq\varepsilon_2\) is false. Thus the reverse implication in (27) needs additional assumptions. This example does not refute the forward monotonicity implication.

A sufficient repair for order reflection is a continuous CDF that is strictly increasing on all of \(\mathbb R\), together with the claimed shift formula. Evaluating that formula at a fixed interior probability, such as \(1/2\), gives strict dependence on the shift. This is a proposed sufficient condition; no minimal hypothesis is claimed here.

## Proposition 6 and Lemma 37: confidence accounting

Source: Section 4.1 (Proposition 6), Appendix D.1 (Lemma 37 and equations (88)–(90)), PDF printed pages 8 and 31 onward. The main text defines \(\gamma(n,d,\delta)\) with \(\log(1/\delta)\); Lemma 37 labels that same expression \(\gamma(n,d,2\delta)\). These are incompatible conventions if \(\gamma\) has one global meaning.

The proof invokes a union bound on two events at failure parameter \(\delta\) and claims joint success \(1-\delta\). From two marginal failure bounds of \(\delta\), the union bound alone yields \(1-2\delta\). Using \(\delta/2\) per event would justify \(1-\delta\). With independent events at marginal success at least \(1-\delta/2\), the product lower bound is \(1-\delta+\delta^2/4\), rather than the footnote's \(1-\delta+\delta^2/2\).

**A claim that these observations disprove Proposition 6 is refuted.** Under the stated independence of the two samples, and with \(m=n_1'>0\), \(n=n_2>0\), the pooled mean admits a simpler argument. Put \(N=m+n\) and

\[
\eta=\mu-\frac{m\mu_1+n\nu_1}{N}.
\]

Then \(\eta\sim N(0,\sigma^2 I_d/N)\). Define

\[
C=\sqrt{d+2\sqrt{d\log(1/\delta)}+2\log(1/\delta)}.
\]

Gaussian concentration gives \(\|\eta\|\leq\sigma C/\sqrt N\) with probability at least \(1-\delta\). The error allowance in the main proposition is

\[
E=\frac{m\gamma(m,d,\delta)+n\gamma(n,d,\delta)}N
 =C\frac{\sqrt m+\sqrt n}N\geq\frac C{\sqrt N}.
\]

On that single event, triangle and reverse-triangle inequalities give both

\[
\frac{\|\mu-\nu_1\|}\sigma\leq\frac mN\Delta+E,
\qquad
\frac{\|\mu-\mu_1\|}\sigma\geq\frac nN\Delta-E.
\]

These are the required sufficient bounds without a union bound and without increasing the proposition's error allowance. This is an informal repair, pending Lean formalization. Cases with no unwanted samples remaining require a separate definition that avoids division by zero; they are outside this calculation.

## Additional check: Lemma 35

Source: Appendix C.6, PDF printed page 30; equations (87) and Lemma 36. Interpret the malformed nested trade-off notation as the intended pair of binomial distributions.

Take \((a,b)=(1/5,4/5)\) and \((c,d)=(4/5,1/5)\). For every positive integer \(n\), the bijection \(k\mapsto n-k\) maps the first binary experiment to the second. Composing tests with this bijection preserves both error probabilities, so the trade-off curves are equal. Yet the parameter pairs have opposite ordering. The ratio conditions in (87) coincide for both pairs, so the obstruction is specifically the extra similarly ordered requirement.

This independently confirms that requirement cannot be necessary as stated. It also makes Lemma 34's use of the characterization a dependency requiring review; this note does not give a full corrected binomial characterization.
