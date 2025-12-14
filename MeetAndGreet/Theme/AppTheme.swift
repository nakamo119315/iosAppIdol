import SwiftUI

/// App theme configuration
/// アプリのテーマ設定
struct AppTheme: Equatable {
    let name: String
    let primaryColor: Color
    let secondaryColor: Color
    let accentColor: Color
    let backgroundColor: Color
    let surfaceColor: Color
    let textPrimary: Color
    let textSecondary: Color
    let cornerRadius: CGFloat
    let shadowRadius: CGFloat
    let shadowOpacity: Double
    let borderWidth: CGFloat

    /// Apple-style theme (clean and minimal)
    static let apple = AppTheme(
        name: "Apple",
        primaryColor: .blue,
        secondaryColor: .gray,
        accentColor: .blue,
        backgroundColor: Color(.systemBackground),
        surfaceColor: Color(.secondarySystemBackground),
        textPrimary: Color(.label),
        textSecondary: Color(.secondaryLabel),
        cornerRadius: 12,
        shadowRadius: 2,
        shadowOpacity: 0.1,
        borderWidth: 0
    )

    /// Game-style theme (colorful and playful)
    static let game = AppTheme(
        name: "Game",
        primaryColor: Color(red: 1.0, green: 0.4, blue: 0.6),
        secondaryColor: Color(red: 0.6, green: 0.4, blue: 1.0),
        accentColor: Color(red: 1.0, green: 0.6, blue: 0.8),
        backgroundColor: Color(red: 0.98, green: 0.95, blue: 1.0),
        surfaceColor: .white,
        textPrimary: Color(red: 0.2, green: 0.1, blue: 0.3),
        textSecondary: Color(red: 0.5, green: 0.4, blue: 0.6),
        cornerRadius: 20,
        shadowRadius: 8,
        shadowOpacity: 0.2,
        borderWidth: 2
    )
}

// MARK: - Environment Key
private struct AppThemeKey: EnvironmentKey {
    static let defaultValue: AppTheme = .apple
}

extension EnvironmentValues {
    var appTheme: AppTheme {
        get { self[AppThemeKey.self] }
        set { self[AppThemeKey.self] = newValue }
    }
}

// MARK: - Theme-aware View Modifiers

/// Card style modifier that adapts to the current theme
struct ThemedCardModifier: ViewModifier {
    @Environment(\.appTheme) private var theme

    func body(content: Content) -> some View {
        content
            .background(theme.surfaceColor)
            .cornerRadius(theme.cornerRadius)
            .shadow(
                color: .black.opacity(theme.shadowOpacity),
                radius: theme.shadowRadius,
                x: 0,
                y: theme.shadowRadius / 2
            )
            .overlay(
                RoundedRectangle(cornerRadius: theme.cornerRadius)
                    .stroke(
                        theme.borderWidth > 0 ? theme.primaryColor.opacity(0.3) : .clear,
                        lineWidth: theme.borderWidth
                    )
            )
    }
}

/// Primary button style that adapts to the current theme
struct ThemedButtonModifier: ViewModifier {
    @Environment(\.appTheme) private var theme
    let isSecondary: Bool

    init(isSecondary: Bool = false) {
        self.isSecondary = isSecondary
    }

    func body(content: Content) -> some View {
        content
            .font(.headline)
            .foregroundColor(isSecondary ? theme.primaryColor : .white)
            .padding(.horizontal, 24)
            .padding(.vertical, 12)
            .background(isSecondary ? theme.surfaceColor : theme.primaryColor)
            .cornerRadius(theme.cornerRadius)
            .overlay(
                RoundedRectangle(cornerRadius: theme.cornerRadius)
                    .stroke(
                        theme.primaryColor,
                        lineWidth: isSecondary ? 2 : 0
                    )
            )
            .shadow(
                color: .black.opacity(theme.shadowOpacity * 0.5),
                radius: theme.shadowRadius * 0.5,
                x: 0,
                y: 2
            )
    }
}

/// Chat bubble modifier with animation
struct ChatBubbleModifier: ViewModifier {
    @Environment(\.appTheme) private var theme
    let isUser: Bool

    func body(content: Content) -> some View {
        content
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(isUser ? theme.primaryColor : theme.surfaceColor)
            .foregroundColor(isUser ? .white : theme.textPrimary)
            .cornerRadius(theme.cornerRadius)
            .overlay(
                RoundedRectangle(cornerRadius: theme.cornerRadius)
                    .stroke(
                        isUser ? .clear : theme.primaryColor.opacity(0.2),
                        lineWidth: theme.borderWidth
                    )
            )
            .shadow(
                color: .black.opacity(theme.shadowOpacity * 0.3),
                radius: 2,
                x: 0,
                y: 1
            )
    }
}

// MARK: - View Extensions
extension View {
    /// Applies themed card styling
    func themedCard() -> some View {
        modifier(ThemedCardModifier())
    }

    /// Applies themed button styling
    func themedButton(isSecondary: Bool = false) -> some View {
        modifier(ThemedButtonModifier(isSecondary: isSecondary))
    }

    /// Applies chat bubble styling
    func chatBubble(isUser: Bool) -> some View {
        modifier(ChatBubbleModifier(isUser: isUser))
    }

    /// Fade in transition for chat messages
    func chatMessageTransition() -> some View {
        self.transition(
            .asymmetric(
                insertion: .opacity.combined(with: .scale(scale: 0.95)).combined(with: .offset(y: 10)),
                removal: .opacity
            )
        )
    }
}

// MARK: - Color Extensions
extension Color {
    /// Category color based on expense category
    static func forExpenseCategory(_ category: ExpenseCategory) -> Color {
        switch category {
        case .ticket: return .pink
        case .transportation: return .blue
        case .accommodation: return .purple
        case .goods: return .orange
        case .food: return .green
        case .gift: return .red
        case .other: return .gray
        }
    }

    /// Category color based on event category
    static func forEventCategory(_ category: EventCategory) -> Color {
        switch category {
        case .live: return .pink
        case .meetAndGreet: return .purple
        case .release: return .blue
        case .festival: return .orange
        case .fanMeeting: return .green
        case .other: return .gray
        }
    }
}
