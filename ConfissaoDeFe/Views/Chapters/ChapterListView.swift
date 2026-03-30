import SwiftUI

// MARK: - ChapterListView

struct ChapterListView: View {

    @EnvironmentObject private var contentService: ContentService
    @EnvironmentObject private var appState: AppState
    @Binding var selectedChapterID: Int?

    @State private var searchText = ""

    private var filtered: [Chapter] {
        if searchText.isEmpty { return contentService.chapters }
        let q = searchText.lowercased()
        return contentService.chapters.filter {
            $0.title.lowercased().contains(q) ||
            $0.romanNumeral.lowercased().contains(q)
        }
    }

    var body: some View {
        Group {
            if UIDevice.current.userInterfaceIdiom == .pad {
                iPadChapterList
            } else {
                iPhoneChapterList
            }
        }
        .searchable(text: $searchText, prompt: "Buscar capítulo")
        .navigationTitle("Capítulos")
        .background(AppTheme.surface.ignoresSafeArea())
    }

    private var iPhoneChapterList: some View {
        List(filtered) { chapter in
            NavigationLink(value: chapter.id) {
                row(for: chapter)
            }
        }
        .listStyle(.plain)
    }

    private var iPadChapterList: some View {
        List(filtered, selection: $selectedChapterID) { chapter in
            row(for: chapter)
                .tag(chapter.id)
                .contentShape(Rectangle())
        }
        .listStyle(.plain)
    }

    @ViewBuilder
    private func row(for chapter: Chapter) -> some View {
        ChapterRowView(chapter: chapter)
            .listRowBackground(AppTheme.surface)
            .listRowSeparatorTint(AppTheme.outline.opacity(0.15))
    }
}

// MARK: - Chapter Row

private struct ChapterRowView: View {

    let chapter: Chapter
    @EnvironmentObject private var appState: AppState

    var body: some View {
        HStack(spacing: 16) {
            // Roman numeral badge
            if chapter.hasNumeral {
                Text(chapter.romanNumeral)
                    .font(.system(size: 12, weight: .bold, design: .serif))
                    .foregroundStyle(.white)
                    .frame(width: 40, height: 40)
                    .background(AppTheme.primaryContainer)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                    .minimumScaleFactor(0.6)
            } else {
                Image(systemName: "doc.text")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(.white)
                    .frame(width: 40, height: 40)
                    .background(AppTheme.primaryContainer)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
            }

            VStack(alignment: .leading, spacing: 3) {
                Text(chapter.title)
                    .font(AppTheme.readingBody(size: 16))
                    .foregroundStyle(AppTheme.primary)
                    .lineLimit(2)

                Text("\(chapter.sections.count) seções")
                    .font(AppTheme.uiLabel(size: 12))
                    .foregroundStyle(AppTheme.outline)
            }

            Spacer(minLength: 0)

            if appState.isFavourite(chapterID: chapter.id) {
                Image(systemName: "star.fill")
                    .font(.system(size: 13))
                    .foregroundStyle(AppTheme.secondary)
                    .accessibilityLabel("Favoritado")
            }
        }
        .padding(.vertical, 4)
        .accessibilityElement(children: .combine)
        .accessibilityLabel(chapter.hasNumeral
            ? "Capítulo \(chapter.romanNumeral), \(chapter.title)"
            : chapter.title)
    }
}

#Preview {
    NavigationStack {
        ChapterListView(selectedChapterID: .constant(nil))
            .environmentObject(ContentService())
            .environmentObject(AppState())
    }
}
