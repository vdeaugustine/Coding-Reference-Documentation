# Modern macOS App Design with SwiftUI and Xcode

This is a single skill-reference guide for SwiftUI-first macOS apps in Xcode: Human Interface Guidelines alignment, native layout and interaction, state and AppKit bridging, and shipping (sandbox, notarization, Sparkle where applicable).

**Audience:** iOS developers moving to macOS, and Swift developers who want production-oriented patterns.

**Default deployment target:** macOS 14 (Sonoma) or later. Examples assume macOS 14+ APIs (including `@Observable` and `.inspector`). Where behavior differs on macOS 13, the text calls it out.

**Third-party libraries:** Prefer Apple frameworks. **Sparkle** is the documented exception for auto-updates outside the Mac App Store; there is no first-party equivalent. Avoid packages that rely on private AppKit introspection (for example window introspection helpers); they break across OS releases.

## Table of contents

1. [Design principles and visual language](#design-principles-and-visual-language)
2. [Scenes, windows, settings, and restoration](#scenes-windows-settings-and-restoration)
3. [Navigation, toolbars, split views, inspector, and window chrome](#navigation-toolbars-split-views-inspector-and-window-chrome)
4. [Visual design: color, typography, spacing, and SwiftUI patterns](#visual-design-color-typography-spacing-and-swiftui-patterns)
5. [Data presentation: lists, tables, and performance at scale](#data-presentation-lists-tables-and-performance-at-scale)
6. [Interaction: pointer, menus, drag and drop, edit commands, animation](#interaction-pointer-menus-drag-and-drop-edit-commands-animation)
7. [Keyboard focus](#keyboard-focus)
8. [State and architecture](#state-and-architecture)
9. [Forms, alignment, and `LabeledContent`](#forms-alignment-and-labeledcontent)
10. [AppKit bridging](#appkit-bridging)
11. [Specialized app types](#specialized-app-types)
12. [App lifecycle and `NSApplicationDelegateAdaptor`](#app-lifecycle-and-nsapplicationdelegateadaptor)
13. [Distribution outside the App Store: Sparkle](#distribution-outside-the-app-store-sparkle)
14. [App Sandbox, entitlements, and hardened runtime](#app-sandbox-entitlements-and-hardened-runtime)
15. [App icon design for macOS 26+](#app-icon-design-for-macos-26)
16. [iOS developer cheat sheet: macOS differences](#ios-developer-cheat-sheet-macos-differences)
17. [Accessibility and localization](#accessibility-and-localization)
18. [Production decisions](#production-decisions)
19. [Master checklist](#master-checklist)
20. [References](#references)

---

## Design principles and visual language

### Platform conventions and mental model

Apple encourages apps that feel at home on macOS by following established patterns for windows, menus, toolbars, sidebars, and keyboard-driven workflows. Users expect rich pointer and keyboard interaction, powerful multiwindow behavior, and content-first layouts that avoid mobile-style full-screen views.[^2][^1]

Key principles:

- Use standard macOS controls and patterns (toolbar, sidebar, tables, menus) before inventing custom UI.[^1]
- Prefer information-dense layouts with clear hierarchy over oversized, touch-first designs.[^4][^1]
- Support multiple windows, resizable content, and flexible layouts by default.[^4][^1]

### Visual style for modern macOS

Modern macOS design emphasizes translucency, depth, and subtle blurs, while maintaining strong contrast and legibility. Use system materials, vibrancy, and SF Symbols to create a cohesive look that adapts to light and dark appearances.[^5][^6][^1]

Guidelines:

- Use system materials (such as `.ultraThinMaterial`) for sidebars and overlays, not manual alpha blending on raw colors.[^5]
- Respect system accent color and vibrancy instead of hardcoding brand colors into core controls.[^1]
- Use SF Symbols consistently for iconography, matching weight and scale to surrounding text.[^1]

### Scenes and commands at a glance

Modern macOS apps use SwiftUI’s scene APIs to define windows, settings, menu bar extras, and document-based workflows. In your `@main` `App`, compose `WindowGroup`, `Settings`, and optional `MenuBarExtra` or `DocumentGroup` scenes. Provide menu commands with the `.commands` modifier for global actions, shortcuts, and standard menu structure.

- Define a primary `WindowGroup` for main navigation and content.
- Use additional scenes (`Settings`, `DocumentGroup`, singleton `Window`) instead of stacking app-level work in sheets when a separate window is more native.
- Follow the standard menu structure (App, File, Edit, View, Window, Help) and add custom menus only when necessary.

---

## Scenes, windows, settings, and restoration

### macOS Settings Pane

The `Settings` scene renders as the standard macOS Settings window (Cmd+,), with a toolbar-style tab switcher automatically applied on macOS 13+.

```swift
@main
struct MyApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }

        Settings {
            SettingsView()
        }
    }
}

struct SettingsView: View {
    private enum Tabs: Hashable {
        case general, appearance, advanced
    }
    @State private var selectedTab: Tabs = .general

    var body: some View {
        TabView(selection: $selectedTab) {
            GeneralSettingsView()
                .tabItem {
                    Label("General", systemImage: "gear")
                }
                .tag(Tabs.general)

            AppearanceSettingsView()
                .tabItem {
                    Label("Appearance", systemImage: "paintbrush")
                }
                .tag(Tabs.appearance)

            AdvancedSettingsView()
                .tabItem {
                    Label("Advanced", systemImage: "slider.horizontal.3")
                }
                .tag(Tabs.advanced)
        }
        .frame(width: 480)
        .fixedSize()
    }
}
```

Key points:

- Use `.fixedSize()` on the `TabView` so the Settings window snaps to its content size as tabs are switched; this matches native macOS Settings behavior.
- Each tab's height will flex to its content, but keep panes to a consistent width (typically 480-560pt).
- Persist settings using `@AppStorage`, which writes to `UserDefaults` automatically.

```swift
struct GeneralSettingsView: View {
    @AppStorage("launchAtLogin") private var launchAtLogin = false
    @AppStorage("refreshInterval") private var refreshInterval = 30

    var body: some View {
        Form {
            Toggle("Launch at Login", isOn: $launchAtLogin)
            Picker("Refresh Interval", selection: $refreshInterval) {
                Text("15 seconds").tag(15)
                Text("30 seconds").tag(30)
                Text("1 minute").tag(60)
            }
        }
        .padding()
    }
}
```


### Window Management: `openWindow`, `dismissWindow`, and `Window`

#### `WindowGroup` vs `Window`

| Feature            | `WindowGroup`              | `Window`                        |
| ------------------ | -------------------------- | ------------------------------- |
| Multiple instances | Yes; user can open many   | No; exactly one instance       |
| Best for           | Documents, per-item detail | Inspector panels, About windows |
| Identified by      | `id` + optional value type | `id` only                       |

Use `Window` for singleton utility windows such as an About panel or a log viewer. Use `WindowGroup` for anything where the user might want multiple copies open simultaneously.

#### Programmatic window control

```swift
// Declare windows in your App
@main
struct MyApp: App {
    var body: some Scene {
        WindowGroup(id: "main") {
            ContentView()
        }

        Window("Inspector", id: "inspector") {
            InspectorView()
        }
        .defaultSize(width: 300, height: 500)
        .windowResizability(.contentSize)
    }
}

// Open and dismiss from any view
struct ContentView: View {
    @Environment(\.openWindow) private var openWindow
    @Environment(\.dismissWindow) private var dismissWindow

    var body: some View {
        Button("Show Inspector") {
            openWindow(id: "inspector")
        }
        Button("Close Inspector") {
            dismissWindow(id: "inspector")
        }
    }
}
```

For data-driven windows, pass a value to `openWindow` and define the `WindowGroup` with a matching type:

```swift
WindowGroup(for: NoteItem.ID.self) { $noteID in
    if let id = noteID, let note = store.note(id: id) {
        NoteDetailView(note: note)
    }
}

// Open a window for a specific note
openWindow(value: note.id)
```


### Window state restoration and `@SceneStorage`

### Window State Restoration

macOS automatically restores window positions and sizes across app launches via `NSWindow` state restoration. SwiftUI participates in this automatically for `WindowGroup`; the system saves and restores window frames without any code on your part.

#### Controlling restoration behavior per window

Use `.restorationBehavior()` to opt windows in or out:

```swift
// Default: system restores this window's position automatically
WindowGroup {
    ContentView()
}

// Disable restoration for a singleton utility window (e.g., About)
Window("About", id: "about") {
    AboutView()
}
.restorationBehavior(.disabled)
```

#### Per-scene state with `@SceneStorage`

`@SceneStorage` persists values per window instance and restores them on relaunch. Unlike `@AppStorage`, it is scoped to the scene, so two open windows of the same `WindowGroup` each get their own independent stored values.

```swift
struct DocumentView: View {
    // Each window independently restores its own selected tab and scroll position
    @SceneStorage("selectedTab") private var selectedTab = "outline"
    @SceneStorage("zoomLevel") private var zoomLevel = 1.0

    var body: some View {
        TabView(selection: $selectedTab) {
            OutlineView()
                .tabItem { Label("Outline", systemImage: "list.bullet") }
                .tag("outline")
            PreviewView(zoom: zoomLevel)
                .tabItem { Label("Preview", systemImage: "eye") }
                .tag("preview")
        }
    }
}
```

`@SceneStorage` supports `Bool`, `Int`, `Double`, `String`, `URL`, and `Data`. For complex model state, encode to `Data` with `JSONEncoder` and store that.

**The difference between `@AppStorage` and `@SceneStorage`:**

| Property Wrapper | Scope                | Backed by          | Use for                                                    |
| ---------------- | -------------------- | ------------------ | ---------------------------------------------------------- |
| `@AppStorage`    | Entire app           | `UserDefaults`     | Preferences, settings, global flags                        |
| `@SceneStorage`  | Single window/scene  | System scene state | Tab selection, scroll position, zoom, UI layout per window |
| `@State`         | Single view instance | Memory only        | Transient UI state, not persisted                          |

---

## Navigation, toolbars, split views, inspector, and window chrome

### NavigationSplitView and column-based layouts

For productivity-style apps, prefer `NavigationSplitView` for the canonical multi-column layout: sidebar, optional list, and detail. Use `.navigationSplitViewColumnWidth` for minimum and ideal widths so layouts survive window resizing.

Typical roles:

- First column: high-level categories or sources.
- Second column: items in the selected category (when using three columns).
- Third column (or detail when two columns): content for the selection.

The toolbar should expose the most important actions for the current context; the sidebar holds structural navigation. Avoid turning the toolbar into a second navigation bar. Use `.toolbar` on your content, and provide sidebar toggling via `SidebarCommands()`. Use segmented controls or toolbar pickers only for small, mutually exclusive modes.

### `NavigationSplitView`: selection binding and empty detail

The most common stumbling block for macOS newcomers: binding the sidebar selection to the detail view. The trick is to bind `List`'s `selection` parameter to an optional state variable, then conditionally render in the detail column.

```swift
struct Item: Identifiable, Hashable {
    var id = UUID()
    var title: String
}

@Observable
class AppStore {
    var items: [Item] = [
        Item(title: "Project Alpha"),
        Item(title: "Project Beta"),
        Item(title: "Project Gamma")
    ]
}

struct RootView: View {
    @Environment(AppStore.self) private var store
    @State private var selectedItem: Item?

    var body: some View {
        NavigationSplitView {
            List(store.items, selection: $selectedItem) { item in
                NavigationLink(value: item) {
                    Label(item.title, systemImage: "folder")
                }
            }
            .navigationTitle("Projects")
        } detail: {
            if let item = selectedItem {
                DetailView(item: item)
            } else {
                ContentUnavailableView(
                    "No Selection",
                    systemImage: "sidebar.left",
                    description: Text("Choose a project from the sidebar.")
                )
            }
        }
    }
}
```

Key points:

- `List(selection:)` with an `Optional` binding automatically handles single selection, including keyboard navigation with arrow keys and Space/Enter to confirm.
- `ContentUnavailableView` (macOS 14+) is the canonical placeholder for empty detail states.
- To set a default selection on launch, set the initial value of `selectedItem` in an `.onAppear` or as part of the `@State` initializer: `@State private var selectedItem: Item? = store.items.first`.


### Toolbars, inspector, and window chrome

#### Customizing the window chrome

Modern macOS apps like Safari, Xcode, and Notes use unified window designs where the content extends behind the title bar or toolbar, creating depth through translucency.

#### Approach 1: Hidden title bar (unified toolbar)

This is the most common pattern: the content view fills the full window height and the title bar becomes transparent, blending with your toolbar or background material.

```swift
WindowGroup {
    ContentView()
        .toolbarBackgroundVisibility(.hidden, for: .windowToolbar)
        .containerBackground(.thinMaterial, for: .window)
}
.windowStyle(.hiddenTitleBar)
```

#### Approach 2: Keep the title, hide just the toolbar separator

If you want the title to remain visible but remove the visual separator between toolbar and content (common in productivity apps):

```swift
WindowGroup {
    ContentView()
        .toolbarBackgroundVisibility(.hidden, for: .windowToolbar)
}
```

#### Approach 3: Full-bleed hero image behind title bar

For apps where a large image or gradient should extend to the very top edge of the window:

```swift
struct ContentView: View {
    var body: some View {
        ZStack(alignment: .top) {
            LinearGradient(
                colors: [.teal.opacity(0.6), .blue.opacity(0.75)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            VStack {
                // content
            }
        }
        .toolbar(removing: .title)
        .toolbarBackgroundVisibility(.hidden, for: .windowToolbar)
    }
}
```

For fine-grained AppKit-level control (e.g., moving the traffic light buttons), use `NSViewRepresentable` with `NSWindow` access as described in the [AppKit bridging](#appkit-bridging) section.



### The `Inspector` API

The `Inspector` is a trailing sidebar that displays metadata or settings for whatever is currently selected in the main content area. Apps like Apple Notes, Pages, and Keynote use this pattern extensively. On macOS 14+ and iPadOS 17+, it renders as a resizable column attached to the trailing edge of the window. On iPhone, it collapses to a sheet.

**HIG context:** Use the Inspector for contextual metadata, formatting options, and properties of a selected item. Do not use it for primary navigation or for content that the user always needs visible; that belongs in the main content or sidebar. The Inspector should be dismissible.

### Basic inspector

```swift
struct DocumentEditor: View {
    @State private var isInspectorPresented = true
    @State private var selectedItem: DocumentItem?

    var body: some View {
        TextEditor(text: $documentText)
            .inspector(isPresented: $isInspectorPresented) {
                InspectorContent(item: selectedItem)
                    .inspectorColumnWidth(min: 200, ideal: 280, max: 400)
            }
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        isInspectorPresented.toggle()
                    } label: {
                        Label("Inspector", systemImage: "sidebar.right")
                    }
                }
            }
    }
}

struct InspectorContent: View {
    var item: DocumentItem?

    var body: some View {
        if let item {
            Form {
                LabeledContent("Created", value: item.created.formatted())
                LabeledContent("Word count", value: item.wordCount.formatted())
                Picker("Font", selection: .constant("San Francisco")) {
                    Text("San Francisco").tag("San Francisco")
                    Text("New York").tag("New York")
                }
            }
            .formStyle(.grouped)
            .navigationTitle("Inspector")
        } else {
            ContentUnavailableView("No Selection", systemImage: "doc")
        }
    }
}
```

`.inspectorColumnWidth(min:ideal:max:)` controls the width range. The user can drag the divider within this range.

**Common gotchas:**

- As of early 2026, there is a known crash when the user drags the inspector divider in certain configurations. Wrapping the inspector content in a `NavigationStack` can reduce this. File feedback with Apple if you hit it.
- The `.inspector` modifier must be applied to the **content view**, not to `NavigationSplitView` itself. Place it on the detail column view.
- On macOS 13, use a manual trailing column in `NavigationSplitView` as a fallback; the `.inspector` modifier does not exist there.


---

## Visual design: color, typography, spacing, and SwiftUI patterns

### Color and materials

Color should support hierarchy and meaning rather than act as the primary decoration. Modern macOS design leans on system background colors, semantic roles, and accent color to ensure consistency across apps and appearances.[^2][^1]

Best practices:

- Use semantic colors from SwiftUI (such as `.background`, `.secondary`, `.accentColor`) that adapt to light and dark mode.[^5]
- Use materials for cards, panels, and sidebars to create depth without breaking contrast requirements.[^5]
- Reserve strong, saturated colors for primary actions and status indicators, not for large background areas.[^1]

### Typography and hierarchy

San Francisco is the standard system typeface on macOS and provides dynamic optical sizes and weights tuned for Apple displays. Use SwiftUI text styles instead of fixed point sizes to get consistent, legible typography that responds to system settings.[^7][^2]

Recommendations:

- Use text styles such as `.title`, `.headline`, `.body`, and `.caption` instead of hardcoded font sizes.[^8]
- Maintain a clear typographic hierarchy by limiting yourself to three or four levels of emphasis in any view.[^2]
- Use `.foregroundStyle(.secondary)` for subordinate text, labels, and helper descriptions.[^5]

### Spacing, alignment, and density

Well-chosen spacing and alignment create the perception of elegance and calmness even in information-dense apps. macOS layouts can afford more whitespace than dense mobile UIs, but should still present information efficiently.[^1]

Guidelines:

- Use consistent spacing tokens in your layout (for example, 8, 12, 16, 24) and apply them via SwiftUI padding and `spacing` parameters.[^5]
- Align content to a grid in lists and tables, and avoid arbitrary offsets that break vertical rhythm.[^1]
- Provide generous padding inside cards and panels so content does not press against rounded corners or window edges.[^5]

## SwiftUI Patterns for macOS Elegance

### A styled card view example

The following pattern shows how to build adaptive, macOS-style cards using materials, environment-aware colors, and subtle hierarchy.[^5]

```swift
import SwiftUI

struct StatusCard: View {
    @Environment(\.colorScheme) private var colorScheme

    var title: String
    var message: String
    var icon: String
    var tint: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label(title, systemImage: icon)
                .font(.headline)
                .foregroundStyle(tint)

            Text(message)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
    }

    private var cardBackground: some View {
        Group {
            if colorScheme == .dark {
                Color.white.opacity(0.05)
            } else {
                Color.black.opacity(0.03)
            }
        }
    }
}
```

This pattern uses environment-aware colors, continuous corner radii, and spacing that matches Apple’s modern macOS look while respecting light and dark appearances.[^5]

### Using materials and vibrancy

Use materials to create translucent surfaces that respond to desktop backgrounds and window content while maintaining contrast.

```swift
struct SidebarItemView: View {
    var title: String

    var body: some View {
        Text(title)
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
    }
}
```

This approach yields a sidebar-like appearance that feels native on current macOS releases using `.ultraThinMaterial` and standard spacing.[^5]

### Custom yet native-feeling button styles

Custom button styles can differentiate your brand while remaining firmly within macOS norms.

```swift
struct PrimaryMacButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 6, style: .continuous)
                    .fill(configuration.isPressed
                          ? Color.accentColor.opacity(0.8)
                          : Color.accentColor)
            )
            .foregroundColor(.white)
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
    }
}
```

Apply this style using `.buttonStyle(PrimaryMacButtonStyle())` on critical actions to create a polished primary button that respects the system accent color.[^5]

---

## Data presentation: lists, tables, and performance at scale

### Lists and tables (overview)

Lists and tables are central to macOS productivity apps: prefer compact rows, clear selection, and SF Symbols plus secondary text for metadata. Use `List` with `selection` for navigation and single-column data; use `Table` when multiple columns, sorting, and header affordances matter.

### Feedback, animations, and motion

### Feedback, animations, and motion

Animations on macOS should be subtle, purposeful, and fast, enhancing clarity rather than showing off. SwiftUI makes it easy to add animations and transitions that remain interruptible and performant.[^8]

Rules of thumb:

- Animate state changes that affect layout or selection, such as expanding rows or changing filters.[^8]
- Use system-like transitions, such as opacity and small-scale transitions, instead of large, sweeping motions more suited to mobile.[^8]
- Avoid long or looping animations that distract from primary content.[^8]

### Multi-column `Table` and data grids

`Table` is the native macOS data grid. Unlike iOS `List`, which is a single-column vertical scroller, `Table` provides true multi-column layout with header rows, sortable columns, resizable columns, column hiding, and multi-row selection. Think of it as the SwiftUI equivalent of `NSTableView`.

**HIG context:** Use `Table` when displaying structured data where multiple attributes of each item are equally important (file managers, contact lists, log viewers, task trackers). Reserve single-column `List` for sidebar navigation and simple item pickers.

### Basic sortable table

```swift
import SwiftUI

struct FileItem: Identifiable {
    var id = UUID()
    var name: String
    var size: Int          // bytes
    var modified: Date
}

struct FileTableView: View {
    @State private var files: [FileItem] = FileItem.sampleData
    @State private var selection = Set<FileItem.ID>()
    @State private var sortOrder = [KeyPathComparator(\FileItem.name)]

    var body: some View {
        Table(files, selection: $selection, sortOrder: $sortOrder) {
            TableColumn("Name", value: \.name)
            TableColumn("Size") { item in
                Text(item.size.formatted(.byteCount(style: .file)))
                    .monospacedDigit()
            }
            .width(min: 80, ideal: 100)

            TableColumn("Modified", value: \.modified) { item in
                Text(item.modified.formatted(date: .abbreviated, time: .omitted))
            }
            .width(min: 100, ideal: 140)
        }
        .onChange(of: sortOrder) { _, newOrder in
            files.sort(using: newOrder)
        }
    }
}
```

`KeyPathComparator` drives sorting. Binding `sortOrder` to the `Table` makes header taps automatically update the sort order and add the sort indicator arrow. The `.onChange` applies the new order to your data source.

### Column customization (show/hide, reorder)

macOS 13+ allows users to hide and reorder columns via the table header context menu. Opt in by persisting a `TableColumnCustomization` value:

```swift
struct FileTableView: View {
    @AppStorage("fileTableColumns")
    private var columnCustomization = TableColumnCustomization<FileItem>()

    var body: some View {
        Table(files, selection: $selection, sortOrder: $sortOrder,
              columnCustomization: $columnCustomization) {
            TableColumn("Name", value: \.name)
                .customizationID("name")    // required for persistence

            TableColumn("Size") { ... }
                .customizationID("size")

            TableColumn("Modified", value: \.modified) { ... }
                .customizationID("modified")
        }
    }
}
```

`@AppStorage` persists the column state across launches automatically. Each column needs a unique `.customizationID` or the system cannot track which column is which.

### Context menus on table rows

Applying `.contextMenu` directly to a `Table` attaches it at the table level, which does not receive row identity. To get a per-row context menu with access to the specific item, attach it inside the column's cell view and expand the hit area so the entire cell responds:

```swift
TableColumn("Name", value: \.name) { item in
    Text(item.name)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
        .contentShape(Rectangle())   // expand hit area to full cell
        .contextMenu {
            Button("Rename") { rename(item) }
            Button("Delete", role: .destructive) { delete(item) }
        }
}
```

**Common gotchas:**

- `Table` on macOS scrolls vertically **and** horizontally if columns overflow the window width. This is automatic; do not wrap `Table` in a `ScrollView`.
- On macOS 13, use `List(selection:)` with manual column-like `HStack` rows as a fallback; `TableColumnCustomization` requires macOS 14.

### View composition and window resizing

## Performance and Responsiveness

### Efficient view composition

SwiftUI’s declarative approach encourages smaller, composable views that can be reused across windows and screens. This fosters both performance and visual consistency.[^8][^4]

Recommendations:

- Extract repeated patterns (cards, rows, toolbars) into reusable views with clear input properties.[^8]
- Avoid heavy work in view body computations; push expensive work into asynchronous tasks or models.[^8]
- Use `@MainActor` and appropriate concurrency primitives when bridging with async work to keep the UI responsive.[^8]

### Handling window resizing and layout changes

macOS windows are expected to be resizable in both dimensions, sometimes down to compact sizes. SwiftUI adaptive layouts using stacks, `GeometryReader` where necessary, and flexible frames give users freedom without sacrificing polish.[^1]

Guidelines:

- Test your layouts at multiple sizes in Xcode previews and live running windows.[^8]
- Use `frame(minWidth:idealWidth:maxWidth:minHeight:idealHeight:maxHeight:alignment:)` thoughtfully to express the constraints you actually need.[^5]
- Avoid relying on fixed coordinates or `GeometryReader` hacks where standard layout tools are sufficient.

### Containers at large scale (`List`, `LazyVStack`, `Table`)

Mac apps regularly handle datasets of 10,000 to 100,000+ rows; think file browsers, log viewers, analytics dashboards. Choosing the right container is critical.

#### How each container handles large data

`List` on macOS uses cell reuse similar to `UITableView` on iOS, but its macOS implementation has historically been less aggressive about reuse. At around 5,000-10,000 rows, scrolling can become sluggish and memory can spike because `List` tends to keep more views alive than strictly necessary.

`LazyVStack` inside a `ScrollView` is lazy only in the sense that it defers view creation until rows enter the visible area. However, it does **not** discard views that scroll out of the visible area on macOS; they remain in memory. This makes `LazyVStack` faster than `List` for initial scroll performance but more memory-hungry at very large counts. It also cannot natively support row selection or multi-selection.

`Table` is the right choice for very large datasets on macOS. Its AppKit foundation (`NSTableView`) is designed for efficient cell reuse and has been optimized for tens of thousands of rows. If you need sortable columns, `Table` is the only native SwiftUI option.

| Container                                      | View Reuse                | Handles 10k+ rows?   | Multi-select | Sortable columns | When to use                              |
| ---------------------------------------------- | ------------------------- | -------------------- | ------------ | ---------------- | ---------------------------------------- |
| `List`                                         | Partial (macOS)           | Degrades at ~5k      | Yes          | No               | Navigation, sidebars, smaller datasets   |
| `LazyVStack`                                   | None (keeps in memory)    | High memory at scale | Manual       | No               | Custom row layouts, smaller datasets     |
| `Table`                                        | Full (NSTableView-backed) | Yes                  | Yes          | Yes              | Data grids, large datasets, multi-column |
| Custom `NSTableView` via `NSViewRepresentable` | Full                      | Yes                  | Yes          | Yes              | Maximum performance, legacy code         |

#### Optimizing `List` for large datasets

When you must use `List` (e.g., because you need sidebar-style appearance), reduce work per row:

```swift
List(items, id: \.id, selection: $selection) { item in
    ListRow(item: item)
        // Keep row bodies cheap; no heavy computation, no network calls
        .id(item.id)   // stable identity prevents unnecessary re-renders
}
// Avoid .listStyle(.inset) on macOS for large lists; it adds overhead
.listStyle(.plain)
```

Extract rows into separate `View` structs. SwiftUI can diff struct identity cheaply, but a large inline closure forces full recomputation.

#### When to reach for a custom `NSTableView`

If your dataset is 100,000+ rows, you have variable-height rows with complex content (attributed strings, inline images), or you need fine-grained scrolling performance, wrap `NSTableView` via `NSViewControllerRepresentable` for maximum control. This is the approach that apps like Xcode's Issue Navigator and Console use.

**Common gotchas:**

- Never put a `LazyVStack` inside a `List`. `List` already provides its own scroll container, and nesting them produces layout ambiguity and broken scroll behavior.
- Avoid calling `@Observable` properties inside `List` row bodies that trigger the parent to re-render. Scope `@Observable` objects to individual row view models so only the affected row re-renders.

---

## Interaction: pointer, menus, drag and drop, edit commands, animation

### Menus, shortcuts, and context menus

Integrate with the menu bar using `.commands` and `CommandGroup`. Add `.keyboardShortcut` to important actions. Use context menus for secondary actions on rows, cells, and icons instead of cluttering the primary UI.

### macOS-Specific Interactions

These interactions do not exist on iOS and are expected by macOS users. Skipping them makes an app feel like a poorly ported mobile app.

#### Hover states

Use `.onHover` to react when the pointer enters or exits a view. This is ideal for revealing delete buttons, highlighting rows, or showing contextual controls.

```swift
struct HoverableRow: View {
    var title: String
    @State private var isHovered = false

    var body: some View {
        HStack {
            Text(title)
            Spacer()
            if isHovered {
                Button(action: {}) {
                    Image(systemName: "trash")
                        .foregroundStyle(.red)
                }
                .buttonStyle(.plain)
                .transition(.opacity.combined(with: .scale(0.8)))
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .fill(isHovered ? Color.accentColor.opacity(0.08) : Color.clear)
        )
        .onHover { hovering in
            withAnimation(.easeInOut(duration: 0.15)) {
                isHovered = hovering
            }
        }
    }
}
```

For more granular control of the pointer position within a view, use `.onContinuousHover`:

```swift
.onContinuousHover { phase in
    switch phase {
    case .active(let location):
        pointerLocation = location
    case .ended:
        pointerLocation = nil
    }
}
```

#### Tooltips

Provide inline help text that appears when the user hovers over a control for a moment. This is standard Mac UX and Apple's HIG recommends it for every icon-only button.

```swift
Button(action: exportDocument) {
    Image(systemName: "square.and.arrow.up")
}
.help("Export document as PDF")
```

#### Drag and Drop

SwiftUI's modern drag-and-drop system uses the `Transferable` protocol, `.draggable()`, and `.dropDestination()`. Any type that conforms to `Transferable` can participate.

```swift
// Make your model Transferable
struct NoteItem: Identifiable, Codable, Transferable {
    var id = UUID()
    var title: String

    static var transferRepresentation: some TransferRepresentation {
        CodableRepresentation(contentType: .data)
    }
}

// Drag source
Text(note.title)
    .draggable(note)

// Drop destination
List(items, id: \.id) { item in
    Text(item.title)
}
.dropDestination(for: NoteItem.self) { droppedItems, location in
    items.append(contentsOf: droppedItems)
    return true
} isTargeted: { isTargeted in
    dropHighlighted = isTargeted
}
```

You can also accept external drops (files from Finder) by using `UTType.fileURL` as the Transferable type.

#### Native Cut, Copy, and Paste

Implement `EditCommands()` in your `.commands` block to get the standard Edit menu for free. For custom copy/paste behavior on specific views, use the `.copyable`, `.cuttable`, and `.pasteDestination` modifiers (macOS 13+):

```swift
List(selection: $selectedNote) {
    ForEach(notes) { note in
        Text(note.title)
    }
}
.copyable(notes.filter { selectedNote == $0.id })
.pasteDestination(for: NoteItem.self) { pasted in
    notes.append(contentsOf: pasted)
}
```

For older-style integration, you can also override `NSResponder` methods via an `NSViewRepresentable` coordinator.


---

## Keyboard focus

### `@FocusState` and key handling

On macOS, keyboard focus is a first-class navigation mechanism. Users expect to tab between fields, use Space to trigger buttons, and press Escape to dismiss. Unlike iOS where focus is mostly about the software keyboard, macOS focus determines which view receives keyboard events at any moment.

**HIG context:** Every interactive view in a macOS app should be keyboard-accessible. Focus should move predictably with Tab and Shift+Tab. Custom key handling (Space to preview, arrow keys to change selection) is expected in productivity apps.

### Basic `@FocusState` for field routing

```swift
struct LoginForm: View {
    @State private var email = ""
    @State private var password = ""
    @FocusState private var focusedField: Field?

    enum Field { case email, password }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            TextField("Email", text: $email)
                .focused($focusedField, equals: .email)
                .onSubmit { focusedField = .password }

            SecureField("Password", text: $password)
                .focused($focusedField, equals: .password)
                .onSubmit { submitForm() }

            Button("Sign In", action: submitForm)
                .keyboardShortcut(.defaultAction)
        }
        .onAppear { focusedField = .email }
    }

    private func submitForm() { /* ... */ }
}
```

`.keyboardShortcut(.defaultAction)` makes Return always trigger the primary button, matching macOS convention.

### Capturing arbitrary key presses outside text fields

For Quick Look-style Space-to-preview, arrow-key navigation in a custom canvas, or game-like key input, use `.onKeyPress` on a focusable view (macOS 14+):

```swift
struct MediaBrowser: View {
    @State private var selectedIndex = 0
    @FocusState private var isFocused: Bool
    var items: [MediaItem]

    var body: some View {
        LazyVGrid(columns: [GridItem(.adaptive(minimum: 120))]) {
            ForEach(items.indices, id: \.self) { index in
                MediaThumbnail(item: items[index],
                               isSelected: selectedIndex == index)
                    .onTapGesture { selectedIndex = index }
            }
        }
        .focusable()
        .focused($isFocused)
        .onKeyPress(.space) {
            openQuickLook(items[selectedIndex])
            return .handled
        }
        .onKeyPress(.leftArrow) {
            selectedIndex = max(0, selectedIndex - 1)
            return .handled
        }
        .onKeyPress(.rightArrow) {
            selectedIndex = min(items.count - 1, selectedIndex + 1)
            return .handled
        }
        .onKeyPress(.return) {
            openItem(items[selectedIndex])
            return .handled
        }
        .onAppear { isFocused = true }
    }
}
```

Return `.handled` to stop the event propagating further up the responder chain, or `.ignored` to let it continue.

### Tab order

SwiftUI infers tab order from the layout order in your view hierarchy. If you need a custom tab order, use `.focusSection()` to group views or rearrange the hierarchy. Avoid manually managing the responder chain through AppKit unless you have no other option.

**Common gotchas:**

- A view must call `.focusable()` before `.onKeyPress` will fire. Without it, key events are silently ignored.
- On macOS 13, `.onKeyPress` does not exist. Use `NSViewRepresentable` with `NSView.keyDown(with:)` as a fallback, or catch keyboard events via a `Commands` menu shortcut.
- Do not autofocus text fields on window open in every window; macOS convention is to let the user initiate typing. Only auto-focus on windows whose entire purpose is text entry (e.g., a search popover or a Spotlight-style bar).

---

## State and architecture

### Modern model layer: `@Observable` (macOS 14+)

On macOS 14+, prefer the `@Observable` macro over `ObservableObject` and `@Published`. Views update when they read properties that changed, which scales better in large trees.

### Modern State Management with `@Observable`

On macOS 14+, replace `ObservableObject` + `@Published` + `@StateObject` with the `@Observable` macro. It is more performant because views only re-render for the specific properties they actually read, not all `@Published` properties on the object.

#### Before (ObservableObject pattern)

```swift
class NoteStore: ObservableObject {
    @Published var notes: [NoteItem] = []
    @Published var selectedNote: NoteItem?
}

struct ContentView: View {
    @StateObject private var store = NoteStore()
}
```

#### After (@Observable pattern, macOS 14+)

```swift
import Observation

@Observable
class NoteStore {
    var notes: [NoteItem] = []
    var selectedNote: NoteItem?
}

struct ContentView: View {
    @State private var store = NoteStore()
}
```

The property wrappers to remember for the new model:

| Old Pattern          | New Pattern    | Notes                                           |
| -------------------- | -------------- | ----------------------------------------------- |
| `@StateObject`       | `@State`       | Used for ownership in the creating view         |
| `@ObservedObject`    | None needed    | Pass the `@Observable` object directly          |
| `@EnvironmentObject` | `@Environment` | Inject via `.environment(\.store, store)`       |
| `@Published`         | (removed)      | All stored properties are tracked automatically |

#### Critical gotcha with `@State` + `@Observable`

When you write `@State private var store = NoteStore()`, the initializer of `NoteStore` runs every time SwiftUI rebuilds the parent struct. SwiftUI preserves the _original_ stored value, but any expensive setup in `init` will still run repeatedly. For heavy initialization, create the object at the `App` level and inject it downward.

```swift
@main
struct MyApp: App {
    @State private var store = NoteStore()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(store)
        }
    }
}

struct ContentView: View {
    @Environment(NoteStore.self) private var store
}
```

### Legacy `ObservableObject` (maintenance and older targets)

If you must support older macOS versions or inherited code, `ObservableObject` with `@Published`, `@StateObject`, and `.environmentObject` remains valid. For new code on macOS 14+, migrate toward `@Observable`, `@State` for ownership at the app root, and `.environment(_:)` for injection.

### Per-window and global persistence

- **`@AppStorage`:** app-wide preferences (`UserDefaults`).
- **`@SceneStorage`:** per-window UI state restored with the scene (tabs, zoom, layout).
- **`@State`:** ephemeral view state, not persisted.

See [Scenes, windows, settings, and restoration](#scenes-windows-settings-and-restoration) for `@SceneStorage` and restoration APIs.

### AppKit when SwiftUI is not enough

Some problems (advanced text, fine window chrome, low-level keyboard handling) still need AppKit. Wrap focused `NSView` or `NSViewController` types with representables; keep SwiftUI owning layout and navigation. Use `NSWindowScene` only when you need platform window behavior that has no SwiftUI API yet.

---

## Forms, alignment, and `LabeledContent`


macOS forms have a characteristic look: labels are right-aligned to a vertical axis, and controls are left-aligned immediately after. This is dramatically different from iOS stacked forms. SwiftUI's `Form` with `.formStyle(.grouped)` delivers this layout automatically on macOS when you use `LabeledContent` and standard controls with labels.

**HIG context:** macOS forms use trailing-aligned labels because users are reading from left to right and always know what a control does before they look at it. Never mix left-aligned and right-aligned labels in the same form section.

### Using `LabeledContent` for native alignment

```swift
struct ProjectSettingsForm: View {
    @AppStorage("projectName") private var projectName = ""
    @AppStorage("autosave") private var autosave = true
    @AppStorage("backupInterval") private var backupInterval = 5
    @AppStorage("colorScheme") private var colorScheme = "system"

    var body: some View {
        Form {
            Section("General") {
                LabeledContent("Project Name") {
                    TextField("Untitled", text: $projectName)
                        .textFieldStyle(.roundedBorder)
                        .frame(maxWidth: 200)
                }

                Toggle("Autosave", isOn: $autosave)

                LabeledContent("Backup interval") {
                    Stepper("\(backupInterval) min",
                            value: $backupInterval,
                            in: 1...60)
                }
            }

            Section("Appearance") {
                Picker("Color scheme", selection: $colorScheme) {
                    Text("System").tag("system")
                    Text("Light").tag("light")
                    Text("Dark").tag("dark")
                }
                .pickerStyle(.radioGroup)
            }
        }
        .formStyle(.grouped)
        .padding()
        .frame(width: 400)
    }
}
```

`Form` with `.formStyle(.grouped)` automatically right-aligns all leading labels to a common edge and left-aligns all controls. This alignment is computed across the whole form, so you do not need to manually calculate label widths.

### Displaying read-only labeled values

`LabeledContent` is not only for interactive controls. It is also the canonical way to display read-only label/value pairs:

```swift
LabeledContent("File size", value: fileSize.formatted(.byteCount(style: .file)))
LabeledContent("Created", value: createdDate.formatted(date: .long, time: .shortened))
LabeledContent("Status") {
    Label("Active", systemImage: "checkmark.circle.fill")
        .foregroundStyle(.green)
}
```

**Common gotchas:**

- On macOS 13 or earlier, `Form` with `.formStyle(.grouped)` does not exist; use `.formStyle(.insetGrouped)` as the closest equivalent.
- Do not put a wide `TextField` directly in a `Form` without a `frame(maxWidth:)` constraint. It will stretch to fill the window, which breaks the macOS form aesthetic. Constrain text fields to a sensible width (typically 160-240pt).


---

## AppKit bridging

### `NSViewRepresentable` examples

#### Example 1: Wrapping `NSTextView` for rich text editing

SwiftUI's `TextEditor` is limited. Wrapping `NSTextView` directly gives you syntax highlighting, rich text, line numbers, and full delegate access.

```swift
import SwiftUI
import AppKit

struct RichTextEditor: NSViewRepresentable {
    @Binding var text: String

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    func makeNSView(context: Context) -> NSScrollView {
        let scrollView = NSTextView.scrollableTextView()
        guard let textView = scrollView.documentView as? NSTextView else {
            return scrollView
        }
        textView.delegate = context.coordinator
        textView.isRichText = false
        textView.font = NSFont.monospacedSystemFont(
            ofSize: NSFont.systemFontSize,
            weight: .regular
        )
        textView.drawsBackground = false
        textView.isAutomaticQuoteSubstitutionEnabled = false
        scrollView.drawsBackground = false
        return scrollView
    }

    func updateNSView(_ scrollView: NSScrollView, context: Context) {
        guard let textView = scrollView.documentView as? NSTextView else { return }
        if textView.string != text {
            textView.string = text
        }
    }

    class Coordinator: NSObject, NSTextViewDelegate {
        var parent: RichTextEditor

        init(_ parent: RichTextEditor) {
            self.parent = parent
        }

        func textDidChange(_ notification: Notification) {
            guard let textView = notification.object as? NSTextView else { return }
            parent.text = textView.string
        }
    }
}
```

Usage:

```swift
struct ContentView: View {
    @State private var code = ""

    var body: some View {
        RichTextEditor(text: $code)
            .frame(minHeight: 200)
    }
}
```

#### Example 2: Hosting a blurred `NSVisualEffectView`

For a sidebar or panel that needs a vibrancy effect not available from SwiftUI materials alone:

```swift
struct VibrancyBackground: NSViewRepresentable {
    var blendingMode: NSVisualEffectView.BlendingMode = .behindWindow
    var material: NSVisualEffectView.Material = .sidebar

    func makeNSView(context: Context) -> NSVisualEffectView {
        let view = NSVisualEffectView()
        view.blendingMode = blendingMode
        view.material = material
        view.state = .active
        return view
    }

    func updateNSView(_ view: NSVisualEffectView, context: Context) {
        view.blendingMode = blendingMode
        view.material = material
    }
}

// Use it as a background
struct MySidebar: View {
    var body: some View {
        List { /* ... */ }
            .background(VibrancyBackground())
    }
}
```

### `NSViewControllerRepresentable`

When porting a legacy Mac app with existing `NSViewController` subclasses, or when a third-party AppKit library exposes a view controller API, use `NSViewControllerRepresentable` to bring it into SwiftUI. The protocol is symmetric with `NSViewRepresentable` but wraps a view controller instead of a bare view, which is important when the wrapped component manages its own child view hierarchy or responds to `viewDidAppear`/`viewWillDisappear`.

```swift
import SwiftUI
import AppKit

// Imagine a legacy chart view controller you cannot rewrite yet
struct LegacyChartView: NSViewControllerRepresentable {
    var data: [DataPoint]
    var onSelectionChange: (DataPoint?) -> Void

    func makeCoordinator() -> Coordinator {
        Coordinator(onSelectionChange: onSelectionChange)
    }

    func makeNSViewController(context: Context) -> LegacyChartViewController {
        let vc = LegacyChartViewController()
        vc.delegate = context.coordinator
        return vc
    }

    func updateNSViewController(_ vc: LegacyChartViewController, context: Context) {
        // Called whenever SwiftUI state that this view depends on changes
        vc.setData(data, animated: true)
    }

    class Coordinator: NSObject, LegacyChartDelegate {
        var onSelectionChange: (DataPoint?) -> Void

        init(onSelectionChange: @escaping (DataPoint?) -> Void) {
            self.onSelectionChange = onSelectionChange
        }

        func chartDidSelectDataPoint(_ point: DataPoint?) {
            onSelectionChange(point)
        }
    }
}
```

Usage in SwiftUI:

```swift
LegacyChartView(data: chartData) { selected in
    selectedDataPoint = selected
}
.frame(minWidth: 400, minHeight: 300)
```

The `Coordinator` is the standard pattern for routing delegate callbacks from AppKit back into SwiftUI state changes. Create one in `makeCoordinator()` and attach it to the AppKit object in `makeNSViewController`. The coordinator persists for the lifetime of the representable, so it is safe to hold references.

**Key difference from `NSViewRepresentable`:** `NSViewControllerRepresentable` hands SwiftUI a full view controller, which means AppKit manages the view lifecycle (`loadView`, `viewDidLoad`, `viewWillAppear`, etc.). This is important when your AppKit component relies on those callbacks for setup.


---

## Specialized app types

### Menu bar apps with `MenuBarExtra`

Menu bar utilities are one of the most popular macOS app archetypes. With SwiftUI's `MenuBarExtra` scene, you can build them entirely without AppKit boilerplate.

#### Minimal menu bar only app

Replace `WindowGroup` in your `@main` `App` with `MenuBarExtra`. Add `LSUIElement = YES` to `Info.plist` to remove the Dock icon so the app lives exclusively in the menu bar.

```swift
@main
struct StatusApp: App {
    var body: some Scene {
        MenuBarExtra("My Utility", systemImage: "waveform") {
            StatusContentView()
                .frame(width: 300, height: 240)
        }
        .menuBarExtraStyle(.window)
    }
}
```

The two available styles are:

- `.menu`; renders a standard pull-down menu with `Button` rows. Simple, native, and appropriate for quick actions with no custom UI.
- `.window`; renders a floating panel below the menu bar icon, allowing any SwiftUI view inside it. Use `.frame(width:height:)` to pin a sensible default size.

#### Hiding the Dock icon

Add this key to `Info.plist` to suppress the Dock entry:

```xml
<key>LSUIElement</key>
<true/>
```

Without this, your menu bar app will still appear in the Dock and in the App Switcher, which breaks the "background utility" feel.

#### Combining a menu bar extra with a main window

You can declare both a `WindowGroup` and a `MenuBarExtra` in the same `App`. The menu bar extra can open the main window using `openWindow`:

```swift
@main
struct HybridApp: App {
    var body: some Scene {
        WindowGroup(id: "main") {
            ContentView()
        }

        MenuBarExtra("Quick Access", systemImage: "bolt.fill") {
            MenuBarQuickView()
        }
        .menuBarExtraStyle(.window)
    }
}

struct MenuBarQuickView: View {
    @Environment(\.openWindow) private var openWindow

    var body: some View {
        VStack(spacing: 12) {
            Text("Quick Summary")
                .font(.headline)
            Divider()
            Button("Open Main Window") {
                openWindow(id: "main")
            }
            .keyboardShortcut("o")
            Divider()
            Button("Quit") {
                NSApplication.shared.terminate(nil)
            }
            .keyboardShortcut("q")
        }
        .padding()
    }
}
```

### Document-based apps with `DocumentGroup`

Document apps automatically get Finder integration, menu-bar Save/Open/Revert commands, version history, autosave, and iCloud Drive support just by adopting the `DocumentGroup` scene.

#### Defining a `FileDocument`

```swift
import SwiftUI
import UniformTypeIdentifiers

// Register your custom file type
extension UTType {
    static let myNote = UTType(exportedAs: "com.yourcompany.mynote")
}

struct NoteDocument: FileDocument {
    var text: String

    static var readableContentTypes: [UTType] { [.myNote, .plainText] }

    init(text: String = "") {
        self.text = text
    }

    init(configuration: ReadConfiguration) throws {
        guard let data = configuration.file.regularFileContents,
              let string = String(data: data, encoding: .utf8)
        else {
            throw CocoaError(.fileReadCorruptFile)
        }
        self.text = string
    }

    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        let data = Data(text.utf8)
        return FileWrapper(regularFileWithContents: data)
    }
}
```

#### Wiring up the scene

```swift
@main
struct NoteApp: App {
    var body: some Scene {
        DocumentGroup(newDocument: NoteDocument()) { file in
            NoteEditorView(document: file.$document)
        }
    }
}
```

Each open document gets its own independent window with its own undo stack. The `$document` binding gives your view direct write access. macOS handles dirty-state tracking, the close-with-unsaved-changes sheet, and autosave automatically.

Key notes:

- Register your `UTType` in `Info.plist` under `CFBundleDocumentTypes` and `UTExportedTypeDeclarations`.
- `DocumentGroup` on macOS also presents a standard Open Recent menu and integrates with Spotlight indexing.
- Use `DocumentGroup(viewing:)` for read-only document viewers that cannot create or save files.

### Menu bar utility lifecycle notes

Menu bar-only apps (no `WindowGroup`, `LSUIElement = YES`) have several known focus quirks:

- **Popover focus:** SwiftUI popovers attached to a `MenuBarExtra` with `.menuBarExtraStyle(.window)` lose focus when the user clicks outside the popover. This dismisses it, which is expected. If you need a persistent panel (one that does not dismiss on outside click), use `.menuBarExtraStyle(.window)` and manage dismissal yourself via `NSApp.activate()`.
- **Keyboard shortcuts in `.window` style:** The window-style menu bar extra renders in a separate `NSPanel`, not the main window. Standard keyboard shortcuts (Cmd+Q, Cmd+W) may not behave as expected. Provide explicit quit behavior via a `Button("Quit") { NSApplication.shared.terminate(nil) }` in your menu bar view.
- **App activation:** Menu bar extras do not activate the application in the traditional sense. If your extra opens a secondary window, call `NSApp.activate(ignoringOtherApps: false)` to bring the app's windows forward before opening the new window.


---

## App lifecycle and `NSApplicationDelegateAdaptor`

SwiftUI's `@main App` hides the AppKit lifecycle entirely, which is a good default. However, several macOS-specific behaviors still require an `NSApplicationDelegate`. Use `@NSApplicationDelegateAdaptor` to bridge in a delegate without abandoning the SwiftUI lifecycle.

**HIG context:** Keep delegate usage minimal. SwiftUI handles the vast majority of lifecycle needs natively. Reach for `NSApplicationDelegateAdaptor` only for the specific events listed below that have no SwiftUI equivalent.

### Events that still require a delegate

| Lifecycle Event                              | SwiftUI Equivalent?        | Delegate Method                                                    |
| -------------------------------------------- | -------------------------- | ------------------------------------------------------------------ |
| URL scheme / universal link open             | `.onOpenURL` (prefer this) | `application(_:open:)`                                             |
| Prevent quit (unsaved data)                  | `.handlesExternalEvents`   | `applicationShouldTerminate(_:)`                                   |
| Dock tile badge + menu                       | None                       | `applicationDockMenu(_:)`                                          |
| Quit when last window closes                 | None                       | `applicationShouldTerminateAfterLastWindowClosed(_:)`              |
| Push notification registration               | None                       | `application(_:didRegisterForRemoteNotificationsWithDeviceToken:)` |
| App reopen (Dock icon click with no windows) | None                       | `applicationShouldHandleReopen(_:hasVisibleWindows:)`              |

### Wiring up the adaptor

```swift
@main
struct MyApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

class AppDelegate: NSObject, NSApplicationDelegate {

    // Quit the app when the last window closes (not default SwiftUI behavior)
    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return true
    }

    // Reopen the main window when the user clicks the Dock icon with no windows open
    func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows: Bool) -> Bool {
        if !hasVisibleWindows {
            for window in sender.windows {
                window.makeKeyAndOrderFront(nil)
            }
        }
        return false
    }

    // Custom Dock tile context menu
    func applicationDockMenu(_ sender: NSApplication) -> NSMenu? {
        let menu = NSMenu()
        menu.addItem(NSMenuItem(title: "New Document",
                                action: #selector(newDocument),
                                keyEquivalent: ""))
        return menu
    }

    @objc func newDocument() {
        // trigger a new document via NSApp or NotificationCenter
    }

    // Prevent quit when there are unsaved changes
    func applicationShouldTerminate(_ sender: NSApplication) -> NSApplication.TerminateReply {
        // Return .terminateCancel to block quit, show your own sheet
        return .terminateNow
    }
}
```

For URL scheme handling, prefer SwiftUI's `.onOpenURL` modifier on your `WindowGroup` content view; it integrates better with the SwiftUI lifecycle and does not require a delegate:

```swift
WindowGroup {
    ContentView()
        .onOpenURL { url in
            handleDeepLink(url)
        }
}
```

**Common gotchas:**

- Do **not** call `NSApp.activate(ignoringOtherApps: true)` in `applicationDidFinishLaunching` in modern apps; it is rude to the user and Gatekeeper behavior changed in recent macOS versions.
- `applicationShouldTerminateAfterLastWindowClosed` returning `true` is almost always the right behavior for single-window utility apps but wrong for document-based apps (which should stay alive after all documents are closed, matching TextEdit behavior).

## Distribution outside the App Store: Sparkle

Apps distributed directly (as a `.dmg` or `.zip` from your own server or Gumroad) have no system-provided update mechanism. Sparkle is the industry-standard open-source framework that fills this gap. It checks an appcast XML feed you host, downloads updates in the background, and presents a native update dialog.

**HIG context:** Users of direct-download Mac apps strongly expect automatic updates. Without Sparkle or an equivalent, users run outdated versions indefinitely. This is especially important for security patches.

### Adding Sparkle via Swift Package Manager

1. In Xcode, go to **File > Add Package Dependencies...**
2. Enter the package URL: `https://github.com/sparkle-project/Sparkle`
3. Add `Sparkle` to your app target.

### Wiring Sparkle into SwiftUI

```swift
import Sparkle

// Create one shared updater controller for the whole app lifecycle
final class UpdaterController: ObservableObject {
    private let updaterController: SPUStandardUpdaterController

    init() {
        updaterController = SPUStandardUpdaterController(
            startingUpdater: true,
            updaterDelegate: nil,
            userDriverDelegate: nil
        )
    }

    func checkForUpdates() {
        updaterController.checkForUpdates(nil)
    }
}

@main
struct MyApp: App {
    @StateObject private var updaterController = UpdaterController()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(updaterController)
        }
        .commands {
            CommandGroup(after: .appInfo) {
                Button("Check for Updates...") {
                    updaterController.checkForUpdates()
                }
            }
        }
    }
}
```

### Hosting an appcast

Sparkle expects an appcast XML feed at a URL you configure in `Info.plist`:

```xml
<key>SUFeedURL</key>
<string>https://yoursite.com/appcast.xml</string>
```

A minimal `appcast.xml` entry:

```xml
<?xml version="1.0" encoding="utf-8"?>
<rss version="2.0" xmlns:sparkle="http://www.andymatuschak.org/xml-namespaces/sparkle">
  <channel>
    <title>My App</title>
    <item>
      <title>Version 2.1.0</title>
      <pubDate>Mon, 07 Apr 2026 12:00:00 +0000</pubDate>
      <sparkle:version>210</sparkle:version>
      <sparkle:shortVersionString>2.1.0</sparkle:shortVersionString>
      <enclosure url="https://yoursite.com/MyApp-2.1.0.zip"
                 sparkle:edSignature="<ed25519 signature>"
                 length="12345678"
                 type="application/octet-stream"/>
    </item>
  </channel>
</rss>
```

Sign updates with the `generate_keys` and `sign_update` tools that Sparkle ships with (`./bin/generate_keys`, then `./bin/sign_update MyApp.zip`). Store the private key securely; losing it means you cannot sign future updates.

**Common gotchas:**

- Sandboxed apps require the `XPC Service` target that Sparkle provides in its package. Follow Sparkle's sandbox setup guide exactly; missing the XPC service causes updates to silently fail.
- Never ship a build with `SUFeedURL` pointing to a localhost or staging URL. Gate the feed URL with a build configuration.


## App Sandbox, entitlements, and hardened runtime

Mac App Store distribution requires sandboxing. Direct distribution outside the store does not require it, but Apple recommends it for all apps.

### Enabling the sandbox in Xcode

1. Select your target in Xcode.
2. Go to **Signing & Capabilities**.
3. Click **+ Capability** and add **App Sandbox**.
4. Xcode creates a `.entitlements` file in your project.

### Common entitlements

| Entitlement Key                                     | Purpose                                   |
| --------------------------------------------------- | ----------------------------------------- |
| `com.apple.security.app-sandbox`                    | Base sandbox (required for Mac App Store) |
| `com.apple.security.network.client`                 | Outbound network requests                 |
| `com.apple.security.network.server`                 | Accept incoming connections               |
| `com.apple.security.files.user-selected.read-write` | Read/write files chosen via Open panel    |
| `com.apple.security.files.downloads.read-write`     | Read/write files in Downloads folder      |
| `com.apple.security.device.camera`                  | Camera access                             |
| `com.apple.security.device.microphone`              | Microphone access                         |
| `com.apple.security.print`                          | Printing access                           |

### Security-scoped bookmarks

When a sandboxed app uses `NSOpenPanel` to let the user pick a file, you get access only for that session. To retain access across launches, create a security-scoped bookmark:

```swift
// Save a bookmark after the user picks a file
func saveBookmark(for url: URL) throws {
    let bookmarkData = try url.bookmarkData(
        options: .withSecurityScope,
        includingResourceValuesForKeys: nil,
        relativeTo: nil
    )
    UserDefaults.standard.set(bookmarkData, forKey: "savedBookmark")
}

// Restore access on next launch
func restoreBookmark() -> URL? {
    guard let data = UserDefaults.standard.data(forKey: "savedBookmark") else { return nil }
    var isStale = false
    let url = try? URL(
        resolvingBookmarkData: data,
        options: .withSecurityScope,
        relativeTo: nil,
        bookmarkDataIsStale: &isStale
    )
    url?.startAccessingSecurityScopedResource()
    return url
}
```

Always call `url.stopAccessingSecurityScopedResource()` when done.

### Hardened Runtime

For notarization (required for any distribution outside the Mac App Store), you also need the Hardened Runtime capability enabled. Certain operations, such as loading unsigned code or using the JIT compiler, require temporary exceptions in your entitlements. Add **Hardened Runtime** via **+ Capability** in your target settings.

## App icon design for macOS 26+

macOS 26 (Tahoe) introduced an updated squircle icon treatment applied system-wide. Understanding how this affects your icon design is important for App Store submissions.

### Sizing and format

Provide a single 1024x1024pt asset in your Xcode Asset Catalog. Xcode and Icon Composer automatically generate the `.icns` file containing all required sizes (16x16 through 1024x1024, in 1x and 2x). You do not need to manually provide multiple sizes.

| Requirement | Value                                       |
| ----------- | ------------------------------------------- |
| Canvas size | 1024 x 1024 px                              |
| Color space | sRGB or Display P3                          |
| Format      | PNG (Xcode converts to `.icns`)             |
| Shape       | System-applied squircle; draw full-bleed   |
| Margins     | Xcode / Icon Composer applies automatically |

### macOS 26 Tahoe changes

On macOS 26, the OS applies a squircle mask and adds automatic drop shadows and vibrancy to all app icons. If your icon was designed for earlier macOS:

- Icons designed to the Apple size guidelines convert cleanly; the system detects proper margins and applies the Tahoe treatment without a gray border.
- Icons that were poorly sized or had hardcoded padding may show an unwanted gray border around them.
- The best approach for new apps is to design a full-bleed icon and let Xcode or Icon Composer handle the margins.

### Design guidelines

- Avoid text in the icon; it is illegible at small sizes.
- Use a simple, recognizable silhouette rather than a detailed illustration.
- Provide a flat-style icon with depth conveyed through gradients or layering, not drop shadows (the OS applies its own shadow).
- Test the icon at 16pt (Dock overflow and menu bar contexts) and 512pt.


## iOS developer cheat sheet: macOS differences

If you are coming from iOS, here are the most important paradigm shifts:

| iOS Expectation                              | macOS Reality                                                    |
| -------------------------------------------- | ---------------------------------------------------------------- |
| `NavigationStack` + `TabView` for navigation | `NavigationSplitView` with sidebar is the primary pattern        |
| One window at a time                         | Multiple windows are expected and should be supported            |
| No pointer events                            | Add `.onHover`, tooltips, and right-click menus                  |
| Touch gestures (swipe to delete)             | Keyboard shortcuts, context menus, toolbar buttons               |
| Full screen by default                       | Resizable windows at any size, never assume full screen          |
| `@StateObject` / `@ObservedObject`           | Use `@Observable` + `@State` on macOS 14+                        |
| `TabView` for top-level nav                  | Reserve `TabView` for the Settings pane only                     |
| `sheet`, `fullScreenCover`                   | Use separate `Window` scenes for utility panels                  |
| `UIFont` / `UIColor`                         | Use SwiftUI semantic styles; they adapt automatically           |
| Form inputs fill width                       | macOS forms use `Form` with labeled fields in a fixed-width pane |

---

## Accessibility and localization

### Accessibility considerations

### Accessibility considerations

Apple’s HIG stresses accessibility as a first-class concern: all users should be able to perceive, understand, and interact with your app. SwiftUI provides built-in accessibility modifiers and often infers semantics from standard controls.[^7][^2]

Best practices:

- Provide descriptive labels, hints, and traits using `.accessibilityLabel`, `.accessibilityHint`, and `.accessibilityRole` where the default is not sufficient.[^2]
- Maintain adequate color contrast and avoid using color alone to convey important information.[^2]
- Test Dynamic Type, high contrast, and reduced motion settings in Xcode previews and on device.[^8]

### Localization and text expansion

Mac apps frequently serve global audiences, so the layout must anticipate text expansion and differing formats. SwiftUI layouts based on flexible stacks and auto-sizing text respond better to localization than rigid, fixed-size designs.[^2]

Guidelines:

- Avoid hardcoding widths and heights for content-bearing elements, preferring flexible layouts that can grow.[^2]
- Use `Text` interpolation and localized strings tables (`Localizable.strings`) instead of inline, hardcoded strings.[^2]
- Leave sufficient padding around text and controls to handle longer translated strings without clipping.[^2]

---

## Production decisions

### Stance on third-party libraries

Strictly prefer Apple first-party APIs. The only recommended exception in this guide is **Sparkle**, because there is no native alternative for non-App Store auto-update. Packages like `WindowIntrospection` or `Introspect` depend on private AppKit internals and routinely break with minor OS updates. If you find yourself reaching for such a package, it usually means the feature should be implemented via `NSViewRepresentable` or `NSApplicationDelegateAdaptor` instead.

### Cross-platform code sharing: `#if os(macOS)` vs. separate views

Use `#if os(macOS)` for **small, targeted divergences**: a modifier that only exists on macOS, a platform-specific default value, or a conditional import. Use it like a scalpel.

```swift
// Good; targeted divergence
.listStyle(
    {
        #if os(macOS)
        return .sidebar
        #else
        return .insetGrouped
        #endif
    }()
)
```

When the divergence is large (for example the entire navigation hierarchy: `NavigationSplitView` on macOS versus `NavigationStack` plus `TabView` on iOS), build separate view hierarchies:

```swift
@main
struct MyApp: App {
    var body: some Scene {
        WindowGroup {
            #if os(macOS)
            MacRootView()
            #else
            iOSRootView()
            #endif
        }
    }
}
```

This keeps each platform's code readable and unambiguous. A view file that is 40% compile-time conditionals is a maintenance burden.

---

## Master checklist

Use this for new projects and pre-release review. Check every item that applies to your app shape (menu bar-only, document-based, App Store vs direct download).

### Architecture and state

- [ ] `@Observable` with `@State` / `@Environment` is the default on macOS 14+; legacy `ObservableObject` only where required
- [ ] App-level state owned in `@main` `App` and injected with `.environment()`; heavy setup not repeated in child view `@State` initializers
- [ ] `openWindow` / `dismissWindow` used for auxiliary windows; `Window` for singleton panels, `WindowGroup` for multi-instance content
- [ ] `@SceneStorage` for per-window UI persistence; `@AppStorage` for global preferences

### Scenes and navigation

- [ ] `WindowGroup`, `Settings`, and any `MenuBarExtra` / `DocumentGroup` scenes declared as needed
- [ ] Primary navigation uses `NavigationSplitView` with bound `List` selection where appropriate
- [ ] `ContentUnavailableView` (or equivalent) in the detail column when nothing is selected
- [ ] `Settings` uses `TabView` with `.fixedSize()` and sensible width; panes use `Form` and `@AppStorage`
- [ ] `DocumentGroup` + `FileDocument` for document apps; `UTType` registered in `Info.plist`

### Data and performance

- [ ] `Table` for large, multi-column data; `sortOrder` bound with `.onChange` to apply sorting
- [ ] `TableColumnCustomization` in `@AppStorage` when you need persisted columns (macOS 14+); `.customizationID` on each column
- [ ] Per-row table context menus implemented in cell content with `.contentShape(Rectangle())`
- [ ] Container choice matches scale: `Table` for very large grids, `List` for navigation and moderate lists; avoid `LazyVStack` inside `List`
- [ ] Row views kept cheap; stable `.id` for list identity; consider `NSTableView` via representable only when required

### Navigation chrome and inspector

- [ ] Toolbar exposes key actions; `SidebarCommands()` and `ToolbarCommands` wired where appropriate
- [ ] Window chrome matches product (unified toolbar, hidden separator, or full-bleed content) without breaking traffic lights
- [ ] `.inspector` on the detail content (macOS 14+) with column width limits; placeholder when there is no selection

### Interaction and keyboard

- [ ] Hover (`.onHover` / `.onContinuousHover`) on rows and interactive surfaces where helpful
- [ ] `.help()` on icon-only and ambiguous controls
- [ ] Drag and drop with `Transferable` where content moves between views or Finder
- [ ] `EditCommands()` and copy/paste modifiers where editing matters
- [ ] `.keyboardShortcut` on primary actions; standard Edit menu behavior
- [ ] `@FocusState` routes fields; `.onKeyPress` on focusable containers when needed (macOS 14+); primary action uses `.keyboardShortcut(.defaultAction)`
- [ ] Full keyboard navigation without requiring the pointer for core flows

### Visual design

- [ ] Semantic colors and materials (not raw alpha stacks) for sidebars and overlays
- [ ] SF Symbols with weights aligned to text; system text styles instead of fixed font sizes
- [ ] Continuous corner radii; consistent spacing rhythm (for example 8 / 12 / 16 / 24)
- [ ] Animations subtle, short, and respectful of Reduce Motion

### Forms

- [ ] `Form` with `.formStyle(.grouped)` on macOS; `LabeledContent` for aligned labels and read-only rows
- [ ] Text fields constrained with `frame(maxWidth:)` so settings panes do not over-stretch

### AppKit and lifecycle

- [ ] `NSViewRepresentable` / `NSViewControllerRepresentable` only for gaps SwiftUI does not cover
- [ ] `@NSApplicationDelegateAdaptor` limited to events with no SwiftUI equivalent; prefer `.onOpenURL` for URLs
- [ ] Quit-on-last-window and reopen behavior match app type (utility vs document)
- [ ] No `NSApp.activate(ignoringOtherApps: true)` on launch

### Accessibility and localization

- [ ] Accessibility labels on non-obvious controls; contrast and Dynamic Type checked
- [ ] Localized strings and layouts that tolerate text expansion

### App icon

- [ ] Single 1024×1024 asset in the catalog; full-bleed artwork; verified at 16pt and 512pt

### Distribution

- [ ] Sandbox and entitlements match shipping channel (App Store requires sandbox)
- [ ] Security-scoped bookmarks for persistent user-picked files in sandbox
- [ ] Hardened Runtime for notarized direct distribution
- [ ] Sparkle (if direct download): SPM integration, appcast URL, signing, sandbox XPC if sandboxed; no staging URLs in release

---

## References

[^1]: [Designing for macOS | Apple Developer Documentation](https://developer.apple.com/design/human-interface-guidelines/designing-for-macos)
[^2]: [Human Interface Guidelines | Apple Developer Documentation](https://developer.apple.com/design/human-interface-guidelines)
[^3]: [Apple HIG (Human Interface Guidelines) Design System](https://designsystems.surf/design-systems/apple)
[^4]: [WWDC21: SwiftUI on the Mac: Build the fundamentals | Apple](https://www.youtube.com/watch?v=ChY_lxk0Pf8)
[^5]: [How to Build macOS Applications with SwiftUI - OneUptime](https://oneuptime.com/blog/post/2026-02-02-swiftui-macos-applications/view)
[^6]: [Design for macOS Big Sur - Design+Code](https://designcode.io/ios-design-handbook-design-for-macos-big-sur/)
[^7]: [Apple Human Interface Guidelines (HIG) - Github-Gist](https://gist.github.com/eonist/f4ba31012815731284d867232f6c70e4)
[^8]: [Design with SwiftUI - WWDC23 - Apple Developer](https://developer.apple.com/videos/play/wwdc2023/10115/)

