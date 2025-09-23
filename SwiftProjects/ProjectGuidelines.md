## Things to consier when building
- Build with localization in mind. So instead of hard coding strings into the code, use Swift localization features.


### To help with agentic coding
- It is easier for a coding agent to read and edit smaller files, so make sure files are as small and singularly-focused as possible. A swift file should not be responsible for a bunch of different things.


### Clear, scalable code
- Write code with scalability in mind. Keep tech debt as small as possbile as we go. Use best coding standards and practices.
- Write DocC comments in helpful places. Any developer who is new to the code should never be confused what a symbol means. Comments and documentation should take advantage of built in Xcode features like Quick Help etc.


### ✅ **SwiftUI Readability Rule: Extract Nested Views into Computed Properties or Subviews**

**Rule:**
Avoid deeply nested SwiftUI views within the `body` property. If a view contains more than 2–3 levels of nesting, extract logically grouped elements into **private computed properties** or **dedicated subviews**.

**Why:**

* Enhances readability and maintainability.
* Clarifies the structure of the UI at a glance.
* Simplifies debugging and styling.
* Encourages reuse and separation of concerns.

**How:**

1. Identify nested groups of views (e.g. headers, sections, cards).
2. Extract each into a `private var` or a separate `View` struct.
3. Name the property or subview descriptively (`profileHeader`, `aboutSection`, etc.).
4. Use these properties in the main `body` to keep it clean and linear.

**Example:**

Instead of:

```swift
var body: some View {
    VStack {
        HStack {
            Image(...)
            VStack { Text(...) }
        }
        ...
    }
}
```

Do:

```swift
var body: some View {
    VStack {
        profileHeader
        aboutSection
    }
}

private var profileHeader: some View { ... }
private var aboutSection: some View { ... }
```

**Exceptions:**
This rule can be relaxed for very simple views (e.g. 1-2 short lines) where nesting does not harm readability.


### Every view should successfully run with a #Preview that is able to show the view properly with dummy data if needed.
