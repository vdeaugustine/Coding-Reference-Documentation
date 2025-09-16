This file contains examples of SwiftUI components that I have built.
I enjoy the UI of these components, look and feel wise.
An AI coding agent will use this file in conjunction with a view I want the AI to make, and will use this as guidance for UI aesthetic.

==== FIRST EXAMPLE ====
### Configuring settings for compressing images. I like this view because rather than providing the user with a simple list-style form, it provides a grid that is more digestable, easy on the eyes, and clean. It's an elegant design without being over-the-top flashy. Its sheets follow the same ideas. Built-in SwiftUI vanilla features like Form or List are too simple and this example below feels much more premium 

```swift
 import SwiftUI

// MARK: - Supporting Enums for Clarity

enum ImageFormat: String, CaseIterable, Identifiable {
    case jpeg = "JPEG"
    case heic = "HEIC"
    case png = "PNG"
    var id: Self { self }
}

enum Resolution: String, CaseIterable, Identifiable {
    case full = "Full Resolution"
    case large = "Large (2048px)"
    case medium = "Medium (1080px)"
    case small = "Small (720px)"
    var id: Self { self }
}

// MARK: - Main View

struct CompressionConfigView: View {
    // MARK: - State Properties

    @State private var quality: Double = 0.8
    @State private var selectedFormat: ImageFormat = .jpeg
    @State private var selectedResolution: Resolution = .full
    @State private var keepMetadata: Bool = false
    @State private var compressionPasses: Int = 3

    // State to control sheet presentation
    @State private var showingQualitySheet: Bool = false
    @State private var showingFormatSheet: Bool = false
    @State private var showingResolutionSheet: Bool = false
    @State private var showingPassesSheet: Bool = false

    let imageCount: Int = 5 // Example count

    // Define the grid layout for our cards
    let columns: [GridItem] = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16),
    ]

    // MARK: - Body

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            HeaderInfoView(imageCount: imageCount)

            ScrollView {
                LazyVGrid(columns: columns, spacing: 16) {
                    // Quality Card
                    ConfigCard(
                        icon: "slider.horizontal.3",
                        title: "Quality",
                        value: "\(String(format: "%.0f", quality * 100))%",
                        accentColor: .green
                    )
                    .onTapGesture { showingQualitySheet = true }

                    // Format Card
                    ConfigCard(
                        icon: "photo.fill.on.rectangle.fill",
                        title: "Format",
                        value: selectedFormat.rawValue,
                        accentColor: .blue
                    )
                    .onTapGesture { showingFormatSheet = true }

                    // Resolution Card
                    ConfigCard(
                        icon: "arrow.up.left.and.arrow.down.right",
                        title: "Resolution",
                        value: selectedResolution.rawValue,
                        accentColor: .orange
                    )
                    .onTapGesture { showingResolutionSheet = true }

                    // Metadata Toggle Card
                    ConfigCard(
                        icon: keepMetadata ? "checkmark.square.fill" : "square",
                        title: "Metadata",
                        value: keepMetadata ? "Included" : "Removed",
                        accentColor: keepMetadata ? .purple : .gray.opacity(0.6)
                    )
                    .onTapGesture { withAnimation { keepMetadata.toggle() } }

                    // Compression Passes Card
                    ConfigCard(
                        icon: "arrow.triangle.2.circlepath",
                        title: "Passes",
                        value: "\(compressionPasses)",
                        accentColor: .teal
                    )
                    .onTapGesture { showingPassesSheet = true }
                }
                .padding(.horizontal)
            }

            Spacer() // Pushes content up

            ActionButtonView()
        }
        .background(Color(.systemGroupedBackground)
            .ignoresSafeArea())
        .navigationTitle("Configure Compression")
        .navigationBarTitleDisplayMode(.inline)

        // MARK: - Sheets for Configuration

        .sheet(isPresented: $showingQualitySheet) {
            QualitySettingsSheet(quality: $quality)
        }
        .sheet(isPresented: $showingFormatSheet) {
            FormatSettingsSheet(selectedFormat: $selectedFormat)
        }
        .sheet(isPresented: $showingResolutionSheet) {
            ResolutionSettingsSheet(selectedResolution: $selectedResolution)
        }
        .sheet(isPresented: $showingPassesSheet) {
            CompressionPassesSheet(compressionPasses: $compressionPasses)
        }
    }
}

// MARK: - Subviews for Config Cards

struct ConfigCard: View {
    let icon: String
    let title: String
    let value: String
    let accentColor: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(accentColor)
            Text(title)
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(.secondary)
            Spacer()
            Text(value)
                .font(.title3)
                .fontWeight(.bold)
                .foregroundColor(.primary)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
        }
        .padding()
        .frame(height: 120)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.secondarySystemGroupedBackground))
        .cornerRadius(15)
        .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 3)
    }
}

// MARK: - Sheet Views for Detailed Input

// UPDATED: More creative slider
struct QualitySettingsSheet: View {
    @Binding var quality: Double
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("Set Image Quality")
                    .font(.title2)
                    .fontWeight(.bold)
                Text("Adjust from 10% (lowest) to 100% (highest).")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)

                VStack {
                    ZStack {
                        LinearGradient(colors: [.red, .yellow, .green], startPoint: .leading, endPoint: .trailing)
                            .mask(Slider(value: .constant(1.0)))
                        Slider(value: $quality, in: 0.1 ... 1.0, step: 0.01)
                            .tint(.clear)
                    }
                    HStack {
                        Text("Low Quality")
                        Spacer()
                        Text("High Quality")
                    }
                    .font(.caption)
                    .foregroundColor(.secondary)
                }
                .padding(.horizontal)

                Text("Current Quality: \(String(format: "%.0f", quality * 100))%")
                    .font(.title3)
                    .fontWeight(.semibold)
                Spacer()
                Button("Confirm") { dismiss() }
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.green)
                    .cornerRadius(15)
                    .padding(.horizontal)
            }
            .padding(.vertical, 40)
            .navigationTitle("Quality")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
    }
}

struct FormatSettingsSheet: View {
    @Binding var selectedFormat: ImageFormat
    @Environment(\.dismiss) var dismiss
    private let columns: [GridItem] = [GridItem(.flexible()), GridItem(.flexible())]

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("Choose Output Format")
                    .font(.title2)
                    .fontWeight(.bold)
                LazyVGrid(columns: columns, spacing: 16) {
                    ForEach(ImageFormat.allCases) { format in
                        SelectionCard(
                            icon: icon(for: format),
                            title: format.rawValue,
                            caption: caption(for: format),
                            isSelected: selectedFormat == format
                        )
                        .onTapGesture { selectedFormat = format }
                    }
                }
                .padding(.horizontal)
                Spacer()
                Button("Confirm") { dismiss() }
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(15)
                    .padding(.horizontal)
            }
            .padding(.vertical, 40)
            .navigationTitle("Format")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
    }

    private func icon(for format: ImageFormat) -> String {
        switch format {
        case .jpeg: "doc.text.fill"
        case .heic: "speedometer"
        case .png: "sparkles"
        }
    }

    private func caption(for format: ImageFormat) -> String {
        switch format {
        case .jpeg: "Best for photos and web."
        case .heic: "Efficient, modern format."
        case .png: "Supports transparency."
        }
    }
}

struct ResolutionSettingsSheet: View {
    @Binding var selectedResolution: Resolution
    @Environment(\.dismiss) var dismiss
    private let columns: [GridItem] = [GridItem(.flexible()), GridItem(.flexible())]

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("Select Output Resolution")
                    .font(.title2)
                    .fontWeight(.bold)
                LazyVGrid(columns: columns, spacing: 16) {
                    ForEach(Resolution.allCases) { res in
                        SelectionCard(
                            icon: icon(for: res),
                            title: res.rawValue.components(separatedBy: " ").first ?? "",
                            caption: caption(for: res),
                            isSelected: selectedResolution == res
                        )
                        .onTapGesture { selectedResolution = res }
                    }
                }
                .padding(.horizontal)
                Spacer()
                Button("Confirm") { dismiss() }
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.orange)
                    .cornerRadius(15)
                    .padding(.horizontal)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.vertical, 40)
            .navigationTitle("Resolution")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { dismiss() }
                }
            }
            
        }
        .background {
            Color(.systemGroupedBackground)
                .ignoresSafeArea()
        }
    }

    private func icon(for resolution: Resolution) -> String {
        switch resolution {
        case .full: "fullscreen"
        case .large: "arrow.down.right.and.arrow.up.left"
        case .medium: "arrow.up.and.down.and.arrow.left.and.right"
        case .small: "arrow.right.and.left"
        }
    }

    private func caption(for resolution: Resolution) -> String {
        switch resolution {
        case .full: "Keeps original size."
        case .large: "Good for sharing."
        case .medium: "Ideal for social media."
        case .small: "Fastest for messaging."
        }
    }
}

// More creative stepper control
struct CompressionPassesSheet: View {
    @Binding var compressionPasses: Int
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("Set Compression Passes")
                    .font(.title2)
                    .fontWeight(.bold)
                Text("More passes improve compression but take longer.")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)

                Spacer()

                HStack {
                    Text("Passes:")
                        .font(.title)
                        .fontWeight(.regular)

                    Spacer()

                    HStack(spacing: 0) {
                        Button(action: {
                            if compressionPasses > 1 {
                                withAnimation { compressionPasses -= 1 }
                            }
                        }) {
                            Image(systemName: "minus")
                                .padding()
                        }
                        .disabled(compressionPasses <= 1)

                        Text("\(compressionPasses)")
                            .font(.title.weight(.bold))
                            .frame(minWidth: 50)
                            .contentTransition(.numericText())

                        Button(action: {
                            if compressionPasses < 10 {
                                withAnimation { compressionPasses += 1 }
                            }
                        }) {
                            Image(systemName: "plus")
                                .padding()
                        }
                        .disabled(compressionPasses >= 10)
                    }
                    .font(.headline.weight(.bold))
                    .background(Color(.secondarySystemGroupedBackground))
                    .clipShape(Capsule())
                }
                .padding(.horizontal, 40)

                Spacer()

                Button("Confirm") { dismiss() }
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.teal)
                    .cornerRadius(15)
                    .padding(.horizontal)
            }
            .padding(.vertical, 40)
            .navigationTitle("Passes")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
    }
}

// MARK: - New Reusable Card for Sheets

struct SelectionCard: View {
    let icon: String
    let title: String
    let caption: String
    let isSelected: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(isSelected ? .accentColor : .secondary)
            Spacer()
            Text(title)
                .font(.headline)
                .fontWeight(.bold)
                .foregroundColor(.primary)
            Text(caption)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
        .frame(height: 120)
        .frame(maxWidth: .infinity)
        .background(Color(.secondarySystemGroupedBackground))
        .cornerRadius(15)
        .overlay(
            RoundedRectangle(cornerRadius: 15)
                .stroke(isSelected ? Color.accentColor : Color.clear, lineWidth: 2.5)
        )
        .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 3)
        .animation(.easeInOut(duration: 0.2), value: isSelected)
    }
}

// MARK: - Reusable Subviews (Unchanged)

struct HeaderInfoView: View {
    let imageCount: Int

    var body: some View {
        VStack(spacing: 4) {
            Image(systemName: "photo.on.rectangle.angled")
                .font(.largeTitle)
                .foregroundColor(.accentColor)
            Text("Compressing \(imageCount) Images")
                .font(.headline)
                .fontWeight(.bold)
            Text("Adjust settings to optimize file size and quality.")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 20)
    }
}

struct ActionButtonView: View {
    var body: some View {
        Button(action: { print("Starting compression...") }) {
            Text("Start Compression")
                .font(.headline)
                .fontWeight(.bold)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.accentColor)
                .cornerRadius(15)
        }
        .padding(20)
    }
}

// MARK: - Preview

#Preview {
    NavigationView {
        CompressionConfigView()
    }
}
```


==== EXAMPLE 2 ====

### This example is similar in idea to the example above (example 1) but its more simple and focuses on being clean and straight forward. This can be used in a place where we don't need any images, graphs, or anything multi-media like that. This is for when we just need to convey a group of information to the user and make it feel premium and not overly-simple.

```swift

import SwiftUI

// MARK: - Main View
struct CompressionResultsView: View {
    // Properties
    let originalSize: Double = 2.4
    let newSize: Double = 0.8
    let compressionPasses: Int = 3
    let quality: Double = 0.7
    let dimensions: String = "4032x3024"
    
    // Computed properties
    var spaceSaved: Double { originalSize - newSize }
    var percentageDecrease: Double { (spaceSaved / originalSize) * 100 }

    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            // Renamed to match your codebase
            HeaderView1(percentageDecrease: percentageDecrease)
            
            // Renamed to match your codebase
            StatsGridView(
                originalSize: originalSize,
                newSize: newSize,
                spaceSaved: spaceSaved,
                compressionPasses: compressionPasses,
                quality: quality,
                dimensions: dimensions
            )
        }
        .padding(25)
        .background(Color(.systemBackground))
        .cornerRadius(20)
        .shadow(color: .black.opacity(0.1), radius: 15, x: 0, y: 5)
        .padding()
    }
}

// MARK: - Subviews

// Renamed as requested
struct HeaderView1: View {
    let percentageDecrease: Double
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Compression Complete")
                .font(.headline)
                .foregroundColor(.secondary)
            
            Text("\(percentageDecrease, specifier: "%.1f")%")
                .font(.system(size: 48, weight: .bold))
                .foregroundColor(.green)
            
            Text("Total space saved on this image.")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
    }
}

// Renamed as requested, but keeping the improved, cleaner layout
struct StatsGridView: View {
    let originalSize: Double
    let newSize: Double
    let spaceSaved: Double
    let compressionPasses: Int
    let quality: Double
    let dimensions: String
    
    var body: some View {
        VStack(spacing: 16) {
            // Using the new, cleaner StatCell1 implementation
            StatCell1(label: "Original Size", value: "\(originalSize, default: "%.1f") MB")
            StatCell1(label: "New Size", value: "\(newSize, default: "%.1f") MB")
            StatCell1(label: "Space Saved", value: "\(spaceSaved, default: "%.1f") MB")
            
            Divider().padding(.vertical, 8)
            
            StatCell1(label: "Quality Setting", value: "\(quality, default: "%.1f")")
            StatCell1(label: "Compression Passes", value: "\(compressionPasses)")
            StatCell1(label: "Dimensions", value: dimensions)
        }
    }
}

// Renamed as requested, with parameters adjusted for the new design
struct StatCell1: View {
    let label: String
    let value: String
    
    var body: some View {
        HStack {
            Text(label)
                .foregroundColor(.secondary)
            Spacer()
            Text(value)
                .fontWeight(.semibold)
                .foregroundColor(.primary)
        }
        .font(.system(.body, design: .rounded))
    }
}

#Preview {
    ZStack {
        Color(.systemGroupedBackground)
            .ignoresSafeArea()
        
        CompressionResultsView()
    }
}

```

==== EXAMPLE 3 ==== 
The following component is a good example what a simple, but crisp and easy-on-the-eyes badge/banner that conveys specific information to he user with a nice slightly-transparent background. This design choice is nice for UI because it highlights important information to the user but is subtle and elegant. It's also layered nicely with an icon for visual appeal, and then a heading and subheading. This design approach is used frequently in well-designed apps and even Apple native apps.


```swift
private struct TintedChip: View {
    var icon: String
    var title: String
    var subtitle: String? = nil

    var body: some View {
        HStack(spacing: MintUI.Space.s3) {
            Image(systemName: icon)
                .font(.system(size: 20, weight: .semibold))
                .foregroundColor(MintUI.Colors.mintDeep)
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(MintUI.Colors.textStrong)
                if let subtitle {
                    Text(subtitle)
                        .font(.system(size: 13))
                        .foregroundColor(MintUI.Colors.textMuted)
                }
            }
            Spacer(minLength: 0)
        }
        .padding(.horizontal, MintUI.Space.s5)
        .padding(.vertical, MintUI.Space.s4)
        .frame(height: 72)
        .background(MintUI.Gradients.mintChip)
        .cornerRadius(20)
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(MintUI.Colors.line, lineWidth: 1)
        )
    }
}

private enum MintUI {
    enum Colors {
        static let bg = Color(hex: "#F7F9F8")
        static let surface = Color.white
        static let surfaceTintMintA = Color(hex: "#ECF6F5")
        static let surfaceTintMintB = Color(hex: "#E6F0EE")

        static let textStrong = Color(hex: "#0B0B0B")
        static let text = Color(hex: "#1A1A1A")
        static let textMuted = Color(hex: "#636260")
        static let textSubtle = Color(hex: "#A2A1A1")

        static let line = Color.black.opacity(0.06)
        static let shadowSm = Color.black.opacity(0.06)

        static let mint = Color(hex: "#20A993")
        static let mintDeep = Color(hex: "#15443C")
        static let amber = Color(hex: "#F59E0B")
        static let goldSoft = Color(hex: "#E7D0A8")
        static let cta = Color(hex: "#0B0B0B")
    }

    enum Radii {
        static let card: CGFloat = 22
        static let chip: CGFloat = 14
        static let button: CGFloat = 16
    }

    enum Space {
        static let s1: CGFloat = 4
        static let s2: CGFloat = 8
        static let s3: CGFloat = 12
        static let s4: CGFloat = 16
        static let s5: CGFloat = 20
        static let s6: CGFloat = 24
        static let s7: CGFloat = 32
        static let s8: CGFloat = 40
    }

    enum Gradients {
        static let mintChip = LinearGradient(
            colors: [Colors.surfaceTintMintA, Colors.surfaceTintMintB],
            startPoint: .top,
            endPoint: .bottom
        )
    }
}
```
