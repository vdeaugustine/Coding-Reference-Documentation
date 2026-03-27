#!/usr/bin/env python3
"""Find likely SwiftUI optional-data presentation race candidates.

Heuristic scan for:
- .sheet/.fullScreenCover/.popover using isPresented
- if let inside presentation closure
- optional @State and boolean @State names in same file

Outputs plain-text findings with file and line numbers.
"""

from __future__ import annotations

import argparse
import pathlib
import re
from dataclasses import dataclass
from typing import Iterable

PRESENTATION_PATTERNS = ["sheet", "fullScreenCover", "popover"]


@dataclass
class Finding:
    file: pathlib.Path
    line: int
    presentation: str
    details: str


def swift_files(root: pathlib.Path) -> Iterable[pathlib.Path]:
    for path in root.rglob("*.swift"):
        if "/.build/" in str(path) or "/DerivedData/" in str(path):
            continue
        yield path


def find_state_vars(text: str) -> tuple[set[str], set[str]]:
    optional_state = set(
        re.findall(r"@State\s+private\s+var\s+(\w+)\s*:\s*[^\n=]+\?", text)
    )
    bool_state = set(
        re.findall(r"@State\s+private\s+var\s+(\w+)\s*:\s*Bool", text)
    )
    return optional_state, bool_state


def scan_file(path: pathlib.Path) -> list[Finding]:
    text = path.read_text(encoding="utf-8")
    lines = text.splitlines()
    optional_state, bool_state = find_state_vars(text)
    findings: list[Finding] = []

    for idx, line in enumerate(lines, start=1):
        for presentation in PRESENTATION_PATTERNS:
            marker = f".{presentation}(isPresented:"
            if marker not in line:
                continue

            window = "\n".join(lines[idx - 1 : min(len(lines), idx + 25)])
            has_if_let = bool(re.search(r"\bif\s+let\b", window))

            if not has_if_let:
                continue

            optional_hint = sorted(optional_state)
            bool_hint = sorted(bool_state)
            detail_parts = ["if-let in presentation closure"]
            if optional_hint:
                detail_parts.append(f"optional @State: {', '.join(optional_hint)}")
            if bool_hint:
                detail_parts.append(f"bool @State: {', '.join(bool_hint)}")

            findings.append(
                Finding(
                    file=path,
                    line=idx,
                    presentation=presentation,
                    details="; ".join(detail_parts),
                )
            )

    return findings


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("root", nargs="?", default=".")
    args = parser.parse_args()

    root = pathlib.Path(args.root).resolve()
    all_findings: list[Finding] = []

    for path in swift_files(root):
        try:
            all_findings.extend(scan_file(path))
        except UnicodeDecodeError:
            continue

    if not all_findings:
        print("No likely optional-data presentation race candidates found.")
        return 0

    print(f"Found {len(all_findings)} candidate(s):")
    for item in all_findings:
        print(f"- {item.file}:{item.line} [{item.presentation}] {item.details}")

    return 0


if __name__ == "__main__":
    raise SystemExit(main())
