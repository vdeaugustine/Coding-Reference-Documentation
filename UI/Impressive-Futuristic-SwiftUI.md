## This file contains examples of SwiftUI components that I have built. I enjoy the UI of these components, look and feel wise. An AI coding agent will use this file in conjunction with a view I want the AI to make, and will use this as guidance for UI aesthetic.

### EXAMPLE 1 

This example is a compact view for an imessage extension. It is to be shwon when the imessage extension is in compact mode and not full screen; meaning, the view only takes up the space of the keyboard until the user expands it if they want. 
The purpose of this example is to show the user what the results of their image compression were. The meta data and the space saved. 
This is a cutting-edge futuristic sort of tech-impressive aesthetic. A full app with this UI would appeal to tech enthusiasts and would feel very premium. 

```swift
import SwiftUI

// MARK: - Compact Theme Configuration
struct CompactTheme {
    // Primary Colors
    static var successColor = Color.green
    static var primaryBlue = Color.blue
    static var accentOrange = Color.orange
    static var subtleGray = Color.gray
    
    // Gradient Sets
    static var backgroundGradient = [Color.black.opacity(0.95), Color.gray.opacity(0.1)]
    static var cardGradient = [Color.white.opacity(0.08), Color.white.opacity(0.03)]
    static var borderGradient = [Color.white.opacity(0.25), Color.clear]
    static var successGradient = [Color.green, Color.green.opacity(0.7)]
    static var statsGradient = [Color.blue.opacity(0.8), Color.purple.opacity(0.6)]
    
    // Savings indicator colors
    static var savingsColors = [Color.blue, Color.cyan]
}

struct CompactCompressionView: View {
    @State private var animateResults = false
    @State private var showingDetails = false
    @State private var pulseAnimation = false
    
    let originalSize = "680 KB"
    let compressedSize = "893 KB" // This seems wrong in the image, but keeping as shown
    let savingsPercent = "-31%"
    let savingsAmount = "-213 KB saved"
    
    var body: some View {
        VStack(spacing: 0) {
            // Top Handle
            RoundedRectangle(cornerRadius: 3)
                .fill(Color.gray.opacity(0.5))
                .frame(width: 36, height: 4)
                .padding(.top, 8)
                .padding(.bottom, 16)
            
            // Main Content
            VStack(spacing: 16) {
                // Header Section
                CompletionHeader()
                
                // Results Section
                CompressionResultsCard(
                    originalSize: originalSize,
                    compressedSize: compressedSize,
                    savingsPercent: savingsPercent,
                    animateResults: $animateResults
                )
                
                // Technical Details Row
                TechnicalDetailsRow()
                
                // Action Bar
                CompactActionBar()
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 16)
        }
        .frame(maxHeight: 280) // Compact keyboard height
        .background(
            LinearGradient(
                colors: CompactTheme.backgroundGradient,
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .onAppear {
            withAnimation(.easeOut(duration: 1.0).delay(0.3)) {
                animateResults = true
            }
        }
    }
}

struct CompletionHeader: View {
    @State private var checkmarkScale = 0.0
    
    var body: some View {
        HStack(spacing: 12) {
            Button {
                // Back action
            } label: {
                Image(systemName: "arrow.backward")
                    .foregroundColor(.white)
                    .font(.system(size: 16, weight: .medium))
                    .frame(width: 32, height: 32)
                    .background(
                        Circle()
                            .fill(Color.white.opacity(0.1))
                            .overlay(
                                Circle()
                                    .stroke(Color.white.opacity(0.2), lineWidth: 1)
                            )
                    )
            }
            
            VStack(alignment: .leading, spacing: 2) {
                HStack(spacing: 8) {
                    // Animated checkmark
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(CompactTheme.successColor)
                        .font(.system(size: 16, weight: .semibold))
                        .scaleEffect(checkmarkScale)
                        .onAppear {
                            withAnimation(.spring(response: 0.6, dampingFraction: 0.7).delay(0.2)) {
                                checkmarkScale = 1.0
                            }
                        }
                    
                    Text("Complete")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)
                }
                
                Text("-213 KB saved")
                    .font(.system(size: 12))
                    .foregroundColor(CompactTheme.subtleGray)
            }
            
            Spacer()
        }
    }
}

struct CompressionResultsCard: View {
    let originalSize: String
    let compressedSize: String
    let savingsPercent: String
    @Binding var animateResults: Bool
    
    var body: some View {
        HStack(spacing: 24) {
            // Before/After Sizes
            HStack(spacing: 16) {
                // Original
                SizeIndicator(
                    size: originalSize,
                    label: "Original",
                    color: CompactTheme.subtleGray,
                    delay: 0.1
                )
                
                // Arrow
                Image(systemName: "arrow.forward")
                    .foregroundColor(CompactTheme.primaryBlue)
                    .font(.system(size: 14, weight: .medium))
                    .opacity(animateResults ? 1 : 0)
                    .animation(.easeInOut(duration: 0.5).delay(0.4), value: animateResults)
                
                // Compressed
                SizeIndicator(
                    size: compressedSize,
                    label: "Compressed",
                    color: CompactTheme.primaryBlue,
                    delay: 0.2
                )
            }
            
            Spacer()
            
            // Savings Circle
            SavingsIndicator(
                percentage: savingsPercent,
                animateResults: $animateResults
            )
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(
                    LinearGradient(
                        colors: CompactTheme.cardGradient,
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(
                            LinearGradient(
                                colors: CompactTheme.borderGradient,
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1
                        )
                )
        )
    }
}

struct SizeIndicator: View {
    let size: String
    let label: String
    let color: Color
    let delay: Double
    
    @State private var animate = false
    
    var body: some View {
        VStack(spacing: 4) {
            Text(size)
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(.white)
                .scaleEffect(animate ? 1 : 0.8)
                .opacity(animate ? 1 : 0)
            
            Text(label)
                .font(.system(size: 10, weight: .medium))
                .foregroundColor(color)
                .textCase(.uppercase)
                .tracking(0.5)
        }
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8).delay(delay)) {
                animate = true
            }
        }
    }
}

struct SavingsIndicator: View {
    let percentage: String
    @Binding var animateResults: Bool
    @State private var rotationAngle = 0.0
    
    var body: some View {
        ZStack {
            // Background circle
            Circle()
                .stroke(Color.white.opacity(0.1), lineWidth: 3)
                .frame(width: 60, height: 60)
            
            // Progress circle
            Circle()
                .trim(from: 0, to: animateResults ? 0.31 : 0) // 31% savings
                .stroke(
                    LinearGradient(
                        colors: CompactTheme.savingsColors,
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    style: StrokeStyle(lineWidth: 3, lineCap: .round)
                )
                .frame(width: 60, height: 60)
                .rotationEffect(.degrees(-90))
                .animation(.easeInOut(duration: 1.0).delay(0.5), value: animateResults)
            
            // Percentage text
            Text(percentage)
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(CompactTheme.primaryBlue)
                .scaleEffect(animateResults ? 1 : 0)
                .animation(.spring(response: 0.6, dampingFraction: 0.7).delay(0.8), value: animateResults)
        }
    }
}

struct TechnicalDetailsRow: View {
    let techSpecs = [
        ("rectangle.portrait", "JPEG"),
        ("rectangle.expand.vertical", "1978×2560"),
        ("scale.3d", "Balanced"),
        ("clock", "0.12s"),
        ("arrow.clockwise", "1")
    ]
    
    var body: some View {
        HStack(spacing: 0) {
            ForEach(Array(techSpecs.enumerated()), id: \.offset) { index, spec in
                TechSpecBadge(
                    icon: spec.0,
                    text: spec.1,
                    color: CompactTheme.subtleGray,
                    delay: Double(index) * 0.1
                )
                
                if index < techSpecs.count - 1 {
                    Spacer()
                }
            }
        }
        .padding(.horizontal, 8)
    }
}

struct TechSpecBadge: View {
    let icon: String
    let text: String
    let color: Color
    let delay: Double
    
    @State private var animate = false
    
    var body: some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .foregroundColor(color)
                .font(.system(size: 12))
                .frame(width: 20, height: 20)
                .background(
                    RoundedRectangle(cornerRadius: 6)
                        .fill(Color.white.opacity(0.05))
                        .overlay(
                            RoundedRectangle(cornerRadius: 6)
                                .stroke(color.opacity(0.3), lineWidth: 0.5)
                        )
                )
            
            Text(text)
                .font(.system(size: 9, weight: .medium))
                .foregroundColor(color)
                .lineLimit(1)
        }
        .opacity(animate ? 1 : 0)
        .offset(y: animate ? 0 : 10)
        .onAppear {
            withAnimation(.easeOut(duration: 0.4).delay(delay + 0.6)) {
                animate = true
            }
        }
    }
}

struct CompactActionBar: View {
    var body: some View {
        HStack(spacing: 16) {
            // Primary actions
            ActionBarButton(
                icon: "house.fill",
                isSelected: false,
                color: CompactTheme.subtleGray
            ) {
                // Home action
            }
            
            ActionBarButton(
                icon: "arrow.triangle.2.circlepath",
                isSelected: false,
                color: CompactTheme.subtleGray
            ) {
                // Retry action
            }
            
            ActionBarButton(
                icon: "arrow.clockwise.circle",
                isSelected: false,
                color: CompactTheme.subtleGray
            ) {
                // Refresh action
            }
            
            Spacer()
            
            // Share button
            ActionBarButton(
                icon: "paperplane.fill",
                isSelected: true,
                color: CompactTheme.primaryBlue
            ) {
                // Share action
            }
        }
        .padding(.horizontal, 8)
    }
}

struct ActionBarButton: View {
    let icon: String
    let isSelected: Bool
    let color: Color
    let action: () -> Void
    
    @State private var buttonScale = 1.0
    
    var body: some View {
        Button(action: {
            // Haptic feedback
            let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
            impactFeedback.impactOccurred()
            
            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                buttonScale = 0.95
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                    buttonScale = 1.0
                }
            }
            
            action()
        }) {
            Image(systemName: icon)
                .foregroundColor(isSelected ? .white : color)
                .font(.system(size: 18, weight: .medium))
                .frame(width: 44, height: 44)
                .background(
                    Circle()
                        .fill(
                            isSelected
                            ? AnyShapeStyle(
                                LinearGradient(
                                    colors: [color, color.opacity(0.8)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                              )
                            : AnyShapeStyle(Color.white.opacity(0.05))
                        )
                        .overlay(
                            Circle()
                                .stroke(
                                    isSelected ? Color.clear : Color.white.opacity(0.1),
                                    lineWidth: 1
                                )
                        )
                )
        }
        .scaleEffect(buttonScale)
        .shadow(
            color: isSelected ? color.opacity(0.3) : .clear,
            radius: isSelected ? 8 : 0,
            y: isSelected ? 4 : 0
        )
    }
}

// MARK: - Preview
#Preview {
    VStack {
        Spacer()
        CompactCompressionView()
    }
    .background(Color.black.ignoresSafeArea())
    .preferredColorScheme(.dark)
}
```
