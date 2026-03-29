import Foundation
import SwiftUI

// MARK: - ReadingSettings
// Persists user preferences for font size and colour scheme.

final class ReadingSettings: ObservableObject {

    @Published var fontSize: Double {
        didSet { UserDefaults.standard.set(fontSize, forKey: "cfw_fontSize") }
    }

    /// "system" | "light" | "dark"
    @Published var colorSchemeRaw: String {
        didSet { UserDefaults.standard.set(colorSchemeRaw, forKey: "cfw_colorScheme") }
    }

    init() {
        let stored = UserDefaults.standard.double(forKey: "cfw_fontSize")
        fontSize = stored > 0 ? stored : 17.0
        colorSchemeRaw = UserDefaults.standard.string(forKey: "cfw_colorScheme") ?? "system"
    }

    var preferredColorScheme: ColorScheme? {
        switch colorSchemeRaw {
        case "light": return .light
        case "dark":  return .dark
        default:      return nil
        }
    }

    func reset() {
        fontSize = 17.0
        colorSchemeRaw = "system"
    }
}
