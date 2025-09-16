SwiftUI Cursor Rules

## SwiftUI Best Practices

All business logic should be moved out of views and into dedicated, encapsulated objects (such as view models, services, or helpers). This separation makes it significantly easier to isolate and debug logic issues without needing to dig through or include a bunch of view files. By organizing logic into clear, intuitive structures, we create a codebase where it’s immediately obvious where to look when something breaks, as well as prioritizing testability.


### View Structure
1. Use computed properties with `@ViewBuilder` for view components
2. Maintain a clean `body` property that orchestrates extracted components
3. Name components clearly based on their content or function
4. Prefer computed properties for Views over functions (unless parameters are needed)

```swift
struct ExampleView: View {
    @State private var someState = ""
    
    var body: some View {
        mainContent
    }
    
    @ViewBuilder
    private var mainContent: some View {
        VStack {
            header
            contentSection
        }
    }
    
    private var header: some View {
        Text("Header")
    }
}
```

### Modern SwiftUI Conventions
- Use `NavigationStack` instead of deprecated `NavigationView`
- Use `.foregroundStyle()` instead of `.foregroundColor()`
- Use `.clipShape(RoundedRectangle(cornerRadius:))` instead of `.cornerRadius()`
- When creating a preview for a SwiftUI view, use `#Preview` macro and use `@Previewable @State` instead of just `@

### Dismiss Action Usage
```swift
// Correct
Button("Cancel") { dismiss() }

// Incorrect - Will Not Work
Button("Cancel", action: dismiss)
```

### Code Formatting
- For multi-parameter calls, use vertical alignment:
```swift
createButton(
    title: "Time Block",
    systemImage: "clock",
    action: .createFirstTimeBlockFirst
)
```

### Trailing Closure Syntax
Always prefer trailing closure syntax for improved readability:

```swift
// Preferred
Button {
    handleAction()
} label: {
    Text("Press me")
}

// Instead of
Button(action: { handleAction() }) {
    Text("Press me")
}
```

### Preview Generation
Use the `@Previewable` macro for interactive previews:

```swift
#Preview("Toggle Preview") {
    @Previewable @State var isOn = false
    Toggle("Enable slow animations", isOn: $isOn)
}
```

### Concurrency
- Avoid `DispatchQueue.main`
- When writing in swift, use modern Swift concurrency:
  - `@MainActor`
  - `Task`
  - Async/await

### Command Definitions

1. "Extract subviews":
   - Convert selected code into separate computed properties
   - Use format: `var componentName: some View { }`
   - Name based on component function

2. "Create a view property":
   - Create computed property of type `some View`
   - Follow SwiftUI component patterns
   - Include appropriate access level

3. "Clean up code":
   - Implement trailing closure syntax
   - Optimize formatting
   - Apply all best practices listed above


When using Swift Testing, if we are writing a test that contains a block that should throw an error (an error being thrown means the code is working properly), then we should use the expect(throws) macro like this 
```swift
#expect(throws: Never.self) {
  FoodTruck.shared.engine.batteryLevel = 100
  try FoodTruck.shared.engine.start()
}
```

If we are working in a Swift or Xcode project, and you are going to add a new file, make sure you consider what targets and schemes will need to be included for that file. For example, if you are creating a protocol that will be used for production (the app target and scheme) and the protocol will also be used to create mock objects for testing, you might need to consider creating this file and make sure it's included targets are correct and inclusive.

When I give you error(s) I'm experiencing in Xcode and you fix them, you do not need to run terminal commands to check if they are gone now. Simply implement the fix and I will check if its good to go.


## Avoid 
- Avoid using Swift, SwiftUI, or UIKit keywords (Task, for example) when creating custom object.
- Avoid large files. Do not put multiple objects definitions in the same file. Each object should have its own file
