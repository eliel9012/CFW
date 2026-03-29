import Foundation

// MARK: - StudyNote

struct StudyNote: Identifiable, Codable, Equatable {
    let id: String          // UUID string
    let chapterID: Int
    let chapterTitle: String
    let sectionID: String
    let sectionNumber: String
    let excerpt: String     // First ~120 chars of section text
    let createdAt: Date

    init(chapterID: Int, chapterTitle: String, sectionID: String,
         sectionNumber: String, excerpt: String) {
        self.id = UUID().uuidString
        self.chapterID = chapterID
        self.chapterTitle = chapterTitle
        self.sectionID = sectionID
        self.sectionNumber = sectionNumber
        let trimmed = excerpt.trimmingCharacters(in: .whitespacesAndNewlines)
        self.excerpt = trimmed.count > 120 ? String(trimmed.prefix(120)) + "…" : trimmed
        self.createdAt = Date()
    }
}
