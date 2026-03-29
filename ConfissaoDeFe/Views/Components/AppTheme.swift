import SwiftUI

// MARK: - AppTheme
// Design tokens derived from the stitch reference files.
// Primary: deep navy #031632 | Secondary: golden amber #775a19
// Surface: warm cream #fbf9f4

enum AppTheme {

    // MARK: - Semantic Colours

    static let primary          = Color("CFW_Primary")        // #031632
    static let secondary        = Color("CFW_Secondary")      // #775a19
    static let surface          = Color("CFW_Surface")        // #fbf9f4
    static let surfaceContainer = Color("CFW_SurfaceContainer") // #f0eee9
    static let surfaceHigh      = Color("CFW_SurfaceHigh")    // #eae8e3
    static let primaryContainer = Color("CFW_PrimaryContainer") // #1a2b48
    static let secondaryContainer = Color("CFW_SecondaryContainer") // #fed488
    static let onPrimaryContainer = Color("CFW_OnPrimaryContainer") // #8293b5
    static let outline          = Color("CFW_Outline")        // #75777e

    // MARK: - Typography

    /// Serif font for body reading text (Georgia maps well to the Newsreader feel)
    static func readingBody(size: CGFloat) -> Font {
        .custom("Georgia", size: size, relativeTo: .body)
    }

    /// Serif bold for headings
    static func readingHeadline(size: CGFloat) -> Font {
        .custom("Georgia", size: size, relativeTo: .title3)
    }

    /// System sans-serif for UI chrome
    static func uiLabel(size: CGFloat, weight: Font.Weight = .regular) -> Font {
        .system(size: size, weight: weight, design: .default)
    }

    // MARK: - Spacing

    static let pagePadding: CGFloat = 20
    static let cardRadius: CGFloat  = 14
    static let lineSpacing: CGFloat = 7
}

// MARK: - Colour Extension

extension Color {
    init(hex: String) {
        let h = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: h).scanHexInt64(&int)
        let r = Double((int >> 16) & 0xFF) / 255
        let g = Double((int >> 8)  & 0xFF) / 255
        let b = Double(int         & 0xFF) / 255
        self.init(red: r, green: g, blue: b)
    }
}

// MARK: - View Modifiers

struct CardStyle: ViewModifier {
    @Environment(\.colorScheme) private var scheme
    func body(content: Content) -> some View {
        content
            .background(scheme == .dark ? Color(.systemGray6) : AppTheme.surfaceContainer)
            .clipShape(RoundedRectangle(cornerRadius: AppTheme.cardRadius))
    }
}

struct SectionDivider: View {
    var body: some View {
        Rectangle()
            .fill(AppTheme.outline.opacity(0.2))
            .frame(height: 0.5)
    }
}

extension View {
    func cardStyle() -> some View { modifier(CardStyle()) }
}

// MARK: - AppTab
// Shared navigation tab enum (named AppTab to avoid clash with SwiftUI.Tab in iOS 18+).

enum AppTab: String, CaseIterable, Hashable {
    case home      = "home"
    case chapters  = "chapters"
    case search    = "search"
    case study     = "study"
    case settings  = "settings"

    var label: String {
        switch self {
        case .home:     return "Início"
        case .chapters: return "Capítulos"
        case .search:   return "Busca"
        case .study:    return "Meu Estudo"
        case .settings: return "Ajustes"
        }
    }

    var icon: String {
        switch self {
        case .home:     return "house"
        case .chapters: return "list.bullet"
        case .search:   return "magnifyingglass"
        case .study:    return "bookmark"
        case .settings: return "gearshape"
        }
    }
}
