# SwiftUI Sheet Presentation with Optional Data - Common Issue & Fix

## Problem Description

When presenting a SwiftUI sheet that requires associated data (like an object, enum, or identifier), developers often encounter an issue where the sheet appears but the data is `nil` on the first presentation attempt. The sheet may show an error message or empty content, but works correctly on subsequent attempts.

### Common Symptoms

- Sheet presents but shows "nil" error messages or empty content on first tap
- Sheet works correctly after dismissing and tapping a different item
- Using `.sheet(isPresented:)` with an optional state variable and checking `if let` inside the sheet closure
- Race condition where the sheet evaluates before the optional is set

### Example of Problematic Code Pattern

```swift
@State private var selectedItem: ItemType?
@State private var showingSheet = false

var body: some View {
    // ...
    .sheet(isPresented: $showingSheet) {
        if let item = selectedItem {
            DetailView(item: item)
        } else {
            Text("Item is nil but trying to show sheet")
        }
    }
}

// In tap handler:
Button(action: {
    selectedItem = someItem
    showingSheet = true  // Race condition here!
})
```

## Root Cause

The issue occurs because `.sheet(isPresented:)` evaluates its content closure when the binding becomes `true`, but there's a timing/race condition:

1. `selectedItem` is set to a value
2. `showingSheet` is set to `true` (often immediately after or in an async context)
3. SwiftUI evaluates the sheet's content closure
4. Due to SwiftUI's view update cycle, `selectedItem` may still be `nil` when the closure is evaluated
5. The sheet presents with `nil` data

This is especially common when:
- State updates happen in async contexts (Task, DispatchQueue, etc.)
- Multiple state variables are updated in sequence
- There are delays or animations between setting the data and showing the sheet

## Solution: Use `.sheet(item:)` Instead

SwiftUI provides `.sheet(item:)` specifically for presenting sheets with associated data. This modifier:
- Only presents when the item is non-nil
- Automatically dismisses when the item becomes nil
- Guarantees the item is non-nil when the content closure is evaluated
- Eliminates the need for a separate boolean binding

### Step 1: Make Your Data Type Conform to Identifiable

If your data type doesn't already conform to `Identifiable`, add it:

```swift
// For enums with raw values:
enum ItemType: String, CaseIterable, Hashable, Identifiable {
    var id: String { rawValue }
    case item1
    case item2
}

// For structs:
struct Item: Identifiable {
    let id: UUID
    // ... other properties
}

// For classes:
class Item: Identifiable {
    let id: UUID
    // ... other properties
}
```

### Step 2: Replace `.sheet(isPresented:)` with `.sheet(item:)`

**Before:**
```swift
@State private var selectedItem: ItemType?
@State private var showingSheet = false

.sheet(isPresented: $showingSheet) {
    if let item = selectedItem {
        DetailView(item: item)
    } else {
        Text("Error: Item is nil")
    }
}
```

**After:**
```swift
@State private var selectedItem: ItemType?

.sheet(item: $selectedItem) { item in
    DetailView(item: item)
}
```

### Step 3: Update Your Tap Handlers

**Before:**
```swift
Button(action: {
    selectedItem = someItem
    showingSheet = true
})
```

**After:**
```swift
Button(action: {
    selectedItem = someItem
    // Sheet automatically presents when selectedItem becomes non-nil
})
```

## Complete Example

### Before (Problematic):
```swift
struct ContentView: View {
    @State private var selectedUser: User?
    @State private var showingUserSheet = false
    
    var body: some View {
        List(users) { user in
            Button(user.name) {
                selectedUser = user
                Task { @MainActor in
                    try? await Task.sleep(for: .seconds(0.5))
                    showingUserSheet = true
                }
            }
        }
        .sheet(isPresented: $showingUserSheet) {
            if let user = selectedUser {
                UserDetailView(user: user)
            } else {
                Text("User is nil")
            }
        }
    }
}
```

### After (Fixed):
```swift
struct ContentView: View {
    @State private var selectedUser: User?  // User must conform to Identifiable
    
    var body: some View {
        List(users) { user in
            Button(user.name) {
                selectedUser = user
                // No delay needed, no separate boolean needed
            }
        }
        .sheet(item: $selectedUser) { user in
            UserDetailView(user: user)
        }
    }
}
```

## How to Identify This Issue

Look for these patterns in your codebase:

1. **Search for**: `.sheet(isPresented:`
2. **Check if**: The sheet closure contains `if let` checks for optional data
3. **Check if**: There are separate boolean state variables for sheet presentation
4. **Check if**: Tap handlers set both a data variable and a boolean in sequence
5. **Check if**: There are delays or async operations between setting data and showing sheet

## When to Use Each Pattern

### Use `.sheet(item:)` when:
- ✅ You have data that must be non-nil when the sheet presents
- ✅ The sheet content depends on the selected item
- ✅ You want automatic dismissal when the item becomes nil
- ✅ You want to eliminate race conditions

### Use `.sheet(isPresented:)` when:
- ✅ The sheet doesn't require associated data
- ✅ The sheet is a simple form or action sheet
- ✅ You need manual control over presentation timing
- ✅ The sheet content doesn't depend on selected state

## Additional Notes

- `.sheet(item:)` requires the item type to conform to `Identifiable`
- The item's `id` property is used to track when the item changes
- Setting the item to `nil` automatically dismisses the sheet
- This pattern also applies to `.fullScreenCover(item:)` and `.popover(item:)`

## Related SwiftUI Modifiers

This same pattern applies to other presentation modifiers:
- `.fullScreenCover(item:)` - Full screen presentation
- `.popover(item:)` - Popover presentation
- `.confirmationDialog(item:)` - Action sheet style dialogs

All follow the same principle: use the `item:` variant when you have associated data.

