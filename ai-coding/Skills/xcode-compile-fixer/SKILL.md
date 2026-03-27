---
name: xcode-compile-fixer
description: Make Xcode apps compile cleanly across all project schemes and supported Apple platforms by running xcodebuild, collecting warnings/errors, and iteratively fixing issues until there are zero warnings and zero errors. Use when the user asks to make a Swift/Xcode project compile, clean build failures, remove build warnings, or verify clean builds for iOS/macOS/tvOS/watchOS/visionOS targets.
---

# Xcode Compile Fixer

Follow this workflow whenever this skill is invoked.

## Workflow

1. Locate the project container in the target repo root.
- Prefer a single `.xcodeproj` if present.
- If the repo uses SwiftPM only, this skill is not applicable.

2. Enumerate schemes.
- Run `xcodebuild -list -json` against the project/workspace.
- Build every listed scheme unless the user explicitly scopes the request.

3. Discover supported destinations per scheme.
- Run `xcodebuild -showdestinations -scheme <scheme>`.
- Build every supported Apple platform represented in destinations.
- At minimum include these when available:
  - `generic/platform=iOS Simulator`
  - `platform=macOS`
  - `generic/platform=tvOS Simulator`
  - `generic/platform=watchOS Simulator`
  - `generic/platform=visionOS Simulator`

4. Compile and extract actionable output.
- Run `xcodebuild ... build 2>&1 | grep -E "(error:|warning:|BUILD)"`.
- Do not stop after one issue; keep iterating until every scheme/platform build is warning-free and error-free.

5. Fix all issues in code/config.
- Resolve compiler errors first, then warnings.
- Re-run builds after each fix batch.
- Continue until all builds report no warnings and no errors.

6. Final verification.
- Re-run the full matrix build.
- Confirm clean results across all schemes/platforms built.

## Commands

Use these command shapes directly when appropriate:

```bash
cd /path/to/repo && xcodebuild -project <ProjectName>.xcodeproj -scheme <ProjectName> -sdk iphonesimulator -destination 'generic/platform=iOS Simulator' build 2>&1 | grep -E "(error:|warning:|BUILD)" | head -100
```

```bash
cd /path/to/repo && xcodebuild -project <ProjectName>.xcodeproj -scheme <ProjectName> -destination 'platform=macOS' build 2>&1 | grep -E "(error:|warning:|BUILD)" | head -100
```

Use the bundled helper script to automate matrix discovery and execution.

## Resources

### scripts/

- `run_xcode_compile_matrix.py`
  - Discovers schemes from project/workspace
  - Detects supported destinations per scheme
  - Runs `xcodebuild` for each scheme+destination pair
  - Prints `BUILD`, `warning:`, and `error:` lines
  - Exits non-zero if any failure/warning/error remains
