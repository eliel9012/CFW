import SwiftUI

// MARK: - SearchView

struct SearchView: View {

    @EnvironmentObject private var contentService: ContentService
    @Binding var selectedChapterID: Int?

    @State private var query = ""
    @FocusState private var focused: Bool

    // MARK: - Search Results

    private struct SearchResult: Identifiable {
        let id: String
        let chapter: Chapter
        let section: Section?       // nil → chapter-level match
        let snippet: String
    }

    private var results: [SearchResult] {
        guard query.count >= 2 else { return [] }
        let q = query.lowercased()
        var found: [SearchResult] = []

        for chapter in contentService.chapters {
            // Match chapter title
            if chapter.title.lowercased().contains(q) ||
               chapter.romanNumeral.lowercased().contains(q) {
                found.append(SearchResult(
                    id: "ch-\(chapter.id)",
                    chapter: chapter,
                    section: nil,
                    snippet: chapter.title
                ))
            }
            // Match section text / references
            for section in chapter.sections {
                let combined = section.text + " " + section.references
                if combined.lowercased().contains(q) {
                    let snippet = extractSnippet(from: section.text, query: q)
                    found.append(SearchResult(
                        id: section.id,
                        chapter: chapter,
                        section: section,
                        snippet: snippet
                    ))
                }
            }
        }
        return found
    }

    var body: some View {
        SwiftUI.List {
            if query.count < 2 {
                searchHint
            } else if results.isEmpty {
                emptyState
            } else {
                SwiftUI.Section {
                    ForEach(results) { result in
                        resultRow(result)
                            .listRowBackground(AppTheme.surface)
                            .listRowSeparatorTint(AppTheme.outline.opacity(0.15))
                    }
                } header: {
                    Text("\(results.count) resultado(s)")
                        .font(AppTheme.uiLabel(size: 12, weight: .medium))
                        .foregroundStyle(AppTheme.outline)
                        .textCase(.none)
                }
            }
        }
        .listStyle(.plain)
        .background(AppTheme.surface.ignoresSafeArea())
        .searchable(text: $query, prompt: "Buscar na Confissão…")
        .navigationTitle("Busca")
    }

    // MARK: - Sub-views

    private var searchHint: some View {
        VStack(spacing: 16) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 48, weight: .ultraLight))
                .foregroundStyle(AppTheme.primary.opacity(0.2))
            Text("Digite ao menos 2 caracteres")
                .font(AppTheme.uiLabel(size: 15))
                .foregroundStyle(AppTheme.outline)
        }
        .frame(maxWidth: .infinity)
        .padding(40)
        .listRowBackground(Color.clear)
        .listRowSeparator(.hidden)
    }

    private var emptyState: some View {
        VStack(spacing: 12) {
            Image(systemName: "doc.text.magnifyingglass")
                .font(.system(size: 40, weight: .ultraLight))
                .foregroundStyle(AppTheme.primary.opacity(0.2))
            Text("Nenhum resultado para \u{201C}\(query)\u{201D}")
                .font(AppTheme.uiLabel(size: 15))
                .foregroundStyle(AppTheme.outline)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(40)
        .listRowBackground(Color.clear)
        .listRowSeparator(.hidden)
    }

    private func resultRow(_ result: SearchResult) -> some View {
        NavigationLink(destination: destinationView(for: result)) {
            VStack(alignment: .leading, spacing: 5) {
                HStack(spacing: 6) {
                    Text(result.chapter.displayTitle)
                        .font(AppTheme.uiLabel(size: 11, weight: .semibold))
                        .tracking(0.8)
                        .textCase(.uppercase)
                        .foregroundStyle(AppTheme.secondary)

                    if let section = result.section, section.hasNumber {
                        Text("· §\(section.romanNumeral)")
                            .font(AppTheme.uiLabel(size: 11))
                            .foregroundStyle(AppTheme.outline)
                    }
                }

                Text(result.chapter.title)
                    .font(AppTheme.readingBody(size: 14))
                    .foregroundStyle(AppTheme.primary)
                    .lineLimit(1)

                Text(highlightedSnippet(result.snippet, query: query))
                    .font(AppTheme.uiLabel(size: 13))
                    .foregroundStyle(AppTheme.outline.opacity(0.85))
                    .lineLimit(2)
            }
            .padding(.vertical, 4)
        }
    }

    private func destinationView(for result: SearchResult) -> some View {
        ReadingView(chapter: result.chapter)
            .onAppear { selectedChapterID = result.chapter.id }
    }

    // MARK: - Text helpers

    private func extractSnippet(from text: String, query: String, radius: Int = 60) -> String {
        let lower = text.lowercased()
        guard let range = lower.range(of: query) else { return String(text.prefix(120)) }
        let start = text.index(range.lowerBound, offsetBy: -min(radius, text.distance(from: text.startIndex, to: range.lowerBound)), limitedBy: text.startIndex) ?? text.startIndex
        let end   = text.index(range.upperBound, offsetBy: min(radius, text.distance(from: range.upperBound, to: text.endIndex)), limitedBy: text.endIndex) ?? text.endIndex
        let snippet = String(text[start..<end])
        return (start > text.startIndex ? "…" : "") + snippet + (end < text.endIndex ? "…" : "")
    }

    private func highlightedSnippet(_ text: String, query: String) -> AttributedString {
        var attributed = AttributedString(text)
        let lower = text.lowercased()
        let qLower = query.lowercased()
        var searchStart = lower.startIndex
        while let range = lower.range(of: qLower, range: searchStart..<lower.endIndex) {
            if let attrRange = Range(range, in: attributed) {
                attributed[attrRange].foregroundColor = AppTheme.secondary
                attributed[attrRange].font = .system(size: 13, weight: .bold)
            }
            searchStart = range.upperBound
        }
        return attributed
    }
}

#Preview {
    NavigationStack {
        SearchView(selectedChapterID: .constant(nil))
            .environmentObject(ContentService())
    }
}
