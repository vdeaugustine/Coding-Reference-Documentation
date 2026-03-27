#!/usr/bin/env python3
import argparse
import json
import re
import shlex
import subprocess
import sys
from pathlib import Path

ISSUE_RE = re.compile(r"(error:|warning:|BUILD)")

PLATFORM_TO_DEST = {
    "iOS Simulator": "generic/platform=iOS Simulator",
    "macOS": "platform=macOS",
    "tvOS Simulator": "generic/platform=tvOS Simulator",
    "watchOS Simulator": "generic/platform=watchOS Simulator",
    "visionOS Simulator": "generic/platform=visionOS Simulator",
    "xrOS Simulator": "generic/platform=visionOS Simulator",
}


def run(cmd, cwd):
    proc = subprocess.run(cmd, cwd=cwd, text=True, capture_output=True)
    return proc.returncode, proc.stdout, proc.stderr


def find_container(repo: Path):
    projects = sorted(repo.glob("*.xcodeproj"))
    workspaces = sorted(repo.glob("*.xcworkspace"))
    if len(projects) == 1:
        return ["-project", projects[0].name]
    if len(workspaces) == 1:
        return ["-workspace", workspaces[0].name]
    if projects:
        return ["-project", projects[0].name]
    if workspaces:
        return ["-workspace", workspaces[0].name]
    raise FileNotFoundError("No .xcodeproj or .xcworkspace found in repo root")


def list_schemes(container_args, cwd: Path):
    code, out, err = run(["xcodebuild", *container_args, "-list", "-json"], cwd)
    if code != 0:
        raise RuntimeError(f"Failed to list schemes:\n{err or out}")
    payload = json.loads(out)
    project = payload.get("project") or payload.get("workspace") or {}
    schemes = project.get("schemes", [])
    if not schemes:
        raise RuntimeError("No schemes found")
    return schemes


def destinations_for_scheme(container_args, scheme: str, cwd: Path):
    code, out, err = run(["xcodebuild", *container_args, "-scheme", scheme, "-showdestinations"], cwd)
    text = out + "\n" + err
    if code != 0 and "Available destinations for the scheme" not in text:
        return []

    destinations = []
    for platform, dest in PLATFORM_TO_DEST.items():
        if f"platform:{platform}" in text and dest not in destinations:
            destinations.append(dest)

    if not destinations:
        destinations.append("generic/platform=iOS Simulator")
    return destinations


def build_one(container_args, scheme: str, destination: str, cwd: Path):
    cmd = [
        "xcodebuild",
        *container_args,
        "-scheme",
        scheme,
        "-destination",
        destination,
        "build",
    ]
    code, out, err = run(cmd, cwd)
    combined = (out or "") + "\n" + (err or "")
    lines = [line for line in combined.splitlines() if ISSUE_RE.search(line)]
    return code, cmd, lines


def main():
    parser = argparse.ArgumentParser(description="Build all Xcode schemes/platforms and surface warnings/errors")
    parser.add_argument("--repo", default=".", help="Repository root containing .xcodeproj/.xcworkspace")
    parser.add_argument("--fail-on-warning", action="store_true", help="Exit non-zero if any warning is found")
    args = parser.parse_args()

    repo = Path(args.repo).resolve()
    container_args = find_container(repo)
    schemes = list_schemes(container_args, repo)

    had_fail = False
    warning_count = 0
    error_count = 0

    for scheme in schemes:
        destinations = destinations_for_scheme(container_args, scheme, repo)
        for destination in destinations:
            code, cmd, issue_lines = build_one(container_args, scheme, destination, repo)
            print(f"\n### Scheme: {scheme} | Destination: {destination}")
            print(f"$ {' '.join(shlex.quote(part) for part in cmd)}")
            if issue_lines:
                for line in issue_lines:
                    print(line)
            else:
                print("BUILD SUCCEEDED")

            for line in issue_lines:
                if "warning:" in line:
                    warning_count += 1
                if "error:" in line:
                    error_count += 1

            if code != 0:
                had_fail = True

    print("\n=== Summary ===")
    print(f"warnings: {warning_count}")
    print(f"errors: {error_count}")
    print(f"build_failures: {1 if had_fail else 0}")

    if had_fail or error_count > 0 or (args.fail_on_warning and warning_count > 0):
        sys.exit(1)


if __name__ == "__main__":
    main()
