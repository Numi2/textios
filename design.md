# Co-Parent App Design System

## Design Philosophy

Our design system embraces Apple's modern glass morphism aesthetic while maintaining clarity and usability. We focus on creating a warm, trustworthy, and professional experience that reflects the sensitive nature of co-parenting.

### Core Principles

1. **Clarity & Trust**
   - Clean, uncluttered interfaces
   - Clear visual hierarchy
   - Consistent, predictable interactions
   - Professional and polished appearance

2. **Accessibility & Inclusivity**
   - High contrast ratios
   - Clear typography
   - Adequate touch targets
   - VoiceOver support
   - Dynamic Type support

3. **Emotional Connection**
   - Warm, inviting color palette
   - Smooth, natural animations
   - Thoughtful micro-interactions
   - Supportive, encouraging copy

## Visual Design

### Glass Morphism

We use glass morphism to create depth and hierarchy while maintaining readability:

```swift
// Background glass effect
.background(.ultraThinMaterial)

// Card glass effect
.background(
    RoundedRectangle(cornerRadius: 20)
        .fill(Color.white.opacity(0.1))
        .background(.ultraThinMaterial)
)
```

### Color System

```swift
enum Colors {
    static let primary = Color.blue      // Trust, stability
    static let secondary = Color.gray    // Neutral, professional
    static let success = Color.green     // Positive actions
    static let error = Color.red         // Errors, warnings
    static let warning = Color.orange    // Caution, attention
}
```

### Typography

We use the rounded system font for a friendly, approachable feel:

```swift
enum Typography {
    static let largeTitle = Font.system(.largeTitle, design: .rounded).weight(.bold)
    static let title = Font.system(.title, design: .rounded).weight(.semibold)
    static let body = Font.system(.body, design: .rounded)
    // ...
}
```

### Layout

Consistent spacing and dimensions create rhythm and harmony:

```swift
enum Layout {
    static let spacing: CGFloat = 16
    static let cornerRadius: CGFloat = 20
    static let buttonHeight: CGFloat = 44
    static let iconSize: CGFloat = 24
    static let padding: CGFloat = 16
}
```

## Components

### Glass Cards

Used for content containers and profile sections:

```swift
struct GlassCardView<Content: View>: View {
    let content: Content
    
    var body: some View {
        content
            .padding(DesignSystem.Layout.padding)
            .glassCard()
    }
}
```

### Glass Buttons

Primary and secondary actions:

```swift
struct GlassButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding(.horizontal, DesignSystem.Layout.padding)
            .frame(height: DesignSystem.Layout.buttonHeight)
            .background(
                RoundedRectangle(cornerRadius: DesignSystem.Layout.cornerRadius)
                    .fill(configuration.isPressed ? 
                          Color.white.opacity(0.2) : 
                          Color.white.opacity(0.1))
                    .background(.ultraThinMaterial)
            )
            .scaleEffect(configuration.isPressed ? 0.98 : 1)
            .animation(DesignSystem.Animation.spring, value: configuration.isPressed)
    }
}
```

### Icon Buttons

For secondary actions and navigation:

```swift
struct GlassIconButton: View {
    let systemName: String
    let action: () -> Void
    let color: Color
    
    var body: some View {
        Button(action: action) {
            Image(systemName: systemName)
                .font(.system(size: DesignSystem.Layout.iconSize, weight: .medium))
                .foregroundColor(color)
                .frame(width: DesignSystem.Layout.buttonHeight, 
                       height: DesignSystem.Layout.buttonHeight)
                .background(color.opacity(0.1))
                .clipShape(Circle())
        }
    }
}
```

## Screen-Specific Design

### Onboarding

- Full-screen glass background
- Large, friendly illustrations
- Clear progress indicators
- Encouraging, supportive copy
- Smooth page transitions

### Profile

- Glass cards for each section
- Prominent profile image
- Clear information hierarchy
- Easy-to-scan sections
- Subtle animations for interactions

### Matching

- Elegant match cards with glass effect
- Clear action buttons
- Smooth card transitions
- Empty state with helpful guidance
- Filter interface with glass panels

### Chat

- Clean message bubbles
- Subtle message status indicators
- Easy-to-use input bar
- Smooth scrolling and loading
- Clear visual feedback for actions

## Animations

We use subtle, purposeful animations to enhance the user experience:

```swift
enum Animation {
    static let spring = SwiftUI.Animation.spring(response: 0.3, dampingFraction: 0.7)
    static let easeOut = SwiftUI.Animation.easeOut(duration: 0.2)
    static let easeIn = SwiftUI.Animation.easeIn(duration: 0.2)
}
```

## Dark Mode Support

Our glass effects adapt to both light and dark modes:

```swift
// Light mode
Color.white.opacity(0.1)
    .background(.ultraThinMaterial)

// Dark mode
Color.black.opacity(0.1)
    .background(.ultraThinMaterial)
```

## Accessibility

- Minimum touch target size: 44x44 points
- Clear visual hierarchy
- VoiceOver labels for all interactive elements
- Dynamic Type support
- High contrast ratios
- Clear focus states

## Implementation Guidelines

1. **Consistency**
   - Use design system components
   - Follow spacing guidelines
   - Maintain typography hierarchy
   - Use standard animations

2. **Performance**
   - Optimize glass effects
   - Use lazy loading
   - Minimize view updates
   - Cache images and assets

3. **Maintenance**
   - Document new components
   - Update design system
   - Test across devices
   - Verify accessibility

## Future Considerations

1. **Customization**
   - User theme preferences
   - Custom color schemes
   - Alternative typography options

2. **Enhancements**
   - Advanced animations
   - Haptic feedback
   - Sound effects
   - Gesture interactions

3. **Platform Adaptation**
   - iPad optimization
   - macOS support
   - Watch companion app
   - Widget support 