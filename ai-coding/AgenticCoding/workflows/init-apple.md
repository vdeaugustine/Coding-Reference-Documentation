---
description: Create init documents for apple platform projects
---

## Create a document that provides context to every AI coding agent

### Purpose
This repository contains an iOS application (and possibly extensions) built with Swift using Xcode, and this document defines the rules, workflow, and “how to run it” commands that every AI coding agent must follow to work safely and effectively.  
The priorities are: keep changes small and reviewable, preserve existing architecture and style, and always validate by building/tests before claiming success.

***

## Understand the project (required first step)
Before proposing code changes, the agent must quickly map the repo and answer these questions in its own notes (do not commit notes unless asked):

- What are the app targets and schemes (main app, widgets, extensions)?
- Is it a `.xcodeproj`, `.xcworkspace`, or SwiftPM-only repo?
- Is the UI SwiftUI, UIKit, or mixed?
- Where are the key layers?
  - App entry / lifecycle (e.g., `@main`, `AppDelegate`, `SceneDelegate`)
  - Networking layer
  - Persistence layer (Core Data / SQLite / file storage / Keychain)
  - UI composition (views/view controllers)
  - Dependency injection / composition root
- Where are tests?
  - Unit tests target(s)
  - UI tests target(s)
- Where are scripts / tooling?
  - `Scripts/`, `bin/`, `Makefile`, CI config, etc.

### Recommended “navigation path” through the repo
Follow this order to understand the structure fast:

1) Open the project definition  
- `.xcworkspace` / `.xcodeproj` (or `Package.swift` if SwiftPM).  

2) Identify schemes and targets  
- Prefer reading scheme names first (see commands below).

3) Find the app entry point  
- SwiftUI `App` type, or `AppDelegate` / `SceneDelegate`.

4) Trace a representative user flow end-to-end  
- UI → ViewModel/Controller → Service → Network/Persistence → back to UI.

5) Confirm how environment/config is handled  
- Build configurations, `.xcconfig`, feature flags, remote config, etc.

***

## How to build and test (must do before declaring “done”)

### Quick build check (your command, kept)
Use this when you just need a fast “does it compile?” signal:

```bash
xcodebuild -project <ProjectName>.xcodeproj -scheme <ProjectName> -sdk iphonesimulator -destination 'generic/platform=iOS Simulator' build 2>&1 | grep -E "(error:|warning:|BUILD)" | head -50
```

### Prefer these more explicit commands (recommended for reliability)
First list schemes:

```bash
xcodebuild -list -project <ProjectName>.xcodeproj
# or
xcodebuild -list -workspace <ProjectName>.xcworkspace
```

Then build with a named simulator device (more deterministic than “generic” in many setups):

```bash
xcodebuild \
  -scheme "<SchemeName>" \
  -destination "platform=iOS Simulator,name=iPhone 15" \
  -configuration Debug \
  build
```

Run unit tests:

```bash
xcodebuild \
  -scheme "<SchemeName>" \
  -destination "platform=iOS Simulator,name=iPhone 15" \
  test
```

Notes:
- If the repo is SwiftPM-only, prefer `swift test` for unit tests.
- If CI uses a specific simulator/runtime, match it to avoid “works on my machine” results.

***

## Swift / iOS best practices (must follow)

### Swift API design & readability
- Optimize for clarity at the point of use (APIs are declared once but used repeatedly), and verify call sites read naturally. [swift](https://swift.org/documentation/api-design-guidelines/)
- Prefer descriptive argument labels, especially for weakly typed parameters, to improve call-site clarity. [swift](https://swift.org/documentation/api-design-guidelines/)
- Avoid force unwraps/force casts in production code except where an invariant is clearly guaranteed (and documented).

### Concurrency & threading
- Prefer `async/await` over callback pyramids for new code.
- UI work must happen on the main thread / main actor; never update SwiftUI/UIKit state off-main.
- Be explicit about actor isolation when introducing new async code.

### SwiftUI guidelines
- Keep views small and composable; extract subviews when bodies get deeply nested.
- Keep state ownership clear (`@State`, `@StateObject`, `@ObservedObject`) and avoid “mystery state” that lives in multiple places.
- Avoid doing heavy work in view initializers; use lifecycle hooks (`.task`, `onAppear`) or view models.

### UIKit guidelines
- Keep view controllers thin; push logic into view models/coordinators/services.
- Avoid ambiguous constraints; ensure layouts are stable across Dynamic Type sizes.
- Prefer modern APIs (diffable data sources, compositional layout) if the project already uses them—do not introduce new patterns without asking.

### Testing expectations
- Any non-trivial logic change should include unit tests (new or updated).
- Avoid network calls in tests; use stubs/mocks.
- Tests must be deterministic and runnable locally via the documented commands.

### Security & privacy
- Never introduce hard-coded secrets, API keys, tokens, or private URLs.
- Don’t log sensitive user data.
- Use Keychain for credentials if the project stores secrets locally.

***

## Change protocol (how the agent should behave)
For each request:

1) Restate the goal in one sentence.  
2) Propose a plan (3–7 bullets) naming which files/targets likely change.  
3) Make the smallest viable diff.  
4) Run build/tests (or explain exactly why not possible).  
5) Report:
- What changed
- How it was verified (commands)
- Any risks, follow-ups, or TODOs

***

## Saving this document (required)
1) Save this file as **`CLAUDE.md`** at the **root of the repository**.  
2) Copy it exactly (byte-for-byte) so all AI tools load the same instructions:

```bash
cp CLAUDE.md GEMINI.md
cp CLAUDE.md AGENTS.md
```

***

## Project-specific placeholders (fill these in once)
Replace these tokens after the first pass (it’s worth doing—agents behave much better with specifics):

- `<ProjectName>`
- `<SchemeName>`
- Preferred simulator name (e.g., `iPhone 15`, `iPhone 15 Pro`)
- Whether builds should use `.xcodeproj` or `.xcworkspace`
- Any required setup steps (e.g., `brew install`, `bundle install`, certificates, env files)


## If these files already exist
Then the user called this so that you will make sure they are up to date. So just analyze the existing files, then analyze the project, and make sure everything mentioned is accurate and up to date.