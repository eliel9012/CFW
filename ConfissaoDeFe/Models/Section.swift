import Foundation

// MARK: - Section

struct Section: Identifiable, Codable, Equatable, Hashable {
    /// Unique id in format "chN_sM"
    let id: String
    let romanNumeral: String
    let text: String
    /// Bible references that follow the section body
    let references: String

    var hasReferences: Bool { !references.isEmpty }
    var displayNumber: String { "§\(romanNumeral)" }
}
