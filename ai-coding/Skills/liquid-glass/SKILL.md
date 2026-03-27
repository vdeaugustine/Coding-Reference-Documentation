---
description: Domain knowledge for implementing iOS 26 Liquid Glass design language in Swift/SwiftUI/UIKit. Load this skill when working on any iOS 26 UI, navigation, tabs, widgets, icons, or accessibility tasks.
globs: ['**/*.swift', '**/*.xib', '**/*.storyboard', 'Info.plist']
alwaysApply: false
---

# SKILL: iOS 26 Liquid Glass Implementation

**Use this skill when:** writing or reviewing SwiftUI/UIKit code that targets iOS 26, implementing navigation bars, tab bars, sheets, cards, widgets, live activities, or app icons, or handling backward compatibility with pre-iOS 26 glass-style materials.

---

## 1. Core API: `glassEffect()`

The primary SwiftUI modifier for Liquid Glass on custom views. First-class API introduced in iOS 26 — do not use `UIVisualEffectView` bridging for new code.

**Basic usage:**

```swift
Text("Hello, Glass")
    .padding()
    .glassEffect()
```

````

### Variants

| Variant              | Use Case                                                    | Requirement                                                   |
| -------------------- | ----------------------------------------------------------- | ------------------------------------------------------------- |
| `.regular` (default) | Navigation bars, cards, buttons, standard chrome            | Balanced translucency; system auto-adjusts for 4.5:1 contrast |
| `.clear`             | Photo galleries, video players, immersive content           | **Must** use bold, high-contrast foreground content           |
| `.identity`          | Loading indicators, status badges, non-interactive overlays | Near-zero refraction; preserves underlying color              |

```swift
view.glassEffect(.regular)
view.glassEffect(.clear)
view.glassEffect(.identity)

// With custom shape clipping (prevents double-frosting at corners)
view.glassEffect(.regular, in: RoundedRectangle(cornerRadius: 12))
```

**API signature:**

```swift
func glassEffect<S: Shape>(
    _ style: GlassEffectStyle = .regular,
    in shape: S
) -> some View
```

### GlassEffectContainer (Coordinated Transitions)

Use this when multiple glass views transition together. Prevents double-frosting by compositing into a single render pass.

```swift
@Namespace var glassID

GlassEffectContainer {
    VStack(spacing: 0) {
        headerView
            .glassEffectID("header", in: glassID)
        contentView
            .glassEffectID("content", in: glassID)
    }
}
```

For morphing between states:

```swift
@Namespace var glassSpace

if isExpanded {
    DetailView()
        .glassEffectID("card", in: glassSpace)
} else {
    CardView()
        .glassEffectID("card", in: glassSpace)
}
```

---

## 2. Backward Compatibility Patterns

### Layered Fallback (ViewModifier pattern)

```swift
struct GlassBackgroundModifier: ViewModifier {
    func body(content: Content) -> some View {
        if #available(iOS 26.0, *) {
            content
                .background(.liquidGlass)
                .glassEffect(.standard)
        } else if #available(iOS 15.0, *) {
            content
                .background(.regularMaterial)
        } else {
            content
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.white.opacity(0.85))
                        .shadow(radius: 8)
                )
        }
    }
}
```

### Fallback Tiers

- **iOS 26+** — `.glassEffect()`, `.material(.liquidGlass)`, `.background(.liquidGlass)`
- **iOS 15-25** — `.regularMaterial` or `.thickMaterial`
- **iOS 13-14** — `Color.white.opacity(0.8)` or `UIVisualEffectView` bridge
- **< iOS 13** — Solid color with subtle gradient

---

## 3. Accessibility: Reduce Transparency

**Always** handle `accessibilityReduceTransparency`. When active, replace all glass with solid backgrounds.

```swift
struct AccessibleGlassView: View {
    @Environment(\.accessibilityReduceTransparency) var reduceTransparency

    var body: some View {
        VStack { /* Content */ }
            .background {
                if reduceTransparency {
                    Color(.systemBackground)
                } else if #available(iOS 26.0, *) {
                    Color.clear.glassEffect()
                } else {
                    Color.clear.background(.regularMaterial)
                }
            }
    }
}
```

**Accessibility checklist:**

- Minimum 4.5:1 contrast ratio for text on all glass surfaces
- 3:1 minimum for graphical elements
- Respect `Reduce Motion`: all glass animations must be < 200ms and pause entirely when enabled
- Provide `Increase Contrast` fallbacks (borders/edges become solid)
- `Bold Text` setting must not break glass layouts
- VoiceOver: add `UIAccessibilityTraitLiquidGlass` for fluid state descriptions where applicable

### Tinted Mode (iOS 26.1+)

A user-facing toggle at **Settings > Display & Brightness > Liquid Glass** (Clear / Tinted). Apps using standard `.glassEffect()` automatically adapt — no code changes needed. Test both modes to validate legibility; no `#available` branching required.

---

## 4. Auto-Adoption and Opt-Out

### What auto-adopts when targeting iOS 26 SDK

Rebuilding with Xcode 26 automatically applies Liquid Glass to:

- `NavigationStack` bars and toolbars
- `TabView` and floating tab bars
- Sheets, popovers, alerts, menus
- System buttons and toggles
- Lists with translucent backgrounds
- Search bars and text field containers

Custom views do **not** auto-adopt and must opt in manually.

### Global Opt-Out (Temporary)

Add to `Info.plist` to revert all system components to iOS 25 solid materials:

```xml
<key>UILiquidGlassOptOut</key>
<true/>
```

**Deprecation timeline — plan accordingly:**

- **iOS 27** (Sep 2026): `UILiquidGlassOptOut` deprecated; App Store submissions generate warnings
- **iOS 28** (Sep 2027): Key removed; opt-out apps fail App Store submission

### Per-View Solid Override (SwiftUI)

No per-view opt-out API exists. Simulate with explicit solid backgrounds:

```swift
NavigationStack {
    contentView
}
.toolbarBackground(.visible, for: .navigationBar)
.toolbarBackground(Color(.systemBackground), for: .navigationBar)
```

---

## 5. UIKit Migration

### Navigation / Tab / Tool Bars

iOS 26 applies Liquid Glass to all `UINavigationBar`, `UITabBar`, `UIToolbar` instances automatically.

```swift
// Prevent bar from being glass when content scrolls under it
navigationController?.navigationBar.hidesSharedBackground = true
```

### Sheets (UISheetPresentationController)

```swift
let sheet = viewController.sheetPresentationController
sheet?.preferredCornerRadius = 20
sheet?.largestUndimmedDetentIdentifier = .medium
// Override glass (not recommended):
viewController.view.backgroundColor = .systemBackground
```

### UIBarButtonItem Padding Change

Glass bars automatically add **8pt horizontal padding** to `UIBarButtonItem`. Compensate custom views:

```swift
// Was 44x44; reduce to 36pt to account for auto-padding
let button = UIButton(frame: CGRect(x: 0, y: 0, width: 36, height: 36))
let barButton = UIBarButtonItem(customView: button)
```

### UIVisualEffectView Soft Deprecation

`UIVisualEffectView(effect: UIBlurEffect(style: .systemMaterial))` still works but is soft-deprecated. Migrate to SwiftUI + hosting controller for forward compatibility:

```swift
let hostingController = UIHostingController(rootView:
    ContentView()
        .glassEffect()
)
addChild(hostingController)
view.addSubview(hostingController.view)
```

---

## 6. TabView and NavigationSplitView

### New Tab API (Full Glass Support)

The legacy `.tabItem` modifier still functions but does **not** receive full glass treatment.

```swift
// Legacy — limited glass
TabView {
    HomeView().tabItem { Label("Home", systemImage: "house") }
    SettingsView().tabItem { Label("Settings", systemImage: "gear") }
}

// New API — full glass (iOS 26+)
TabView {
    Tab("Home", systemImage: "house") { HomeView() }
    Tab("Settings", systemImage: "gear") { SettingsView() }
}
.tabViewStyle(.floatingGlass)
```

### Floating Tab Bar Behavior

- Floats above content; content flows beneath it
- Use `.safeAreaInset()` or `.ignoresSafeArea()` to manage layout
- Auto-avoids Dynamic Island
- In landscape (iPhone): transitions to a side rail with labels replacing icons
- On iPad (landscape/multitasking): becomes a persistent sidebar with blur radius 15-25pt

### NavigationSplitView

Sidebar adopts glass material on iPadOS and macOS. On iPhone, sidebar is modal with glass sheet treatment. The system uses `hidesSharedBackground` (UIKit) or auto z-ordering (SwiftUI) to prevent double-frosting when detail overlaps sidebar.

---

## 7. Widgets and Live Activities

### Home Screen Widgets

- Liquid Glass applied automatically by WidgetKit on iOS 26
- **Do not** set `.background(.clear)` — this overrides the system glass material

```swift
// WRONG — breaks glass
struct MyWidget: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(...) { context in
            MyWidgetView()
                .background(.clear)  // NEVER DO THIS
        }
    }
}

// CORRECT — no explicit background
struct MyWidget: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(...) { context in
            MyWidgetView()
        }
    }
}
```

### Lock Screen Widgets

- Circular complications: retain solid backgrounds (no glass)
- Rectangular complications: adopt glass treatment
- Live Activity (collapsed → expanded): transitions from opaque to glass over 0.3s (not customizable)
- Live Activity opacity: ~85% on Lock Screen vs. ~70% on Home Screen

### Live Activities (Dynamic Island)

- Expanded Dynamic Island activities use glass by default
- System enforces high-contrast text automatically
- In Tinted mode (iOS 26.1+): Lock Screen notifications gain additional frosted layer automatically
- In Reduce Motion: glass effects remain; animations are suppressed

### Widget Typography Rules

- Use **Bold** or **Heavy** font weights for primary widget content
- Avoid subtle grays or pastels; prefer pure white, black, or saturated accents
- Test on varied wallpapers — design for worst-case low-contrast gradients
- Validate with Xcode's Widget Gallery simulator presets

---

## 8. Platform-Specific Behaviors

### visionOS — Do NOT apply Liquid Glass

visionOS 3 does **not** adopt iOS 26 Liquid Glass. It retains its own volumetric glass system.

```swift
#if os(iOS) || os(macOS)
    .glassEffect(.regular)
#elseif os(visionOS)
    .glassBackgroundEffect()  // visionOS-specific API
#endif
```

### macOS 26 (Tahoe)

- Window title bars and toolbars: Liquid Glass by default
- Sidebars (Messages, Mail, etc.): same glass treatment as iPadOS
- Menu bar: opaque by default; Glass Menu Bar option in System Settings > Desktop & Dock
- Cursor hover: glass surfaces shift lighting with pointer position (automatic for standard controls; custom views opt in via `.hoverEffect(.highlight)`)

### watchOS 12

- Simplified shaders; blur radius 5-10pt (vs. 10-20pt on iPhone)
- Real-time refraction disabled
- Complications: opaque at rest (battery), glass only in interactive states
- Avoid conditional backgrounds in watchOS widgets (causes transparency bugs)

---

## 9. Layering Rules and Performance

**Critical constraints:**

- Maximum **2 overlapping translucent layers** — beyond this causes visual muddiness
- Limit to **3-5 glass layers per view hierarchy** for GPU performance
- All shaders are Metal-based; profile with Xcode Shader Profiler for overdraw
- Animations auto-pause in Low Power Mode
- On macOS laptop on battery: auto-throttles to 60Hz with reduced refraction complexity

### Materials Reference

| Material                        | Usage                                                 |
| ------------------------------- | ----------------------------------------------------- |
| `.liquidGlass`                  | Primary Liquid Glass material (iOS 26+)               |
| `UIBlurEffectStyle.liquidGlass` | UIKit equivalent for `UIVisualEffectView` backgrounds |
| `.backgroundUltraThin`          | Beneath panels; auto hue-shifts for 4.5:1 contrast    |
| `.regularMaterial`              | iOS 15-25 fallback                                    |
| `.thickMaterial`                | Higher-opacity iOS 15-25 fallback                     |

Default blur radius: 10-20pt (iPhone), 15-25pt (iPad). Do not manually replicate blur — use system materials.

---

## 10. Common Bugs and Fixes

### Double-Frosting in Modal Sheets (SwiftUI)

```swift
// Fix: remove sheet's own background, let parent's glass show through
.sheet(isPresented: $showSheet) {
    SheetContent()
        .presentationBackground(.clear)
}
```

### Double-Frosting in Modal Sheets (UIKit)

```swift
override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    if let shadowView = view.superview?.superview {
        shadowView.backgroundColor = .clear
    }
}
// WARNING: This is fragile and breaks on swipe-to-dismiss. File a radar.
```

Use `GlassEffectContainer` to prevent double-frosting in multi-glass layouts:

```swift
GlassEffectContainer {
    VStack(spacing: 0) {
        headerView.glassEffect(.identity)
        bodyView.glassEffect(.clear)
    }
}
```

### Text Legibility on Dynamic Wallpapers

```swift
// Use system-provided contrast adaptation
Text("Title")
    .foregroundStyle(.primary)

// Add subtle text shadow for additional safety
Text("Title")
    .shadow(color: .black.opacity(0.3), radius: 2, x: 0, y: 1)
```

Test with Accessibility Inspector High Contrast mode to validate worst cases.

### Widget Fully Transparent Background

Remove any explicit `.background(.clear)` from Widget/LiveActivity views. See Section 7.

### Icon Corner Optical Distortion (iOS 26.0 bug)

Icons with high-contrast edges at corners can appear tilted due to a refraction shader bug (partially fixed in iOS 26.2).

Mitigations:

- Avoid solid black or white elements at icon corners
- Apply higher blur radius (30-50) to outermost Icon Composer groups
- Offer alternate flat icon via `UIApplication.setAlternateIconName()` for affected users

---

## 11. Icon Composer Workflow

Access via: **Xcode > Open Developer Tool > Icon Composer** (or standalone download from Apple Developer Downloads; requires macOS 25+).

### Layer Structure

- Deconstruct icon into separate layers in Figma/Sketch/XD before importing
- Separate by depth and by color for maximum control
- Export PNG or SVG with transparent backgrounds (1024x1024 minimum)
- Maximum **4 depth groups** (Group 1 = back, Group 4 = front)

**Example (messaging app):**

- Group 1: Background circle
- Group 2: Speech bubble body
- Group 3: Speech bubble tail
- Group 4: Text/glyph

### Export and Xcode Integration

1. Save as `.icon` file from Icon Composer
2. In Xcode: Project Settings > App Icons and Launch Screen
3. Delete existing AppIcon asset
4. Drag `.icon` file into App Icons field

For App Store: **File > Export Marketing Assets** (flattened 1024x1024 PNG).

### Known Limitation

Interleaving layers across groups (Layer A behind B but in front of C, where C is behind B) is not directly supported — requires creative group restructuring or element splitting.

---

## 12. FluidKit (Advanced / Optional)

FluidKit is a declarative physics framework for advanced custom effects. Standard apps should use SwiftUI `.glassEffect()` instead.

```swift
import FluidKit

View {
    Button("Confirm Purchase")
        .physics(
            .surfaceTension(.high),
            .viscosity(.medium),
            .refractionIndex(1.33)  // Default is 1.33 (water-like); 1.5-1.8 for stronger effects
        )
        .onPress { processPurchase() }
}
```

FluidKit is currently in beta. Avoid in production until stable.

---

## 13. Deprecation and Compliance Timeline

| Date                | Event                                                                 |
| ------------------- | --------------------------------------------------------------------- |
| iOS 26.0 (Jul 2025) | Liquid Glass ships; `UILiquidGlassOptOut` available                   |
| iOS 26.1 (Nov 2025) | Tinted mode toggle added (Settings > Display & Brightness)            |
| iOS 27 (Sep 2026)   | `UILiquidGlassOptOut` deprecated; App Store warnings begin            |
| iOS 28 (Sep 2027)   | `UILiquidGlassOptOut` removed; opt-out apps fail App Store submission |

All apps must be Liquid Glass-compliant before the iOS 28 hard cutoff.

---

## 14. Migration Checklist

- [ ] Audit all custom `UIVisualEffectView` and blur implementations for duplication with system glass
- [ ] Replace legacy `TabView { .tabItem }` with new `Tab()` API where full glass is desired
- [ ] Handle `@Environment(\.accessibilityReduceTransparency)` in all glass views
- [ ] Validate 4.5:1 text contrast in Clear mode (the baseline — not just Tinted)
- [ ] Remove all `.background(.clear)` from Widget and Live Activity views
- [ ] Test on varied wallpapers (high-contrast, gradient, photo-based) using Xcode Simulator presets
- [ ] Add `#if os(visionOS)` guards and use `.glassBackgroundEffect()` on that platform
- [ ] Profile for GPU overdraw using Xcode Shader Profiler on A17+ devices
- [ ] Verify animations pause in Low Power Mode and Reduce Motion
- [ ] Rebuild app icons in Icon Composer as layered `.icon` files
- [ ] Test Tinted mode and Reduce Transparency accessibility settings

---

## References

- Apple Developer: [Applying Liquid Glass to custom views](https://developer.apple.com/documentation/swiftui/applying-liquid-glass-to-custom-views)
- Apple Developer: [Technology Overviews - Liquid Glass](https://developer.apple.com/documentation/TechnologyOverviews/liquid-glass)
- Apple Developer: [Adopting Liquid Glass](https://developer.apple.com/documentation/TechnologyOverviews/adopting-liquid-glass)
- WWDC25 Session 323: Build a SwiftUI app with the new design
- WWDC25 Session 284: Build a UIKit app with the new design
- WWDC25 Session 361: Create icons with Icon Composer
- HIG: [Materials](https://developer.apple.com/design/human-interface-guidelines/materials)

````
