### Guide to Using Photo Pickers in iOS Development

This guide covers the primary APIs for implementing photo pickers in iOS apps, focusing on SwiftUI and UIKit. Photo pickers allow users to select images, videos, or other media from their photo library or take new photos/videos. We'll emphasize the most up-to-date frameworks as of iOS 18 (released in 2024), including best practices for privacy, performance, and user experience. The modern APIs prioritize user privacy by avoiding full library access requirements, unlike older methods.

Key APIs:
- **SwiftUI**: Use `PhotosPicker` (introduced in iOS 16, with enhancements in iOS 17 for inline pickers).
- **UIKit**: Use `PHPickerViewController` (introduced in iOS 14, recommended for most cases).
- **Legacy UIKit**: `UIImagePickerController` (available since early iOS versions, but less privacy-friendly).

For custom camera implementations beyond pickers, consider AVFoundation, but this guide focuses on library-based selection.

#### Comparison of Photo Picker APIs

| API                  | Framework | Minimum iOS | Privacy Features | Key Advantages | Key Limitations | When to Use |
|----------------------|-----------|-------------|------------------|----------------|-----------------|-------------|
| PhotosPicker        | SwiftUI  | 16         | No full library permission needed; user selects specific assets | Native SwiftUI integration, supports multiple selections, inline mode (iOS 17+) | Limited customization of UI | Modern SwiftUI apps needing simple, privacy-focused selection |
| PHPickerViewController | UIKit/PhotosUI | 14     | Runs in separate process; no library permission prompt | Built-in search, multi-selection, deferred loading | Requires delegate for handling selections | UIKit apps or SwiftUI apps via UIViewControllerRepresentable; best for privacy |
| UIImagePickerController | UIKit   | 2          | Requires full library access permission | Supports camera capture directly; customizable overlays | Privacy concerns (full access); potential deprecation risks in future | Legacy apps or when camera integration is primary and full access is acceptable |

#### Using Photo Pickers in SwiftUI

SwiftUI's `PhotosPicker` is the preferred API for iOS 16+. It presents a system-provided picker view for selecting photos, videos, or Live Photos without requiring broad photo library permissions. In iOS 17, it gained support for inline pickers (embedded directly in your view hierarchy). No major changes were introduced in iOS 18 beyond bug fixes and performance improvements.

**Key Features**:
- Supports single or multiple selections.
- Filters for media types (e.g., images, videos).
- Binding to selected items via `@State` or `@Binding`.
- Asynchronous loading of selected assets.
- Matching identifiers for pre-selected items.

**Configuration Options**:
- `PhotosPickerStyle`: `.presentation` (default modal) or `.inline` (embedded, iOS 17+).
- `selectionBehavior`: `.default` or `.ordered` (respects user selection order).
- `preferredItemEncoding`: Controls asset representation (e.g., `.compatible` for broad compatibility).
- `photoLibrary`: Defaults to `.shared()`, but customizable.

**Usage Example**:
Import `PhotosUI` and use the view like this:

```swift
import SwiftUI
import PhotosUI

struct PhotoPickerView: View {
    @State private var selectedItems: [PhotosPickerItem] = []
    @State private var selectedImages: [Image] = []

    var body: some View {
        VStack {
            PhotosPicker(
                selection: $selectedItems,
                maxSelectionCount: 5,
                matching: .images,  // Filter for images only
                photoLibrary: .shared()
            ) {
                Label("Select Photos", systemImage: "photo")
            }
            .photosPickerStyle(.presentation)  // Or .inline for iOS 17+

            // Display selected images
            ForEach(selectedImages, id: \.self) { image in
                image
                    .resizable()
                    .scaledToFit()
            }
        }
        .onChange(of: selectedItems) { newItems in
            Task {
                selectedImages.removeAll()
                for item in newItems {
                    if let data = try? await item.loadTransferable(type: Data.self),
                       let uiImage = UIImage(data: data) {
                        selectedImages.append(Image(uiImage: uiImage))
                    }
                }
            }
        }
    }
}
```

- **Handling Selections**: Use `loadTransferable` to asynchronously load data (e.g., `Data`, `URL`, or custom types). This supports deferred loading for large assets.
- **iOS Version Specifics**: Available in iOS 16+. Use inline style only on iOS 17+. For earlier iOS, wrap `PHPickerViewController` in `UIViewControllerRepresentable`.

**Best Practices in SwiftUI**:
- Always load assets asynchronously to avoid blocking the UI.
- Handle errors in loading (e.g., user cancels or asset unavailable).
- Use `maxSelectionCount: 0` for unlimited selections, but limit to reasonable numbers for performance.

#### Using Photo Pickers in UIKit

For UIKit, `PHPickerViewController` is the modern, privacy-focused choice. It runs in a separate process, providing built-in search, filtering, and multi-selection without needing "Photos Library" permission in Info.plist. UIImagePickerController is legacy and should be avoided for new apps due to its requirement for full library access.

**PHPickerViewController Key Features**:
- No permission prompts; users implicitly grant access to selected assets.
- Supports images, videos, Live Photos, and more.
- Deferred loading and recovery for large assets.
- Built-in UI similar to the Photos app.

**Configuration Options** (via `PHPickerConfiguration`):
- `selectionLimit`: Max items (0 for unlimited).
- `filter`: `.images`, `.videos`, `.livePhotos`, or combinations (e.g., `.any(of: [.images, .videos])`).
- `preferredAssetRepresentationMode`: `.compatible` (default) or `.current` for original format.
- `selection`: `.default` or `.ordered`.
- `disabledCapabilities`: Disable features like search (iOS 15+).
- `preselectedAssetIdentifiers`: Array of strings for pre-selecting items.

**Delegate Methods**:
Implement `PHPickerViewControllerDelegate`:
- `picker(_:didFinishPicking:)`: Called when user finishes. Receives `[PHPickerResult]`; each has an `itemProvider` (NSItemProvider) for loading data.
- No `didCancel` method; handle dismissal in your presentation logic.

**Usage Example**:
Import `PhotosUI` and present the picker:

```swift
import UIKit
import PhotosUI

class PhotoPickerViewController: UIViewController, PHPickerViewControllerDelegate {
    override func viewDidLoad() {
        super.viewDidLoad()
        let button = UIButton(type: .system, primaryAction: UIAction(title: "Pick Photo") { [weak self] _ in
            self?.presentPicker()
        })
        view.addSubview(button)
        // Add constraints...
    }

    private func presentPicker() {
        var config = PHPickerConfiguration(photoLibrary: .shared())
        config.filter = .images
        config.selectionLimit = 3
        config.preferredAssetRepresentationMode = .compatible

        let picker = PHPickerViewController(configuration: config)
        picker.delegate = self
        present(picker, animated: true)
    }

    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true)
        for result in results {
            result.itemProvider.loadObject(ofClass: UIImage.self) { [weak self] object, error in
                if let image = object as? UIImage {
                    // Handle image (e.g., display in UIImageView)
                    DispatchQueue.main.async {
                        // Update UI
                    }
                }
            }
        }
    }
}
```

- **Loading Data**: Use `itemProvider.loadObject`, `loadDataRepresentation`, or `loadFileRepresentation` for async loading. Supports progress and cancellation.
- **iOS Version Specifics**: iOS 14+. In iOS 15+, added `disabledCapabilities`. In iOS 17+, improved support for inline embedding via SwiftUI bridges. No significant iOS 18 updates beyond stability.

**Legacy: UIImagePickerController**:
Use only if you need direct camera access with custom overlays or for iOS <14 compatibility. It requires "NSPhotoLibraryUsageDescription" and "NSCameraUsageDescription" in Info.plist, prompting for full access.

**Key Differences from PHPicker**:
- Requires permissions; can access entire library.
- Supports camera source (`sourceType: .camera`).
- Delegate: `UIImagePickerControllerDelegate` with `imagePickerController(_:didFinishPickingMediaWithInfo:)` and `imagePickerControllerDidCancel(_:)`.

**Usage Example** (Simplified):
```swift
let picker = UIImagePickerController()
picker.sourceType = .photoLibrary
picker.delegate = self  // Conform to UIImagePickerControllerDelegate & UINavigationControllerDelegate
present(picker, animated: true)
```

In `didFinishPickingMediaWithInfo`, access `info[.originalImage]` or `info[.mediaURL]`.

Avoid in new apps; migrate to PHPicker for privacy.

#### General Best Practices for Photo Pickers in iOS Development

1. **Prioritize Privacy**: Always use `PhotosPicker` or `PHPickerViewController` to avoid full library access. These don't require Info.plist keys and limit app access to user-selected assets only. Handle limited access mode (iOS 14+) by checking `PHPhotoLibrary.authorizationStatus()` and presenting `presentLimitedLibraryPicker` if needed.

2. **Handle Permissions Gracefully**: For legacy pickers, request `PHPhotoLibrary.requestAuthorization` before presenting. Explain usage in prompts. For modern pickers, no explicit request is needed.

3. **Asynchronous Loading**: Load assets in background tasks to prevent UI freezes. Use `Task` in SwiftUI or GCD in UIKit. Support cancellation for large files.

4. **Media Type Handling**: Filter appropriately (e.g., `.images` only). Validate loaded data (e.g., check for errors, format compatibility). Support Live Photos and videos with `loadFileRepresentation`.

5. **User Experience**: Provide feedback during loading (progress indicators). Respect selection order with `.ordered`. Limit selections to avoid overwhelming users (e.g., max 10-20).

6. **Error Handling and Edge Cases**: Handle cancellations, unavailable assets, or low memory. Test on devices with limited storage or iCloud-synced libraries.

7. **Performance Optimizations**: Use deferred loading; avoid loading full-resolution images unless necessary (request thumbnails first). Clean up references to avoid memory leaks.

8. **Accessibility**: Ensure buttons and previews are accessible (e.g., alt text for images). Test with VoiceOver.

9. **Testing**: Simulate limited access in Settings > Privacy > Photos. Test on physical devices for camera integration.

10. **Migration Tips**: If upgrading from UIImagePicker, replace with PHPicker and remove unnecessary permissions.

For more examples, refer to Apple's sample code or tutorials. Always check Apple's documentation for the latest iOS 18 nuances.
