---
name: swiftui-sheet-item-fixer
description: Find and fix SwiftUI presentation race patterns where `.sheet(isPresented:)`, `.fullScreenCover(isPresented:)`, or `.popover(isPresented:)` depends on optional selected data and can render nil on first presentation. Use when a codebase has optional selection state plus separate presentation booleans, `if let` guards inside presentation closures, or delayed/async state updates that present with stale data.
---

# SwiftUI Sheet Item Fixer

Scan SwiftUI code for optional-data presentation races and migrate safe cases to item-driven presentation APIs.

## Workflow

1. Run the candidate scanner from the repo root:
```bash
python3 "$CODEX_HOME/skills/swiftui-sheet-item-fixer/scripts/find_optional_presentation_candidates.py" .
```
2. Prioritize findings where all three are true:
- `.sheet(isPresented:)` (or `fullScreenCover` / `popover`) is used.
- The presentation closure contains `if let` over a selected optional.
- A tap/action path sets selected data and presentation bool separately.
3. Convert safe matches to item-based presentation:
- Replace `.sheet(isPresented: $showingX)` with `.sheet(item: $selectedX)`.
- Remove fallback `else` UI for nil-only race handling.
- Stop toggling the presentation boolean in handlers; assign selected item only.
4. Ensure presented item type conforms to `Identifiable` (stable id).
5. Rebuild and test after edits.

## Conversion Rules

Use this canonical transformation when the sheet depends on selected data:

```swift
@State private var selectedThing: Thing?
@State private var showingThing = false

.sheet(isPresented: $showingThing) {
    if let thing = selectedThing {
        ThingDetailView(thing: thing)
    } else {
        Text("Error")
    }
}

Button {
    selectedThing = thing
    showingThing = true
}
```

Convert to:

```swift
@State private var selectedThing: Thing?

.sheet(item: $selectedThing) { thing in
    ThingDetailView(thing: thing)
}

Button {
    selectedThing = thing
}
```

Dismiss item-based presentation by setting `selectedThing = nil` when needed.

## Safety Checks Before Editing

- Keep `isPresented` when no associated data is required.
- Keep `isPresented` when timing is intentionally decoupled from selection.
- Do not auto-convert when the optional is derived/computed rather than owned state.
- Keep `@MainActor` correctness for UI state updates in async contexts.

## Validation

Run project commands (adjust scheme/destination when needed):

```bash
xcodebuild -list -project PokemonAnalyzer.xcodeproj
xcodebuild -scheme "PokemonAnalyzer" -destination "platform=iOS Simulator,name=iPhone 15" -configuration Debug build
xcodebuild -scheme "PokemonAnalyzer" -destination "platform=iOS Simulator,name=iPhone 15" test
```
