## This file contains examples of SwiftUI components that I have built. I enjoy the UI of these components, look and feel wise. An AI coding agent will use this file in conjunction with a view I want the AI to make, and will use this as guidance for UI aesthetic.
---
### EXAMPLE 1
--
This view is a compact view that shows in an iMessage extension in the compact size -- meaning it's taking up the space of the keyboard and is not fully expanded to the size of a full sheet. In this view, the user had selected an image to be compressed by using an image picker and this is the view showing them their selection as well as the size of the image and the compression preset they have selected. Design wise, this isa notable example for two reasons:
1. Its use of glassEffect -- a new feature of iOS 26 that apple is pivoting towards moving forward in their iOS designs.
2. It utilizes an approach where it allows the user to see extra information, but only if they want to. This is demonstrated by the button that shows the size of the image. By default, the extra metadata is hidden, but if the user clicks on the size button (which has a chevron indicating there is more to see), then it uses nice transitions and glass effect animations that slides the more information out. This contrasts the approach of showing the user all information no matter what, for example putting all the meta data in a box that is information-heavy and cluttering the screen. In my experience, I have noticed that Apple's native apps like Safari utilize the approach demonstrated in the code below -- where it doesn't just show the user every option, button, information, etc. right away (because it wouldn't be practical to do so), instead the user chooses to see it when they want to see it, and the UI hints to the user that its there... but it still requires some user-discovery. 


```swift
//
//  CompactSept10.swift
//  UISandbox
//
//  Created by Vincent DeAugustine on 9/10/25.
//

import SwiftUI

struct CompactSept10: View {
    @State private var isExpanded: Bool = false
    @Namespace private var namespace
    var body: some View {
        ZStack(alignment: .bottom) {
            VStack {
                Image("space")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
            }
            HStack(alignment: .bottom) {
                Button {
                    
                } label: {
                    Label("Custom", systemImage: "slider.horizontal.3")
                }
//                .font(.subheadline)
                
                .adaptiveGlassButtonStyle(.standard)

                Spacer()

                metaSatck

                Button {
                    
                } label: {
                    Image(systemName: "arrow.right.circle")
                        .foregroundStyle(.white)
                }
                .adaptiveGlassButtonStyle(.prominent)
            }
            .padding(.horizontal)
        }
    }
    
    @ViewBuilder private var metaSatck: some View {
        VStack(alignment: .trailing) {
            AdaptiveGlassContainer(spacing: 20) {
                VStack(alignment: .trailing, spacing: 12) {
                    if isExpanded {
                        Text("1920x1080")
                            .padding(.horizontal, 10)
                            .padding(.vertical, 5)
                            .adaptiveGlass(in: .capsule)
                            .adaptiveGlassID("dimensions", in: namespace)
                        
                        Text("JPEG")
                            .padding(.horizontal, 10)
                            .padding(.vertical, 5)
                            .adaptiveGlass(in: .capsule)
                            .adaptiveGlassID("type", in: namespace)
                    }
                    
                    Button {
                        withAnimation {
                            isExpanded.toggle()
                        }
                    } label: {
                        HStack {
                            Text("12 MB")
                            Image(systemName: "chevron.down")
                                .rotationEffect(.degrees(isExpanded ? 0 : 180))
                        }
                    }
                    .adaptiveGlassButtonStyle(.standard)
                    .adaptiveGlassID("button", in: namespace)
                }
            }
//            .font(.subheadline)
        }
    }
}

// MARK: - Environment flag to force fallback rendering in previews

private struct AdaptiveGlassForceFallbackKey: EnvironmentKey {
    static let defaultValue: Bool = false
}

private extension EnvironmentValues {
    var adaptiveGlassForceFallback: Bool {
        get { self[AdaptiveGlassForceFallbackKey.self] }
        set { self[AdaptiveGlassForceFallbackKey.self] = newValue }
    }
}

extension View {
    func adaptiveGlassForceFallback(_ force: Bool) -> some View {
        environment(\.adaptiveGlassForceFallback, force)
    }
}

// MARK: - Adaptive Glass Helpers (iOS 26 glass, fallback to ultraThinMaterial)

private enum AdaptiveGlassButtonKind {
    case standard
    case prominent
}

private extension View {
    // Apply glass when available; otherwise use ultraThinMaterial with a subtle stroke.
    @ViewBuilder
    func adaptiveGlass(in shape: some InsettableShape = RoundedRectangle(cornerRadius: 12, style: .continuous)) -> some View {
        modifier(AdaptiveGlassModifier(shape: AnyInsettableShape(shape)))
    }

    // No-op before iOS 26 (unless glass is available).
    @ViewBuilder
    func adaptiveGlassID(_ id: String, in namespace: Namespace.ID) -> some View {
        modifier(AdaptiveGlassIDModifier(id: id, namespace: namespace))
    }

    // Map glass button styles to a custom glass-like fallback on older systems.
    @ViewBuilder
    func adaptiveGlassButtonStyle(_ kind: AdaptiveGlassButtonKind) -> some View {
        modifier(AdaptiveGlassButtonModifier(kind: kind))
    }
}

private struct AdaptiveGlassModifier: ViewModifier {
    let shape: AnyInsettableShape
    @Environment(\.adaptiveGlassForceFallback) private var forceFallback

    func body(content: Content) -> some View {
        if #available(iOS 26.0, *), !forceFallback {
            content.glassEffect(.regular, in: shape)
        } else {
            content
                .background(.ultraThinMaterial, in: shape)
                .overlay(
                    shape
                        .strokeBorder(.white.opacity(0.20), lineWidth: 0.75)
                )
                .shadow(color: .black.opacity(0.15), radius: 8, x: 0, y: 4)
        }
    }
}

private struct AdaptiveGlassIDModifier: ViewModifier {
    let id: String
    let namespace: Namespace.ID
    @Environment(\.adaptiveGlassForceFallback) private var forceFallback

    func body(content: Content) -> some View {
        if #available(iOS 26.0, *), !forceFallback {
            content.glassEffectID(id, in: namespace)
        } else {
            content
        }
    }
}

private struct AdaptiveGlassButtonModifier: ViewModifier {
    let kind: AdaptiveGlassButtonKind
    @Environment(\.adaptiveGlassForceFallback) private var forceFallback

    func body(content: Content) -> some View {
        if #available(iOS 26.0, *), !forceFallback {
            switch kind {
            case .standard:
                content.buttonStyle(.glass)
            case .prominent:
                content.buttonStyle(.glassProminent)
            }
        } else {
            // Custom glass-like fallback
            switch kind {
            case .standard:
                content.buttonStyle(GlassFallbackButtonStyle(kind: .standard))
            case .prominent:
                content.buttonStyle(GlassFallbackButtonStyle(kind: .prominent))
            }
        }
    }
}

// MARK: - Glass-like fallback ButtonStyle

private struct GlassFallbackButtonStyle: ButtonStyle {
    let kind: AdaptiveGlassButtonKind
    
    func makeBody(configuration: Configuration) -> some View {
        let pressed = configuration.isPressed
        let shape = Capsule(style: .circular)
        
        return configuration.label
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
            .background(background(shape: shape, pressed: pressed))
            .overlay(
                shape
                    .strokeBorder(.white.opacity(kind == .prominent ? 0.22 : 0.20), lineWidth: kind == .prominent ? 1 : 0.75)
            )
            .shadow(color: .black.opacity(kind == .prominent ? 0.22 : 0.15), radius: kind == .prominent ? 10 : 8, x: 0, y: kind == .prominent ? 6 : 4)
            .scaleEffect(pressed ? 0.98 : 1.0)
            .animation(.easeOut(duration: 0.12), value: pressed)
            .tint(kind == .prominent ? .white : .primary)
    }
    
    @ViewBuilder
    private func background(shape: some InsettableShape, pressed: Bool) -> some View {
        switch kind {
        case .standard:
            // Blur + subtle translucency to read over imagery
            Color.white.opacity(0.06)
                .background(.ultraThinMaterial)
                .clipShape(shape)
                .overlay(
                    shape
                        .fill(.white.opacity(pressed ? 0.08 : 0.04))
                )
        case .prominent:
            // Tinted capsule with a hint of gloss to mimic prominent glass
            LinearGradient(colors: [
                Color.blue.opacity(pressed ? 0.95 : 1.0),
                Color.blue.opacity(pressed ? 0.85 : 0.92)
            ], startPoint: .topLeading, endPoint: .bottomTrailing)
            .clipShape(shape)
            .overlay(
                // Subtle top highlight
                shape
                    .strokeBorder(.white.opacity(0.35), lineWidth: 0.5)
                    .blendMode(.overlay)
            )
            .overlay(
                shape
                    .fill(.white.opacity(pressed ? 0.10 : 0.06))
            )
        }
    }
}

// MARK: - AnyInsettableShape wrapper to pass shapes around

private struct AnyInsettableShape: InsettableShape, Sendable {
    private let _path: @Sendable (CGRect) -> Path
    private let _inset: @Sendable (CGFloat) -> AnyInsettableShape
    
    init<S: InsettableShape & Sendable>(_ shape: S) {
        _path = { rect in shape.path(in: rect) }
        _inset = { amount in AnyInsettableShape(shape.inset(by: amount)) }
    }
    
    func path(in rect: CGRect) -> Path {
        _path(rect)
    }
    
    func inset(by amount: CGFloat) -> AnyInsettableShape {
        _inset(amount)
    }
}

// MARK: - Adaptive container wrapper

private struct AdaptiveGlassContainer<Content: View>: View {
    var spacing: CGFloat
    @ViewBuilder var content: () -> Content
    @Environment(\.adaptiveGlassForceFallback) private var forceFallback

    var body: some View {
        if #available(iOS 26.0, *), !forceFallback {
            GlassEffectContainer(spacing: spacing) {
                content()
            }
        } else {
            // Fallback: simple VStack with same spacing
            VStack(spacing: spacing) {
                content()
            }
        }
    }
}

// MARK: - Previews

#Preview("iOS 26 (Glass)") {
    CompactSept10()
        .frame(height: 216)
        .adaptiveGlassForceFallback(false)
}

#Preview("Fallback (ultraThinMaterial)") {
    CompactSept10()
        .frame(height: 216)
        .adaptiveGlassForceFallback(true)
}

```
