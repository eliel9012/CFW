import Foundation

// MARK: - Chapter

struct Chapter: Identifiable, Codable, Equatable, Hashable {
    let id: Int
    let romanNumeral: String
    let title: String
    let sections: [Section]

    var displayTitle: String { "Capítulo \(romanNumeral)" }
    var fullTitle: String { "\(romanNumeral) — \(title)" }

    /// All text content joined for full-text search
    var allText: String {
        sections.map { $0.text + " " + $0.references }.joined(separator: " ")
    }
}
