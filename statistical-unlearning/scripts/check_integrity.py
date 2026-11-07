#!/usr/bin/env python3
"""Structural safeguards and explicit axiom-audit checks for project Lean files.

Structural checks are a source hygiene check, not a substitute for Lean's kernel.
The axiom-log command must follow a successful Lean run in the pinned environment.
"""

from __future__ import annotations

import argparse
import hashlib
import json
from pathlib import Path
import re
import sys


ALLOWLIST = frozenset({"propext", "Classical.choice", "Quot.sound"})
EXCLUDED_PARTS = {".git", ".lake", "node_modules", "vendor"}
FORBIDDEN = {
    "sorry", "admit", "axiom", "unsafe", "native_decide", "sorryAx",
    "debug.skipKernelTC", "Lean.trustCompiler", "Lean.ofReduceBool",
    "Lean.ofReduceNat",
}
NAME = re.compile(r"(?:[^\W\d]|_)[\w']*(?:\.(?:[^\W\d]|_)[\w']*)*", re.UNICODE)
TOKEN = re.compile(r"(?:[^\W\d]|_)[\w']*(?:\.(?:[^\W\d]|_)[\w']*)*", re.UNICODE)
ANSI = re.compile(r"\x1b\[[0-?]*[ -/]*[@-~]")
REPORT = re.compile(
    r"'([^'\r\n]+)'\s+(?:"
    r"depends on axioms:\s*\[([^\]]*)\]"
    r"|(does not depend on any axioms))"
)


def sha256(data: bytes) -> str:
    return hashlib.sha256(data).hexdigest()


def project_lean_files(root: Path) -> list[Path]:
    return sorted(
        p for p in root.rglob("*.lean")
        if not EXCLUDED_PARTS.intersection(p.relative_to(root).parts)
    )


def strip_comments_and_strings(source: str) -> str:
    """Blank comments/strings while retaining offsets and all line boundaries.

    Handles Lean's nested block comments, line comments, escaped quoted strings,
    raw strings (r#"..."# and arbitrary # counts), and character literals.
    Unterminated comments or strings are rejected instead of masking source.
    """
    out = list(source)
    n = len(source)
    i = 0

    def blank(start: int, end: int) -> None:
        for j in range(start, end):
            if source[j] not in "\r\n":
                out[j] = " "

    while i < n:
        if source.startswith("--", i):
            end = source.find("\n", i)
            end = n if end < 0 else end
            blank(i, end)
            i = end
        elif source.startswith("/-", i):
            start, depth = i, 1
            i += 2
            while i < n and depth:
                if source.startswith("/-", i):
                    depth += 1
                    i += 2
                elif source.startswith("-/", i):
                    depth -= 1
                    i += 2
                else:
                    i += 1
            if depth:
                raise ValueError("unterminated block comment")
            blank(start, i)
        else:
            # Raw-string recognition is bounded by an identifier boundary.
            raw = re.match(r'r(#+)?"', source[i:]) if (
                source[i] == "r" and (i == 0 or not (source[i - 1].isalnum() or source[i - 1] in "_'"))
            ) else None
            if raw:
                start = i
                hashes = raw.group(1) or ""
                terminator = '"' + hashes
                end = source.find(terminator, i + len(raw.group(0)))
                if end < 0:
                    raise ValueError("unterminated raw string")
                i = end + len(terminator)
                blank(start, i)
            elif source[i] == '"':
                start = i
                i += 1
                while i < n:
                    if source[i] == "\\":
                        i += 2
                    elif source[i] == '"':
                        i += 1
                        break
                    else:
                        i += 1
                else:
                    raise ValueError("unterminated string")
                blank(start, min(i, n))
            elif source[i] == "'":
                # Apostrophes in identifiers (e.g. le') are not character starts.
                char = re.match(r"'(?:\\(?:u\{[0-9A-Fa-f]+\}|x[0-9A-Fa-f]{2}|.)|[^'\\\r\n])'", source[i:])
                if char and (i == 0 or not (source[i - 1].isalnum() or source[i - 1] in "_'")):
                    end = i + len(char.group(0))
                    blank(i, end)
                    i = end
                else:
                    i += 1
            else:
                i += 1
    return "".join(out)


def source_snapshot(root: Path) -> dict[str, str]:
    paths = set(project_lean_files(root))
    paths.update(
        path for name in ("lean-toolchain", "lakefile.lean", "lake-manifest.json", "declarations.json")
        if (path := root / name).is_file()
    )
    return {
        p.relative_to(root).as_posix(): sha256(p.read_bytes())
        for p in sorted(paths)
    }


def structural(root: Path, module: str, audit_module: str) -> list[str]:
    errors: list[str] = []
    paths = project_lean_files(root)
    if not paths:
        return ["no project Lean source files found"]
    imports: dict[str, set[str]] = {}
    for path in paths:
        relative = path.relative_to(root)
        try:
            clean = strip_comments_and_strings(path.read_text(encoding="utf-8"))
        except (ValueError, UnicodeError) as exc:
            errors.append(f"{relative}: {exc}")
            continue
        for match in TOKEN.finditer(clean):
            token = match.group(0)
            if token in FORBIDDEN:
                line = clean.count("\n", 0, match.start()) + 1
                errors.append(f"{relative}:{line}: forbidden source token {token}")
        local_module = ".".join(relative.with_suffix("").parts)
        imports[local_module] = {
            name for match in re.finditer(r"(?m)^\s*import\s+([^\r\n]+)", clean)
            for name in match.group(1).split() if NAME.fullmatch(name)
        }
    root_file = root / Path(*module.split(".")).with_suffix(".lean")
    if not root_file.is_file():
        errors.append(f"missing library root: {root_file.relative_to(root)}")
        return errors
    # The audit imports the library and must stay outside its import closure.
    required = {name for name in imports if name.startswith(module + ".") and name != audit_module}
    reached: set[str] = set()
    pending = [module]
    while pending:
        name = pending.pop()
        if name in reached:
            continue
        reached.add(name)
        pending.extend(imports.get(name, set()) - reached)
    for name in sorted(required - reached):
        errors.append(f"library module {name} is unreachable from import {module}")
    return errors


def source_declarations(root: Path) -> set[str]:
    """Find manually named declarations in the project's conventional source style.

    This is a coverage safeguard for the registry, not a Lean parser. Elaborated
    generated declarations are covered transitively by the registered constants.
    """
    names: set[str] = set()
    declaration = re.compile(
        r"^\s*(?:@\[[^\]]*\]\s*)*"
        r"(?:(?:noncomputable|private|protected|partial|unsafe)\s+)*"
        r"(?:theorem|lemma|def|abbrev|opaque|structure|inductive|class|instance)\s+"
        r"((?:[^\W\d]|_)[\w']*(?:\.(?:[^\W\d]|_)[\w']*)*)",
        re.UNICODE,
    )
    for path in project_lean_files(root):
        clean = strip_comments_and_strings(path.read_text(encoding="utf-8"))
        blocks: list[tuple[str, str]] = []
        for line in clean.splitlines():
            start = re.match(r"^\s*(namespace|section)(?:\s+(\S+))?\s*$", line)
            if start:
                blocks.append((start.group(1), start.group(2) or ""))
                continue
            if re.match(r"^\s*end(?:\s+\S+)?\s*$", line):
                if blocks:
                    blocks.pop()
                continue
            match = declaration.match(line)
            if match:
                prefix = [name for kind, name in blocks if kind == "namespace" and name]
                names.add(".".join(prefix + [match.group(1)]))
    return names


def load_declarations(path: Path) -> list[str]:
    value = json.loads(path.read_text(encoding="utf-8"))
    if isinstance(value, dict):
        value = value.get("declarations")
    if not isinstance(value, list) or not value:
        raise ValueError("declarations must be a nonempty JSON list, or an object with that list")
    names: list[str] = []
    for entry in value:
        name = entry.get("name") if isinstance(entry, dict) else entry
        if not isinstance(name, str) or not NAME.fullmatch(name):
            raise ValueError(f"invalid fully qualified declaration name: {name!r}")
        if name in names:
            raise ValueError(f"duplicate declaration name: {name}")
        names.append(name)
    return names


def generate_audit(names: list[str], module: str, output: Path) -> None:
    if not NAME.fullmatch(module):
        raise ValueError(f"invalid module name: {module!r}")
    output.parent.mkdir(parents=True, exist_ok=True)
    output.write_text(
        f"import {module}\n\n"
        "-- Generated axiom queries; build the imported library before running.\n"
        + "".join(f"#print axioms {name}\n" for name in names),
        encoding="utf-8",
    )


def verify_audit(names: list[str], log: Path, root: Path) -> dict:
    raw = log.read_bytes()
    text = ANSI.sub("", raw.decode("utf-8"))
    errors: list[str] = []
    discovered = source_declarations(root)
    if not discovered:
        errors.append("no named project source declarations found")
    for name in sorted(discovered - set(names)):
        errors.append(f"source declaration missing from audit registry: {name}")
    found: dict[str, list[str]] = {}
    for match in REPORT.finditer(text):
        name = match.group(1)
        if name in found:
            errors.append(f"duplicate axiom report for {name}")
            continue
        axioms = [item.strip() for item in (match.group(2) or "").split(",") if item.strip()]
        if any(not NAME.fullmatch(item) for item in axioms):
            errors.append(f"malformed axiom list for {name}")
        found[name] = sorted(set(axioms))
    for name in names:
        if name not in found:
            errors.append(f"missing axiom report for {name}")
        else:
            extra = set(found[name]) - ALLOWLIST
            if extra:
                errors.append(f"{name} uses disallowed axioms: {', '.join(sorted(extra))}")
    for name in sorted(set(found) - set(names)):
        errors.append(f"unexpected axiom report for {name}")
    if re.search(r"(?im)^.*\b(?:error|warning):", text):
        errors.append("Lean log contains an error or warning")
    toolchain = root / "lean-toolchain"
    if not toolchain.is_file():
        errors.append("missing pinned lean-toolchain file")
    if not (root / "lake-manifest.json").is_file():
        errors.append("missing compiled dependency lockfile lake-manifest.json")
    return {
        "schema_version": 1,
        "kind": "lean_axiom_audit",
        "status": "failed" if errors else "passed",
        "allowed_axioms": sorted(ALLOWLIST),
        "declarations": [
            {
                "name": name,
                "axioms": found.get(name),
                "status": "failed" if errors else "passed",
            }
            for name in names
        ],
        "errors": errors,
        "log_sha256": sha256(raw),
        "toolchain": toolchain.read_text(encoding="utf-8").strip() if toolchain.is_file() else None,
        "source_snapshot": source_snapshot(root),
        "source_declarations": sorted(discovered),
        "scope": "Parsed axiom reports after an independently successful Lean run; not standalone kernel certification.",
    }


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--root", type=Path, default=Path(__file__).resolve().parents[1])
    sub = parser.add_subparsers(dest="command", required=True)
    structural_parser = sub.add_parser("structural", help="check source hygiene and library imports")
    structural_parser.add_argument("--module", default="StatisticalUnlearning")
    structural_parser.add_argument("--audit-module", default="StatisticalUnlearning.Audit")
    generate_parser = sub.add_parser("generate-audit", help="generate one #print axioms per registered declaration")
    generate_parser.add_argument("--declarations", type=Path, required=True)
    generate_parser.add_argument("--output", type=Path, required=True)
    generate_parser.add_argument("--import-module", default="StatisticalUnlearning")
    verify_parser = sub.add_parser("verify-audit", help="check a successful Lean run's complete axiom log")
    verify_parser.add_argument("--declarations", type=Path, required=True)
    verify_parser.add_argument("--log", type=Path, required=True)
    verify_parser.add_argument("--json-output", type=Path)
    args = parser.parse_args()
    try:
        root = args.root.resolve()
        if args.command == "structural":
            errors = structural(root, args.module, args.audit_module)
            for error in errors:
                print(error, file=sys.stderr)
            if not errors:
                print("Source structure passed. This is not a Lean kernel check.")
            return int(bool(errors))
        names = load_declarations(args.declarations)
        if args.command == "generate-audit":
            generate_audit(names, args.import_module, args.output)
            print(f"Generated {len(names)} axiom queries in {args.output}")
            return 0
        report = verify_audit(names, args.log, root)
        if args.json_output:
            args.json_output.parent.mkdir(parents=True, exist_ok=True)
            args.json_output.write_text(json.dumps(report, indent=2, ensure_ascii=False) + "\n", encoding="utf-8")
        for error in report["errors"]:
            print(error, file=sys.stderr)
        if report["status"] == "passed":
            print(f"Axiom log passed for {len(names)} declarations; only the standard allowlist occurs.")
        return int(report["status"] != "passed")
    except (OSError, ValueError, UnicodeError) as exc:
        print(f"Integrity check failed: {exc}", file=sys.stderr)
        return 1


if __name__ == "__main__":
    raise SystemExit(main())
