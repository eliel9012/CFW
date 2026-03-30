import Foundation

// MARK: - Chapter

struct Chapter: Identifiable, Codable, Equatable, Hashable {
    let id: Int
    let romanNumeral: String
    let title: String
    let sections: [Section]

    var hasNumeral: Bool {
        !romanNumeral.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    var displayTitle: String {
        hasNumeral ? "Capítulo \(romanNumeral)" : title
    }

    var fullTitle: String {
        hasNumeral ? "\(romanNumeral) — \(title)" : title
    }

    /// All text content joined for full-text search
    var allText: String {
        sections.map { $0.text + " " + $0.references }.joined(separator: " ")
    }
}
