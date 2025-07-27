# Apple's Human Interface Guidelines: Essential Updates for Liquid Glass in iOS 26

**Last Updated:** July 27, 2025

## Introduction: The Evolution of Interface Design

With the release of iOS 26 in July 2025, Apple introduces Liquid Glass, a groundbreaking design language that transforms the iOS interface into a dynamic, fluid material mimicking the properties of liquid and glass. This isn't just a visual overhaul—it's a system-wide evolution that leverages the A20 Bionic's Photonic Core for real-time rendering, creating an immersive experience where the UI bends, blurs, refracts, and flows around user content. Liquid Glass builds on Apple's core Human Interface Guidelines (HIG) principles of clarity, deference, depth, and consistency, while introducing new metaphors inspired by physics, light, and fluidity.

The July 2025 HIG refresh adds a dedicated "Liquid Glass" chapter, revised sections on colors, accessibility, and materials, and updated APIs for UIKit, SwiftUI, and the new FluidKit framework. The goal is to bring greater focus to content while adding vitality to controls, navigation, icons, and widgets, making the interface feel "alive" and responsive. Early betas showed iterative tweaks, such as restoring stronger warp effects in beta 4 for better legibility after user feedback. This guide distills the essentials for designers and developers, ensuring apps integrate seamlessly while prioritizing usability, performance, and inclusivity.

Liquid Glass treats the OS as a single, interactive fluid surface—translucent, reflective, and adaptive—where content is like a solid submerged below, and the UI emerges organically. It's familiar yet fresh, dynamic in context, and battery-friendly, pausing animations in Low Power Mode. By adhering to these guidelines, apps will feel native in iOS 26's shimmering world.

## Core Principles Reimagined

Apple's foundational principles are refined to embrace Liquid Glass's physical and light-based metaphors, ensuring the material enhances rather than obscures the user experience.

### Clarity Through Refraction and Legibility
Clarity is achieved via light physics: the system analyzes underlying content and adjusts refractive properties for maximum contrast.
- **Content Focus:** Use high-contrast text and icons on glassy backgrounds; avoid overly blurred effects in text-heavy areas.
- **Adaptive Readability:** Text scales dynamically on interactions, with San Francisco font weights optimized for translucency. Minimum body text size is 17 points.
- **Caustics for Attention:** Subtle shimmering patterns draw the eye to key elements, like notifications warping light before appearing.
- **Baseline Enhancements:** Increased contrast in notifications and secondary panels ensures WCAG 2.2 AA compliance.

### Deference Through Fluidity
The UI defers to content by flowing around it, emerging only when needed.
- **Medium-Like Behavior:** Controls are transparent when idle, bubbling up like swells in water on interaction.
- **Interaction Ripples:** Touches create ripples for feedback—small for taps, wakes for swipes—synced with haptics.
- **Non-Obstructive Design:** Avoid excessive glass effects; use sparingly to highlight interactives without overwhelming content.

### Depth as a Physical and Volumetric Dimension
Depth becomes tangible, with volumetric space replacing layered illusions.
- **Layering Limits:** Use Liquid Glass for a single depth tier; no more than two overlapping translucent layers to prevent muddiness.
- **Parallax and Motion:** Surfaces respond to device tilt with re-lighting and subtle distortions.
- **Physics Properties:** Introduce viscosity (η) for transition feel (e.g., honey-like for deliberate apps) and surface tension (γ) for cohesion in gestures like pinching notifications.
- **Volumetric Interactions:** Modals depress the surface, displacing surrounding content realistically.

### Consistency Across the Ecosystem
All system apps adopt Liquid Glass by default, with "All Clear" mode for minimalist, colorless glass. Third-party apps should follow for unity, supporting dynamic adaptations.

## Visual Design Essentials

Liquid Glass emphasizes translucency, colors, and typography that adapt fluidly.

### Colors and Materials
- **Translucency and Blur:** Default blur radius of 10-20 points; use `UIBlurEffectStyle.liquidGlass` for backgrounds. Avoid full opacity in non-interactives.
- **Color Modes:** Support Light, Dark, and All Clear; accents like blue links must maintain visibility on glassy surfaces.
- **System Adjustments:** Prefer `.backgroundUltraThin` materials beneath panels for automatic hue shifts ensuring 4.5:1 contrast.
- **Best Practices:** Test in varied lighting; opaque accents for buttons to prevent "disappearing" against wallpapers.

### Typography
- **Fluid Scaling:** Text expands subtly on hover/tap for emphasis.
- **Hierarchy:** Bold weights for headings on translucent backgrounds; use semantic styles like `UIFont.preferredFont(forTextStyle: .body)`.
- **Legibility Rules:** High contrast mandatory; avoid low-contrast glassy text.

## Layout and Components

Layouts prioritize fluidity with adaptive grids and glassy elements.

- **Adaptive Grids:** Safe areas and Dynamic Island blend with glassy edges; use Auto Layout for orientations and multitasking.
- **Widgets and Controls:** Default glassy overlays; buttons/sliders with liquid ripple effects (<200ms duration, paused on Reduce Motion).
- **Navigation:** Semi-translucent bars reveal content below; avoid deep stacking for performance.

| Component | Key Update | Best Practice |
|-----------|------------|---------------|
| Buttons | Liquid ripple on tap; displacement based on pressure | Sync with haptics; use opaque fills for primaries |
| Cards | Glassy borders with curved, droplet-like edges | Implement `UICardView`; limit shadows |
| Lists | Translucent separators with wave effects on scroll | Pull-to-refresh with fluid distortion |
| Modals | Full-screen glassy overlays bubbling up | Dismiss via swipe-down; 20% backdrop opacity |
| Menus/Pop-overs | Emerge from surface, pushing content aside | Submerge on dismiss; define viscosity for feel |

### Essential Interaction Patterns
- **Gestures:** Standard swipes/pinches with enhanced fluidity; ripples provide subconscious feedback.
- **Fluid Controls:** Buttons deform on press; sliders leave wakes; menus bubble up.
- **Morphic Multitasking:** Apps as gel-like spheres; merge for Split View, resize via fluid membranes.
- **Live Dock:** Icons float in a high-density channel; active apps create currents, drags produce "drip" animations.
- **Feedback:** Haptics tied to visuals (e.g., pebble-in-water for taps); use `UIImpactFeedbackGenerator`.

## Accessibility Considerations

Liquid Glass addresses early concerns like low-vision challenges with robust updates.
- **Contrast and Readability:** WCAG AA required; tools flag low-contrast glassy elements.
- **Customization:** Honor Reduce Transparency (swaps to solid colors) and Increase Contrast (boosts edge highlights).
- **VoiceOver:** Add traits like `UIAccessibilityTraitLiquidGlass` for fluid state descriptions.
- **Fallbacks:** Provide non-glassy options for critical UI; test in high-contrast modes.
- **Motion Respect:** Animations <200ms, paused on Reduce Motion.

## Performance and Implementation Essentials

Liquid Glass is GPU-accelerated but demands optimization.
- **Optimization:** Limit layers to 3-5 per view; shaders are Metal-based and tile-rendered.
- **Battery Impact:** Pauses in Low Power Mode; profile with Xcode's Shader Profiler to avoid overdraw on A17+ devices.
- **Testing:** Use Liquid Glass simulator presets; ensure iOS 24 compatibility.
- **APIs and Frameworks:**
  - **SwiftUI:** `.background(.liquidGlass)` or `.material(.liquidGlass)` for system material.
  - **UIKit:** `UIVisualEffectView(effect: UIBlurEffect(style: .liquidGlass))`; avoid custom opacity.
  - **FluidKit (New):** Declarative physics for advanced apps.
    ```swift
    View {
        Button("Confirm")
            .physics(
                .surfaceTension(.high),
                .viscosity(.medium),
                .refractionIndex(1.33)
            )
            .onPress { process() }  // System handles displacement
    }
    ```
  - **Icons/Widgets:** Flatten artwork; system applies reflections.
- **Migration Checklist:**
  1. Audit custom blurs/translucency for duplication.
  2. Test contrast in all modes.
  3. Verify fallbacks for accessibility settings.
  4. Profile for overdraw and battery efficiency.

## Resources
- HIG → Materials → Liquid Glass (Apple Developer Documentation)
- WWDC25 Session 102: Liquid Glass Preview (Developer App Video)
- Glassmorphism Best Practices (Nielsen Norman Group)
- SwiftUI/FluidKit Tutorials (Medium, Apple Developer)
- Beta Trackers (MacRumors, Tom's Guide)
- Accessibility Guides (Apple Support)

## Conclusion

Liquid Glass in iOS 26 redefines the HIG by treating the interface as a structuring material—beautiful, delightful, and intuitive—while preserving legibility and user control. Treat it as a privilege users can toggle off, and focus on content deference. By mastering these essentials, your app will thrive in this fluid, refractive ecosystem, feeling like an extension of the user's intent. For full details, consult Apple's developer resources.
