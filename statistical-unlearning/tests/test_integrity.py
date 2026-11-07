"""Synthetic trust-pipeline tests; no fixture is actual Lean proof evidence.

All source trees, logs and evidence are temporary. These tests never write to the
project's verification directory, generated reader, or real declaration registry.
"""

from __future__ import annotations

import copy
import json
from pathlib import Path
import sys
from tempfile import TemporaryDirectory
import unittest


sys.path.insert(0, str(Path(__file__).resolve().parents[1] / "scripts"))
import build_site  # noqa: E402
import check_integrity as integrity  # noqa: E402


class SyntheticProject(unittest.TestCase):
    """An explicitly synthetic two-declaration project, entirely in temp storage."""

    def setUp(self):
        self.temp = TemporaryDirectory(prefix="synthetic-lean-audit-test-")
        self.addCleanup(self.temp.cleanup)
        self.root = Path(self.temp.name)
        self.module = self.root / "StatisticalUnlearning" / "Testing.lean"
        self.module.parent.mkdir()
        self.module.write_text(
            "namespace StatisticalUnlearning\n"
            "/-- Synthetic fixture definition. -/\n"
            "def baseline := 0\n\n"
            "/-- Synthetic fixture theorem, never compiled by this test. -/\n"
            "theorem bound : True := by trivial\n"
            "end StatisticalUnlearning\n",
            encoding="utf-8",
        )
        (self.root / "StatisticalUnlearning.lean").write_text(
            "import StatisticalUnlearning.Testing\n", encoding="utf-8"
        )
        (self.root / "lean-toolchain").write_text("leanprover/lean4:synthetic-test-only\n")
        (self.root / "lakefile.lean").write_text("import Lake\n")
        (self.root / "lake-manifest.json").write_text('{"packages": []}\n')
        self.names = ["StatisticalUnlearning.baseline", "StatisticalUnlearning.bound"]
        (self.root / "declarations.json").write_text(json.dumps({"declarations": self.names}))
        self.log = self.root / "synthetic-audit.log"
        self.log.write_text(
            "'StatisticalUnlearning.baseline' does not depend on any axioms\n"
            "'StatisticalUnlearning.bound' depends on axioms: [propext,\n"
            " Classical.choice, Quot.sound]\n",
            encoding="utf-8",
        )

    def report(self):
        return integrity.verify_audit(self.names, self.log, self.root)

    def evidence_file(self, evidence=None):
        path = self.root / "synthetic-evidence.json"
        path.write_text(json.dumps(self.report() if evidence is None else evidence), encoding="utf-8")
        return path


class AxiomLogTests(SyntheticProject):
    def test_standard_axioms_and_axiom_free_declaration_accepted(self):
        report = self.report()
        self.assertEqual(report["status"], "passed")
        self.assertEqual(report["errors"], [])
        self.assertEqual(report["declarations"][0]["axioms"], [])
        self.assertEqual(set(report["declarations"][1]["axioms"]), integrity.ALLOWLIST)

    def test_disallowed_axioms_rejected(self):
        original = self.log.read_text()
        for axiom in ("sorryAx", "Custom.unproved", "bound._native.native_decide.1"):
            with self.subTest(axiom=axiom):
                self.log.write_text(original.replace("propext,", axiom + ","))
                report = self.report()
                self.assertEqual(report["status"], "failed")
                self.assertTrue(any("disallowed axioms" in error for error in report["errors"]))

    def test_missing_and_duplicate_reports_rejected(self):
        original = self.log.read_text()
        self.log.write_text(original.splitlines(keepends=True)[0])
        self.assertTrue(any("missing axiom report" in e for e in self.report()["errors"]))
        self.log.write_text(original + original.splitlines(keepends=True)[0])
        self.assertTrue(any("duplicate axiom report" in e for e in self.report()["errors"]))

    def test_unexpected_report_rejected(self):
        with self.log.open("a") as log:
            log.write("'Unregistered.theorem' does not depend on any axioms\n")
        self.assertEqual(self.report()["status"], "failed")
        self.assertTrue(any("unexpected axiom report" in e for e in self.report()["errors"]))

    def test_warning_and_error_fail_entire_report(self):
        original = self.log.read_text()
        for message in ("warning: synthetic warning", "Audit.lean:1:0: error: synthetic error"):
            with self.subTest(message=message):
                self.log.write_text(original + message + "\n")
                report = self.report()
                self.assertEqual(report["status"], "failed")
                self.assertTrue(all(item["status"] == "failed" for item in report["declarations"]))

    def test_omitting_definition_from_registry_rejected(self):
        report = integrity.verify_audit(self.names[1:], self.log, self.root)
        self.assertEqual(report["status"], "failed")
        self.assertTrue(any("source declaration missing from audit registry" in e for e in report["errors"]))

    def test_lockfile_required_and_configuration_hashed(self):
        snapshot = self.report()["source_snapshot"]
        for filename in ("lean-toolchain", "lakefile.lean", "lake-manifest.json", "declarations.json"):
            self.assertRegex(snapshot[filename], r"^[0-9a-f]{64}$")
        (self.root / "lake-manifest.json").unlink()
        self.assertEqual(self.report()["status"], "failed")


class SourceHygieneTests(SyntheticProject):
    def test_nested_comments_strings_and_chars_avoid_false_positives(self):
        fragment = (
            '/- sorry /- axiom -/ admit -/\n'
            '-- unsafe native_decide\n'
            'def text := "sorry \\" admit"\n'
            'def raw := r##"unsafe \" native_decide"##\n'
            "def char := '\\n'\n"
        )
        clean = integrity.strip_comments_and_strings(fragment)
        tokens = {match.group() for match in integrity.TOKEN.finditer(clean)}
        self.assertFalse(tokens.intersection(integrity.FORBIDDEN))
        self.assertEqual(clean.count("\n"), fragment.count("\n"))
        self.assertEqual(len(clean), len(fragment))

    def test_actual_incomplete_proof_rejected(self):
        with self.module.open("a") as source:
            source.write("\ntheorem invalid : False := by sorry\n")
        errors = integrity.structural(self.root, "StatisticalUnlearning", "StatisticalUnlearning.Audit")
        self.assertTrue(any("forbidden source token sorry" in error for error in errors))

    def test_unterminated_comment_or_string_fails_closed(self):
        for source in ('/- missing end', '"missing quote', 'r#"missing raw terminator'):
            with self.subTest(source=source), self.assertRaises(ValueError):
                integrity.strip_comments_and_strings(source)


class ReaderEvidenceTests(SyntheticProject):
    def test_no_evidence_means_no_checked_declarations(self):
        self.assertEqual(build_site.load_evidence(self.root, None), (None, {}))

    def test_fresh_synthetic_evidence_accepted(self):
        # Acceptance tests parser behavior only. This log was not produced by Lean.
        evidence, declarations = build_site.load_evidence(self.root, self.evidence_file())
        self.assertEqual(evidence["status"], "passed")
        self.assertEqual(set(declarations), set(self.names))

    def test_stale_source_snapshot_rejected(self):
        path = self.evidence_file()
        with self.module.open("a") as source:
            source.write("\n-- Changed after synthetic audit snapshot.\n")
        with self.assertRaisesRegex(ValueError, "exact current"):
            build_site.load_evidence(self.root, path)

    def test_missing_lockfile_rejected_even_if_snapshot_matches(self):
        evidence = self.report()
        (self.root / "lake-manifest.json").unlink()
        evidence["source_snapshot"] = integrity.source_snapshot(self.root)
        with self.assertRaisesRegex(ValueError, "lockfile"):
            build_site.load_evidence(self.root, self.evidence_file(evidence))

    def test_incomplete_or_duplicate_declaration_coverage_rejected(self):
        original = self.report()
        for reports in (original["declarations"][:1], [original["declarations"][0]] * 2):
            with self.subTest(reports=reports):
                evidence = copy.deepcopy(original)
                evidence["declarations"] = reports
                with self.assertRaisesRegex(ValueError, "coverage"):
                    build_site.load_evidence(self.root, self.evidence_file(evidence))

    def test_disallowed_axiom_rejected_despite_success_label(self):
        evidence = self.report()
        evidence["declarations"][0]["axioms"] = ["sorryAx"]
        with self.assertRaisesRegex(ValueError, "declaration audit failed"):
            build_site.load_evidence(self.root, self.evidence_file(evidence))

    def test_failed_audit_or_error_list_rejected(self):
        original = self.report()
        for mutation in ({"status": "failed"}, {"errors": ["synthetic failure"]}):
            with self.subTest(mutation=mutation):
                evidence = copy.deepcopy(original)
                evidence.update(mutation)
                with self.assertRaisesRegex(ValueError, "successful axiom audit"):
                    build_site.load_evidence(self.root, self.evidence_file(evidence))

    def test_toolchain_mismatch_rejected_after_snapshot_refresh(self):
        evidence = self.report()
        (self.root / "lean-toolchain").write_text("leanprover/lean4:different-synthetic-version\n")
        evidence["source_snapshot"] = integrity.source_snapshot(self.root)
        with self.assertRaisesRegex(ValueError, "toolchain mismatch"):
            build_site.load_evidence(self.root, self.evidence_file(evidence))


if __name__ == "__main__":
    unittest.main()
