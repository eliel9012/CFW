import SwiftUI

// MARK: - StudyView
// Shows favourite chapters and saved study notes.

struct StudyView: View {

    @EnvironmentObject private var contentService: ContentService
    @EnvironmentObject private var appState: AppState
    @Binding var selectedChapterID: Int?

    @State private var selectedSegment: Segment = .favourites

    enum Segment: String, CaseIterable {
        case favourites = "Favoritos"
        case notes      = "Notas"
    }

    var body: some View {
        VStack(spacing: 0) {
            // Segment control
            Picker("", selection: $selectedSegment) {
                ForEach(Segment.allCases, id: \.self) { seg in
                    Text(seg.rawValue).tag(seg)
                }
            }
            .pickerStyle(.segmented)
            .padding(.horizontal, AppTheme.pagePadding)
            .padding(.vertical, 12)
            .background(Color(.systemBackground))

            if selectedSegment == .favourites {
                favouritesContent
            } else {
                notesContent
            }
        }
        .background(AppTheme.surface.ignoresSafeArea())
        .navigationTitle("Meu Estudo")
    }

    // MARK: - Favourites

    private var favouriteChapters: [Chapter] {
        contentService.chapters.filter { appState.isFavourite(chapterID: $0.id) }
    }

    private var favouritesContent: some View {
        Group {
            if favouriteChapters.isEmpty {
                emptyState(
                    icon: "star",
                    title: "Nenhum favorito ainda",
                    message: "Adicione capítulos aos favoritos durante a leitura tocando em ★"
                )
            } else {
                List {
                    ForEach(favouriteChapters) { chapter in
                        NavigationLink(destination: ReadingView(chapter: chapter)) {
                            favouriteRow(chapter)
                        }
                        .listRowBackground(AppTheme.surface)
                        .listRowSeparatorTint(AppTheme.outline.opacity(0.15))
                    }
                    .onDelete { indexSet in
                        indexSet.map { favouriteChapters[$0].id }.forEach {
                            appState.toggleFavourite(chapterID: $0)
                        }
                    }
                }
                .listStyle(.plain)
            }
        }
    }

    private func favouriteRow(_ chapter: Chapter) -> some View {
        HStack(spacing: 14) {
            Image(systemName: "star.fill")
                .font(.system(size: 14))
                .foregroundStyle(AppTheme.secondary)
                .frame(width: 28)

            VStack(alignment: .leading, spacing: 3) {
                Text(chapter.title)
                    .font(AppTheme.readingBody(size: 16))
                    .foregroundStyle(AppTheme.primary)
                    .lineLimit(2)

                Text(chapter.displayTitle)
                    .font(AppTheme.uiLabel(size: 12))
                    .foregroundStyle(AppTheme.outline)
            }
        }
        .padding(.vertical, 4)
    }

    // MARK: - Notes

    private var notesContent: some View {
        Group {
            if appState.studyNotes.isEmpty {
                emptyState(
                    icon: "bookmark",
                    title: "Nenhuma nota ainda",
                    message: "Salve seções para estudo usando o menu ··· em cada parágrafo"
                )
            } else {
                List {
                    ForEach(appState.studyNotes.sorted { $0.createdAt > $1.createdAt }) { note in
                        noteRow(note)
                            .listRowBackground(AppTheme.surface)
                            .listRowSeparatorTint(AppTheme.outline.opacity(0.15))
                    }
                    .onDelete { indexSet in
                        let sorted = appState.studyNotes.sorted { $0.createdAt > $1.createdAt }
                        indexSet.map { sorted[$0].id }.forEach { appState.removeNote(id: $0) }
                    }
                }
                .listStyle(.plain)
            }
        }
    }

    private func noteRow(_ note: StudyNote) -> some View {
        NavigationLink {
            if let chapter = contentService.chapter(id: note.chapterID) {
                ReadingView(chapter: chapter)
            }
        } label: {
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text(note.chapterTitle)
                        .font(AppTheme.uiLabel(size: 11, weight: .semibold))
                        .tracking(0.6)
                        .textCase(.uppercase)
                        .foregroundStyle(AppTheme.secondary)

                    Spacer()

                    Text(note.sectionNumber)
                        .font(AppTheme.uiLabel(size: 12))
                        .foregroundStyle(AppTheme.outline)
                }

                Text(note.excerpt)
                    .font(AppTheme.readingBody(size: 14))
                    .foregroundStyle(AppTheme.primary)
                    .lineLimit(3)
                    .italic()

                Text(note.createdAt, style: .date)
                    .font(AppTheme.uiLabel(size: 11))
                    .foregroundStyle(AppTheme.outline)
            }
            .padding(.vertical, 4)
        }
    }

    // MARK: - Empty State

    private func emptyState(icon: String, title: String, message: String) -> some View {
        VStack(spacing: 20) {
            Spacer()
            Image(systemName: icon)
                .font(.system(size: 56, weight: .ultraLight))
                .foregroundStyle(AppTheme.primary.opacity(0.2))

            VStack(spacing: 8) {
                Text(title)
                    .font(AppTheme.readingHeadline(size: 18))
                    .foregroundStyle(AppTheme.primary)

                Text(message)
                    .font(AppTheme.uiLabel(size: 14))
                    .foregroundStyle(AppTheme.outline)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
            }
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview {
    NavigationStack {
        StudyView(selectedChapterID: .constant(nil))
            .environmentObject(ContentService())
            .environmentObject(AppState())
    }
}
