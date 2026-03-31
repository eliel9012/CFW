import SwiftUI

// MARK: - AppState
// Centralises reading progress, favourites and study notes.

final class AppState: ObservableObject {

    // MARK: - Reading progress

    @Published var lastReadChapterID: Int {
        didSet { UserDefaults.standard.set(lastReadChapterID, forKey: "cfw_lastReadChapterID") }
    }

    // MARK: - Favourites (chapter IDs)

    @Published var favouriteChapterIDs: Set<Int> = [] {
        didSet { persistFavourites() }
    }

    // MARK: - Study notes

    @Published var studyNotes: [StudyNote] = [] {
        didSet { persistStudyNotes() }
    }

    // MARK: - Init

    init() {
        lastReadChapterID = UserDefaults.standard.integer(forKey: "cfw_lastReadChapterID")
        favouriteChapterIDs = loadFavourites()
        studyNotes = loadStudyNotes()
    }

    // MARK: - Favourites API

    func toggleFavourite(chapterID: Int) {
        if favouriteChapterIDs.contains(chapterID) {
            favouriteChapterIDs.remove(chapterID)
        } else {
            favouriteChapterIDs.insert(chapterID)
        }
    }

    func isFavourite(chapterID: Int) -> Bool {
        favouriteChapterIDs.contains(chapterID)
    }

    // MARK: - Study Notes API

    func addNote(_ note: StudyNote) {
        studyNotes.removeAll { $0.id == note.id }
        studyNotes.append(note)
    }

    func removeNote(id: String) {
        studyNotes.removeAll { $0.id == id }
    }

    // MARK: - Persistence

    private let favKey = "cfw_favourites"
    private let notesKey = "cfw_studyNotes"

    private func loadFavourites() -> Set<Int> {
        guard let data = UserDefaults.standard.data(forKey: favKey),
              let ids = try? JSONDecoder().decode(Set<Int>.self, from: data) else { return [] }
        return ids
    }

    private func persistFavourites() {
        guard let data = try? JSONEncoder().encode(favouriteChapterIDs) else { return }
        UserDefaults.standard.set(data, forKey: favKey)
    }

    private func loadStudyNotes() -> [StudyNote] {
        guard let data = UserDefaults.standard.data(forKey: notesKey),
              let notes = try? JSONDecoder().decode([StudyNote].self, from: data) else { return [] }
        return notes
    }

    private func persistStudyNotes() {
        guard let data = try? JSONEncoder().encode(studyNotes) else { return }
        UserDefaults.standard.set(data, forKey: notesKey)
    }
}
