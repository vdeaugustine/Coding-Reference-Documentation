## This file contains examples of SwiftUI components that I have built. I enjoy the UI of these components, look and feel wise. An AI coding agent will use this file in conjunction with a view I want the AI to make, and will use this as guidance for UI aesthetic.

### EXAMPLE 1 

These views demonstrate use of a very clean, very minimalistic approach to presenting information to the user. Rather than different colors used for layering components and boxes, it utilizes outlining and slight shadows. You will also notice that it uses a black and white theme. While it would work with any accent color, the fact that it works well with black as the main accent tint shows that the clean simplicity works in this minimal aesthetic.

```swift
import SwiftUI

struct CompressingSubmitView: View {
    let presetString: String = "Balanced"
    
    @Environment(\.colorScheme) private var colorScheme: ColorScheme
    
    var background: Color {
        if colorScheme == .dark {
            Color(.secondarySystemBackground)
        } else {
            Color(.systemBackground)
        }
        
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                HStack {
                    Text("Compressing")
                        .font(.title2)
                        .fontWeight(.semibold)

                    Spacer()

                    Text(presetString)
                        .font(.headline)
                        .foregroundStyle(.secondary)
                }
                .padding(.horizontal)

                Image("space")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .frame(maxHeight: 200)

                VStack(spacing: -10) {
                    BorderedBox(background: background, shadow: .verySubtle) {
                        HStack {
                            Text("Original")
                                .font(.headline)
                            Spacer()
                            Text("2.8 MB")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }

                        Divider()

                        VStack(spacing: 12) {
                            contentRow(label: "Format", value: "JPEG", sfSymbol: "photo")
                            contentRow(label: "Dimensions", value: "920 x 1080", sfSymbol: "ruler")
                        }
                    }

                    BorderedBox(background: background, shadow: .verySubtle) {
                        HStack {
                            Text("Settings")
                                .font(.headline)
                            Spacer()
                            Text(presetString)
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }

                        Divider()

                        VStack(spacing: 12) {
                            contentRow(label: "Quality", value: "0.8", sfSymbol: "slider.horizontal.3")
                            contentRow(label: "Output format", value: "JPEG", sfSymbol: "photo.on.rectangle")
                            contentRow(label: "Passes", value: "5", sfSymbol: "arrow.triangle.2.circlepath")
                        }
                    }
                }
                Spacer()

                
            }
            .padding(.vertical, 16)
            
        }
        .safeAreaInset(edge: .bottom) {
            bottomButtons
                .padding()
        }
    }

    @ViewBuilder
    var bottomButtons: some View {
        // Bottom action buttons
        HStack(spacing: 12) {
            Button(action: {
                // TODO: Modify action
            }) {
                HStack {
                    Spacer()
                    Image(systemName: "slider.horizontal.3")
                    Text("Modify")
                        .fontWeight(.medium)
                    Spacer()
                }
                .font(.subheadline)
                .foregroundStyle(.primary)
                .padding(.vertical, 12)
                .padding(.horizontal, 14)
                .background(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .stroke(colorScheme == .dark ? Color.secondary : Color.black.opacity(0.08), lineWidth: 1.5)
                        .fill(Color(.systemBackground))
                )
            }
            .buttonStyle(.plain)

            Button(action: {
                // TODO: Go action
            }) {
                HStack(spacing: 8) {
                    Spacer()
                    Text("Go")
                        .fontWeight(.semibold)
                    Image(systemName: "arrow.right")
                        .font(.headline)
                    Spacer()
                }
                .font(.subheadline)
                .foregroundStyle(.white)
                .padding(.vertical, 12)
                .padding(.horizontal, 14)
                .background(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(Color.black)
                )
            }
            .buttonStyle(.plain)
        }
        .padding(.top, 8)
    }

    @ViewBuilder
    func contentRow(label: String, value: String, sfSymbol: String) -> some View {
        HStack {
            Group {
                Image(systemName: sfSymbol)
                Text(label)
            }
            .font(.subheadline)
            .foregroundStyle(.secondary)
            .fontWeight(.medium)
            Spacer()
            Text(value)
                .font(.subheadline)
                .fontWeight(.medium)
        }
    }
}

#Preview {
    CompressingSubmitView()
}


//
//  EnterCompressionSettings.swift
//  UISandbox
//
//  Created by Vincent DeAugustine on 9/7/25.
//

import SwiftUI

struct EnterCompressionSettings: View {
    let presetString: String = "Balanced"

    @Environment(\.colorScheme) private var colorScheme: ColorScheme
    @State private var quality: Double = 80 // 10...100
    @State private var format: Format = .jpeg
    @State private var selectedPreset: PresetTypes = .custom
    @State private var customName: String = ""
    @State private var justSavedCustom: Bool = false

    enum Format: String, CaseIterable {
        case jpeg = "JPEG"
        case png = "PNG"
        case webp = "WebP"
    }

    var background: Color {
        if colorScheme == .dark {
            return Color(.secondarySystemBackground)
        } else {
            return Color(.systemBackground)
        }
    }

    enum PresetTypes: String, CaseIterable {
        case balanced
        case tiny
        case large
        case custom
    }

    struct Preset: Equatable, Hashable {
        static let balanced = Preset(.balanced)
        static let tiny = Preset(.tiny)
        static let large = Preset(.large)
        static let custom = Preset(.custom)

        let name: String
        let quality: Double
        let format: Format
        let sfSymbol: String

        init(name: String, quality: Double, format: Format, sfSymbol: String) {
            self.name = name
            self.quality = quality
            self.format = format
            self.sfSymbol = sfSymbol
        }

        init(_ presetType: PresetTypes) {
            switch presetType {
            case .balanced:
                self.init(name: "Balanced", quality: 80, format: .jpeg, sfSymbol: "photo.on.rectangle")
            case .tiny:
                self.init(name: "Tiny", quality: 20, format: .webp, sfSymbol: "photo")
            case .large:
                self.init(name: "Large", quality: 100, format: .png, sfSymbol: "photo.stack")
            case .custom:
                self.init(name: "Custom", quality: 80, format: .jpeg, sfSymbol: "slider.horizontal.3")
            }
        }

        func hash(into hasher: inout Hasher) {
            hasher.combine(name)
            hasher.combine(quality)
            hasher.combine(format)
            hasher.combine(sfSymbol)
        }

        static func == (lhs: Preset, rhs: Preset) -> Bool {
            // Safer than comparing hashValue
            return lhs.name == rhs.name &&
                lhs.quality == rhs.quality &&
                lhs.format == rhs.format &&
                lhs.sfSymbol == rhs.sfSymbol
        }
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                VStack(spacing: 24) {
                    header
                    Divider()
                        .padding([.leading, .bottom])
                }

                VStack(alignment: .leading, spacing: 8) {
                    Text("Presets")
                        .font(.headline)
                        .foregroundStyle(.secondary)
                        .padding(.leading)

                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            ForEach(PresetTypes.allCases, id: \.self) { type in
                                presetChip(for: type)
                            }
                        }
                        .padding(.horizontal)
                        .padding(.vertical, 2)
                        .padding(.bottom)
                    }
                }

                VStack(alignment: .leading, spacing: 0) {
                    HStack {
                        Text("Details")
                            .font(.headline)
                            .foregroundStyle(.secondary)
                        Spacer()
                        if selectedPreset != .custom {
                            Button {
                                let base = Preset(selectedPreset)
                                // Seed custom with current preset values and select it
                                withAnimation(.easeInOut(duration: 0.2)) {
                                    format = base.format
                                    quality = base.quality
                                    selectedPreset = .custom
                                }
                            } label: {
                                HStack(spacing: 6) {
                                    Image(systemName: "wand.and.stars")
                                    Text("Customize")
                                        .fontWeight(.medium)
                                }
                                .font(.subheadline)
                                .padding(.vertical, 6)
                                .padding(.horizontal, 10)
                                .background(
                                    Capsule(style: .continuous)
                                        .fill(Color(.systemBackground))
                                )
                                .overlay(
                                    Capsule(style: .continuous)
                                        .stroke(colorScheme == .dark ? Color.secondary : Color.black.opacity(0.08), lineWidth: 1)
                                )
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    // .padding(.horizontal)

                    // BorderedBox(background: background, shadow: .verySubtle) {
                    if selectedPreset == .custom {
                        VStack(alignment: .leading, spacing: 12) {
                            // Format picker

                            Picker("Format", selection: $format) {
                                ForEach(Format.allCases, id: \.self) { f in
                                    Text(f.rawValue).tag(f)
                                }
                            }
                            .pickerStyle(.segmented)

                            

                                VStack(alignment: .leading, spacing: 8) {
                                    HStack {
                                        Group {
                                            Image(systemName: "slider.horizontal.3")
                                            Text("Quality")
                                        }
                                        .font(.subheadline)
                                        .foregroundStyle(.secondary)
                                        .fontWeight(.medium)
                                        Spacer()
                                        Text("\(Int(quality))%")
                                            .font(.subheadline)
                                            .fontWeight(.medium)
                                    }
                                    Slider(value: $quality, in: 10 ... 100, step: 1)
                                }
                                .padding() 
                                .borderedSurface(background: background, shadow: .verySubtle)
                            
                        }
                        .padding(.vertical, 6)
                    } else {
                        VStack(alignment: .leading, spacing: 8) {
                            contentRow(label: "Format", value: format.rawValue, sfSymbol: "photo")
                            BoxDivider()
                            contentRow(label: "Quality", value: "\(Int(quality))%", sfSymbol: "slider.horizontal.3")
                            BoxDivider()
                            contentRow(label: "Dimensions", value: "Original", sfSymbol: "ruler")
                        }
                    }
                    // }
                }
                .padding()

                // Divider()
                //     .padding([.leading, .vertical])

                // Save custom preset section
                if selectedPreset == .custom {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Save")
                            .font(.headline)
                            .foregroundStyle(.secondary)
                            .padding(.leading)

                        HStack {
                            Image(systemName: "bookmark")
                                .foregroundStyle(.secondary)
                            TextField("Give it a name", text: $customName)
                                .textInputAutocapitalization(.words)
                                .disableAutocorrection(true)
                                .padding(.vertical, 8)
                                .padding(.horizontal, 10)
                            // .background(
                            //     RoundedRectangle(cornerRadius: 10, style: .continuous)
                            //         .stroke(colorScheme == .dark ? Color.secondary : Color.black.opacity(0.08), lineWidth: 1)
                            //         .fill(Color(.systemBackground))
                            // )
                        }
                        .padding(.horizontal)
                        .padding(.vertical, 2)
                        .borderedSurface(background: background, shadow: .verySubtle)
                        .padding(.horizontal)
                    }
                }

                Spacer()
            }
            .padding(.vertical, 16)
        }
        .safeAreaInset(edge: .bottom) {
            bottomButtons
                .padding()
        }
    }

    func presetChip(for type: PresetTypes) -> some View {
        let preset = Preset(type)
        let isSelected = type == selectedPreset
        return Button {
            withAnimation(.easeInOut(duration: 0.2)) {
                selectedPreset = type
                quality = preset.quality
                format = preset.format
                if type != .custom { justSavedCustom = false }
            }
        } label: {
            HStack(spacing: 6) {
                Image(systemName: preset.sfSymbol)
                    .font(.caption)
                Text(preset.name)
                    .font(.subheadline)
                    .fontWeight(.medium)
            }
            .padding(.vertical, 8)
            .padding(.horizontal, 12)
            .background(
                Capsule(style: .continuous)
                    .fill(isSelected ? Color.black : Color(.systemBackground))
            )
            .overlay(
                Capsule(style: .continuous)
                    .stroke(colorScheme == .dark ? Color.secondary : Color.black.opacity(0.08), lineWidth: isSelected ? 0 : 1.5)
            )
            .foregroundStyle(isSelected ? .white : .primary)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }

    private func saveCustomPreset() {
        // Simulate saving; integrate persistence as needed
        justSavedCustom = true
    }

    var header: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("Configure")
                    .font(.title2)
                    .fontWeight(.semibold)
                Text("Choose your compression settings")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            Spacer()
        }
        .padding(.horizontal)
    }

    @ViewBuilder
    var bottomButtons: some View {
        // Bottom action buttons
        HStack(spacing: 12) {
            Button(action: {
                // TODO: Modify action
            }) {
                HStack {
                    Spacer()
                    Image(systemName: "bookmark")
                    Text("Save Preset")
                        .fontWeight(.medium)
                    Spacer()
                }
                .font(.subheadline)
                .foregroundStyle(.primary)
                .padding(.vertical, 12)
                .padding(.horizontal, 14)
                .background(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .stroke(colorScheme == .dark ? Color.secondary : Color.black.opacity(0.08), lineWidth: 1.5)
                        .fill(Color(.systemBackground))
                )
            }
            .buttonStyle(.plain)

            Button(action: {
                // TODO: Go action
            }) {
                HStack(spacing: 8) {
                    Spacer()
                    Text("Go")
                        .fontWeight(.semibold)
                    Image(systemName: "arrow.right")
                        .font(.headline)
                    Spacer()
                }
                .font(.subheadline)
                .foregroundStyle(.white)
                .padding(.vertical, 12)
                .padding(.horizontal, 14)
                .background(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(Color.black)
                )
            }
            .buttonStyle(.plain)
        }
        .padding(.top, 8)
    }

    @ViewBuilder
    func contentRow(label: String, value: String, sfSymbol: String) -> some View {
        HStack {
            Group {
                Image(systemName: sfSymbol)
                Text(label)
            }
            .font(.subheadline)
            .foregroundStyle(.secondary)
            .fontWeight(.medium)
            Spacer()
            Text(value)
                .font(.subheadline)
                .fontWeight(.medium)
        }
    }
}

#Preview {
    EnterCompressionSettings()
}

//
//  CompressResultsView.swift
//  UISandbox
//
//  Created by Vincent DeAugustine on 9/7/25.
//

import SwiftUI

struct CompressResultsView: View {
    struct ImageMetadata: Equatable {
        var sizeBytes: Int
        var format: String
        var dimensions: String
    }

    let presetString: String
    let original: ImageMetadata
    let result: ImageMetadata

    // MARK: - Computed

    private var originalSizeString: String { byteCountString(original.sizeBytes) }
    private var resultSizeString: String { byteCountString(result.sizeBytes) }

    private var bytesSaved: Int { max(original.sizeBytes - result.sizeBytes, 0) }
    private var savingsString: String { byteCountString(bytesSaved) }

    private var percentSaved: Double {
        guard original.sizeBytes > 0 else { return 0 }
        return (Double(bytesSaved) / Double(original.sizeBytes)) * 100.0
    }

    @Environment(\.colorScheme) private var colorScheme: ColorScheme
    
    var background: Color {
        if colorScheme == .dark {
            Color(.secondarySystemBackground)
        } else {
            Color(.systemBackground)
        }
        
    }

    // MARK: - Body

    var body: some View {
        ScrollView {
            VStack(spacing: 10) {
                // Header
                HStack {
                    Text("Results")
                        .font(.title2)
                        .fontWeight(.semibold)

                    Spacer()

                    Image(systemName: "square.and.arrow.up")
                        .font(.headline)
                        .foregroundStyle(.secondary)
                }
                .padding(.horizontal)

                // Preview image (same test image as submit view)
                Image("space")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .frame(maxHeight: 200)
                    .padding(.top, 4)

                VStack(spacing: -10) {
                    // Comparison box with 3 columns
                    BorderedBox(background: background, shadow: .verySubtle) {
                        HStack {
                            Text("Comparison")
                                .font(.headline)
                            Spacer()
                        }

                        BoxDivider()

                        VStack(spacing: 0) {
                            // Column headers
                            HStack {
                                Text("Original")
                                    .font(.footnote)
                                    .foregroundStyle(.secondary)
                                    .frame(maxWidth: .infinity, alignment: .leading)

                                Text("") // spacer column (labels column header intentionally blank)
                                    .font(.footnote)
                                    .foregroundStyle(.secondary)
                                    .frame(maxWidth: .infinity, alignment: .center)

                                Text("Result")
                                    .font(.footnote)
                                    .foregroundStyle(.secondary)
                                    .frame(maxWidth: .infinity, alignment: .trailing)
                            }
                            .padding(.bottom, 8)

                            // Rows
                            comparisonRow(left: originalSizeString,
                                          label: "Size",
                                          right: resultSizeString,
                                          labelSymbol: "internaldrive")

                            BoxDivider()

                            comparisonRow(left: original.format,
                                          label: "Format",
                                          right: result.format,
                                          labelSymbol: "photo")

                            BoxDivider()

                            comparisonRow(left: original.dimensions,
                                          label: "Dimensions",
                                          right: result.dimensions,
                                          labelSymbol: "aspectratio")
                        }
                    }

                    // Optional summary box (kept for quick read)
                    BorderedBox(background: background, shadow: .verySubtle) {
                        HStack {
                            Text("Summary")
                                .font(.headline)
                            Spacer()
//                            Text("\(String(format: "%.1f", percentSaved))%")
//                                .font(.subheadline)
//                                .foregroundStyle(.secondary)
                        }

                        BoxDivider()

                        VStack(spacing: 12) {
                            contentRow(label: "Saved", value: savingsString, sfSymbol: "arrow.down.circle")
                            BoxDivider()
                            contentRow(label: "Reduction", value: String(format: "%.1f%%", percentSaved), sfSymbol: "percent")
                        }

                        VStack(spacing: 10) {
                            GeometryReader { geometry in
                                ZStack(alignment: .leading) {
                                    RoundedRectangle(cornerRadius: 10)
                                        .fill(.tertiary)
                                    RoundedRectangle(cornerRadius: 10)
                                        .fill(.primary)
                                        .frame(width: geometry.size.width * 0.5)
                                }
                            }
                            .frame(height: 14)
                            .padding(.top)

                            HStack(alignment: .center) {
                                HStack(spacing: 4) {
                                    Image(systemName: "circle.fill")
                                        .foregroundStyle(.primary) // gray icon
                                    Text("Result")
                                        .foregroundStyle(.primary) // keep text primary
                                        .font(.caption2)
                                }

                                Spacer()

                                HStack(spacing: 4) {
                                    Text("Original")
                                        .foregroundStyle(.primary) // keep text primary
                                        .font(.caption2)

                                    Image(systemName: "circle.fill")
                                        .foregroundStyle(.secondary) // gray icon
                                }
                            }
                            .font(.caption2)
                        }
                    }
                }

                Spacer()
            }
            .padding(.vertical, 16)
        }
        .safeAreaInset(edge: .bottom) {
            bottomButtons
                .padding()
        }
    }

    // MARK: - 3-Column Comparison Row

    @ViewBuilder
    private func comparisonRow(left: String,
                               label: String,
                               right: String,
                               labelSymbol: String? = nil) -> some View {
        HStack(alignment: .firstTextBaseline) {
            // Left (Original) — no icon
            HStack(spacing: 6) {
                Text(left)
                    .font(.footnote.monospacedDigit())
                    .fontWeight(.medium)
                    .foregroundStyle(.primary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            // Middle (Label + icon) — icon one size smaller
            HStack(spacing: 6) {
                if let labelSymbol {
                    Image(systemName: labelSymbol)
                        .font(.caption2) // smaller than the text font
                        .foregroundStyle(.secondary)
                }
                Text(label)
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                    .fontWeight(.medium)
            }
            .frame(maxWidth: .infinity, alignment: .center)

            // Right (Result) — no icon
            HStack(spacing: 6) {
                Text(right)
                    .font(.footnote.monospacedDigit())
                    .fontWeight(.medium)
                    .foregroundStyle(.primary)
            }
            .frame(maxWidth: .infinity, alignment: .trailing)
        }
        .padding(.vertical, 8)
    }

    // MARK: - Bottom Buttons (styled like CompressingSubmitView)

    @ViewBuilder
    var bottomButtons: some View {
        HStack(spacing: 12) {
            Menu {
                Button("Compress again", systemImage: "arrow.2.circlepath") {
                }
                Button("Share", systemImage: "square.and.arrow.up") {
                }
                Button("Compare", systemImage: "rectangle.split.2x1") {}
            } label: {
                HStack {
                    Spacer()
                    Image(systemName: "ellipsis")
                    Text("More")
                        .fontWeight(.medium)
                    Spacer()
                }
                .font(.subheadline)
                .foregroundStyle(.primary)
                .padding(.vertical, 12)
                .padding(.horizontal, 14)
                .background(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .stroke(colorScheme == .dark ? Color.secondary : Color.black.opacity(0.08), lineWidth: 1.5)
                        .fill(
                            Color(.systemBackground)
                        )
                )
            }
            .buttonStyle(.plain)

            Button(action: {
                // TODO: Done action
            }) {
                HStack(spacing: 8) {
                    Spacer()
                    Text("Done")
                        .fontWeight(.semibold)
                    Image(systemName: "checkmark")
                        .font(.headline)
                    Spacer()
                }
                .font(.subheadline)
                .foregroundStyle(colorScheme == .dark ? .black : .white)
                .padding(.vertical, 12)
                .padding(.horizontal, 14)
                .background(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(.primary)
//                        .fill(colorScheme == .dark ? Color.white : Color.black)
                )
            }
            .buttonStyle(.plain)
        }
        .padding(.top, 8)
    }

    // MARK: - Row helper (mirrors CompressingSubmitView)

    @ViewBuilder
    func contentRow(label: String, value: String, sfSymbol: String) -> some View {
        HStack {
            Group {
                Image(systemName: sfSymbol)
                Text(label)
            }
            .font(.footnote)
            .foregroundStyle(.secondary)
            .fontWeight(.medium)

            Spacer()

            Text(value)
                .font(.footnote)
                .fontWeight(.medium)
        }
    }

    // MARK: - Formatters

    private func byteCountString(_ bytes: Int) -> String {
        let formatter = ByteCountFormatter()
        formatter.allowedUnits = [.useKB, .useMB, .useGB]
        formatter.countStyle = .file
        formatter.includesUnit = true
        return formatter.string(fromByteCount: Int64(bytes))
    }
}

// MARK: - Preview

#Preview {
    CompressResultsView(
        presetString: "Balanced",
        original: .init(sizeBytes: 2940000, format: "JPEG", dimensions: "1920 × 1080"),
        result: .init(sizeBytes: 1240000, format: "JPEG", dimensions: "1920 × 1080")
    )
}

```
