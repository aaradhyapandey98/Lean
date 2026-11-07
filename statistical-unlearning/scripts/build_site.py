#!/usr/bin/env python3
"""Generate the reader from actual source; fail closed on mismatched evidence."""

from __future__ import annotations

import argparse
import json
import os
from pathlib import Path
import re
import sys

from check_integrity import ALLOWLIST, source_snapshot, strip_comments_and_strings


def extract_declaration(root: Path, file: str, name: str) -> tuple[str, list[int]]:
    path = (root / file).resolve()
    if not path.is_relative_to(root) or path.suffix != ".lean":
        raise ValueError(f"invalid source path: {file}")
    text = path.read_text(encoding="utf-8")
    clean = strip_comments_and_strings(text)
    local = name.removeprefix("StatisticalUnlearning.")
    pattern = re.compile(
        r"(?m)^[ \t]*(?:@\[[^\n]*\][ \t]*)?(?:noncomputable[ \t]+)?"
        r"(?:def|abbrev|structure|theorem|lemma)[ \t]+" + re.escape(local) + r"(?=[\s{(:])"
    )
    matches = list(pattern.finditer(clean))
    if len(matches) != 1:
        raise ValueError(f"expected exactly one {name} in {file}; found {len(matches)}")
    start = matches[0].start()
    # Project source style separates declarations with docstrings or namespace end.
    boundary = re.search(r"\n(?=/--|end StatisticalUnlearning\b|variable\b)", text[matches[0].end():])
    end = matches[0].end() + boundary.start() if boundary else len(text)
    code = text[start:end].rstrip()
    first = text.count("\n", 0, start) + 1
    return code, [first, first + code.count("\n")]


def load_evidence(root: Path, path: Path | None) -> tuple[dict | None, dict[str, dict]]:
    if path is None:
        return None, {}
    evidence = json.loads(path.read_text(encoding="utf-8"))
    if evidence.get("kind") != "lean_axiom_audit" or evidence.get("status") != "passed" or evidence.get("errors"):
        raise ValueError("evidence does not record a successful axiom audit")
    if evidence.get("source_snapshot") != source_snapshot(root):
        raise ValueError("audit evidence does not match the exact current Lean/configuration sources")
    if not (root / "lake-manifest.json").is_file():
        raise ValueError("checked status requires the resolved dependency lockfile")
    if evidence.get("toolchain") != (root / "lean-toolchain").read_text().strip():
        raise ValueError("audit toolchain mismatch")
    registry = json.loads((root / "declarations.json").read_text())["declarations"]
    names = {item if isinstance(item, str) else item["name"] for item in registry}
    reports = evidence.get("declarations", [])
    if len(reports) != len(names) or {item["name"] for item in reports} != names:
        raise ValueError("incomplete or duplicate declaration audit coverage")
    for item in reports:
        if item.get("status") != "passed" or not set(item.get("axioms", [])).issubset(ALLOWLIST):
            raise ValueError(f"declaration audit failed: {item.get('name')}")
    return evidence, {item["name"]: item for item in reports}


def generate(root: Path, evidence_path: Path | None, revision: str) -> str:
    catalog = json.loads((root / "catalog.json").read_text(encoding="utf-8"))
    evidence, audited = load_evidence(root, evidence_path)
    build = {
        "status": "passed" if evidence else "unverified",
        "command": "lake build --wfail; lake env lean StatisticalUnlearning/Audit.lean; strict axiom audit",
        "revision": evidence.get("build", {}).get("revision", revision) if evidence else "No successful build recorded",
        "toolchain": (root / "lean-toolchain").read_text().strip(),
    }
    lock = root / "lake-manifest.json"
    if lock.exists():
        mathlib = next((p for p in json.loads(lock.read_text()).get("packages", []) if p.get("name") == "mathlib"), {})
        build["mathlib"] = mathlib.get("rev", "Not resolved")
    if evidence and evidence.get("build", {}).get("url"):
        build["url"] = evidence["build"]["url"]
    elif evidence and os.environ.get("GITHUB_RUN_ID"):
        build["url"] = "https://github.com/aaradhyapandey98/Lean/actions/runs/" + os.environ["GITHUB_RUN_ID"]
    ids = [entry["id"] for entry in catalog["entries"]]
    if len(ids) != len(set(ids)):
        raise ValueError("duplicate catalog identifiers")
    source_ref = build["revision"] if evidence and re.fullmatch(r"[0-9a-f]{40}", build["revision"]) else revision
    for entry in catalog["entries"]:
        if any(dep not in ids for dep in entry.get("dependencies", [])):
            raise ValueError(f"unknown dependency in {entry['id']}")
        entry.setdefault("sourceUrl", "https://arxiv.org/html/2605.16645v1")
        if "lean" not in entry:
            entry["status"] = "pending"
            continue
        lean = entry["lean"]
        lean["code"], lean["lines"] = extract_declaration(root, lean["file"], lean["declaration"])
        lean["url"] = (
            f"https://github.com/aaradhyapandey98/Lean/blob/{source_ref}/statistical-unlearning/"
            f"{lean['file']}#L{lean['lines'][0]}-L{lean['lines'][1]}"
        )
        entry["status"] = "checked" if lean["declaration"] in audited else "unverified"
        if entry["status"] == "checked":
            entry["axioms"] = audited[lean["declaration"]]["axioms"]
            entry["verification"] = (
                "Lean accepted the encoded declaration and its axiom audit uses only the displayed foundational axioms. "
                "This records code checking; read the correspondence notes for remaining mathematical representation obligations."
            )
    catalog["build"] = build
    if evidence and evidence.get("generated_at"):
        catalog["generatedAt"] = evidence["generated_at"]
    # This is an external JS asset; escape HTML metacharacters as an additional safeguard.
    encoded = json.dumps(catalog, ensure_ascii=False, indent=2).replace("<", "\\u003c").replace(">", "\\u003e").replace("&", "\\u0026")
    return "// Generated by scripts/build_site.py. Do not edit proof statuses by hand.\nwindow.PROOF_DATA = " + encoded + ";\n"


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--root", type=Path, default=Path(__file__).resolve().parent.parent)
    parser.add_argument("--evidence", type=Path)
    parser.add_argument("--revision", default=os.environ.get("GITHUB_SHA", "main"))
    parser.add_argument("--check", action="store_true")
    args = parser.parse_args()
    root = args.root.resolve()
    try:
        output = generate(root, args.evidence, args.revision)
        target = root / "site/data/proofs.js"
        if args.check:
            if not target.exists() or target.read_text(encoding="utf-8") != output:
                raise ValueError("generated site manifest is stale")
        else:
            target.parent.mkdir(parents=True, exist_ok=True)
            target.write_text(output, encoding="utf-8")
        print("Site manifest checked." if args.check else "Site manifest generated from actual source.")
        return 0
    except (OSError, ValueError, KeyError, TypeError) as exc:
        print(f"Site generation failed: {exc}", file=sys.stderr)
        return 1


if __name__ == "__main__":
    raise SystemExit(main())
