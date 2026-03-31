import SwiftUI

// MARK: - ReadingView
// Main reading experience for a single chapter.

struct ReadingView: View {

    let chapter: Chapter

    @EnvironmentObject private var appState: AppState
    @EnvironmentObject private var settings: ReadingSettings
    @Environment(\.dismiss) private var dismiss

    @State private var showFontControls = false
    @State private var navigateToChapterID: Int?

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                chapterHeader
                    .padding(.bottom, 28)

                ForEach(Array(chapter.sections.enumerated()), id: \.element.id) { index, section in
                    SectionRowView(section: section, chapter: chapter, fontSize: settings.fontSize)

                    if index < chapter.sections.count - 1 {
                        SectionDivider()
                            .padding(.vertical, 16)
                    }
                }
            }
            .padding(.horizontal, AppTheme.pagePadding)
            .padding(.top, 20)
            .padding(.bottom, 60)
        }
        .background(Color(.systemBackground).ignoresSafeArea())
        .navigationTitle(chapter.displayTitle)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar { toolbarContent }
        .navigationDestination(item: $navigateToChapterID) { id in
            if let target = contentService.chapter(id: id) {
                ReadingView(chapter: target)
            }
        }
        .onAppear {
            appState.lastReadChapterID = chapter.id
        }
    }

    // MARK: - Chapter Header

    private var chapterHeader: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(chapter.displayTitle)
                .font(AppTheme.uiLabel(size: 13, weight: .semibold))
                .tracking(1.2)
                .textCase(.uppercase)
                .foregroundStyle(AppTheme.secondary)

            Text(chapter.title)
                .font(AppTheme.readingHeadline(size: 28))
                .foregroundStyle(AppTheme.primary)
                .lineSpacing(4)

            SectionDivider()
                .padding(.top, 8)
        }
    }

    // MARK: - Toolbar

    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        ToolbarItemGroup(placement: .topBarTrailing) {
            // Font size toggle
            Button {
                withAnimation(.spring(response: 0.3)) {
                    showFontControls.toggle()
                }
            } label: {
                Image(systemName: "textformat.size")
                    .accessibilityLabel("Tamanho da fonte")
            }
            .foregroundStyle(AppTheme.primary)
            .popover(isPresented: $showFontControls) {
                fontControlsPopover
            }

            // Chapter navigation
            Menu {
                chapterNavigationMenu
            } label: {
                Image(systemName: "list.number")
                    .foregroundStyle(AppTheme.primary)
            }
            .accessibilityLabel("Navegar capítulos")

            // Favourite toggle
            Button {
                appState.toggleFavourite(chapterID: chapter.id)
            } label: {
                Image(systemName: appState.isFavourite(chapterID: chapter.id) ? "star.fill" : "star")
                    .foregroundStyle(AppTheme.secondary)
            }
            .accessibilityLabel(appState.isFavourite(chapterID: chapter.id) ? "Remover dos favoritos" : "Favoritar")
        }
    }

    // MARK: - Font Controls Popover

    private var fontControlsPopover: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Tamanho da letra")
                .font(AppTheme.uiLabel(size: 14, weight: .semibold))
                .foregroundStyle(AppTheme.primary)

            HStack(spacing: 12) {
                Button {
                    settings.fontSize = max(13, settings.fontSize - 1)
                } label: {
                    Image(systemName: "minus")
                        .frame(width: 36, height: 36)
                        .background(AppTheme.surfaceContainer)
                        .clipShape(Circle())
                }

                Text("\(Int(settings.fontSize))pt")
                    .font(AppTheme.uiLabel(size: 15, weight: .semibold))
                    .frame(width: 56)
                    .multilineTextAlignment(.center)
                    .foregroundStyle(AppTheme.primary)

                Button {
                    settings.fontSize = min(28, settings.fontSize + 1)
                } label: {
                    Image(systemName: "plus")
                        .frame(width: 36, height: 36)
                        .background(AppTheme.surfaceContainer)
                        .clipShape(Circle())
                }
            }
            .foregroundStyle(AppTheme.primary)

            Slider(value: $settings.fontSize, in: 13...28, step: 1)
                .tint(AppTheme.secondary)
                .frame(width: 200)
        }
        .padding(20)
        .presentationCompactAdaptation(.popover)
    }

    // MARK: - Chapter Navigation Menu

    @EnvironmentObject private var contentService: ContentService

    private var chapterNavigationMenu: some View {
        Group {
            if let prev = contentService.chapter(id: chapter.id - 1) {
                Button {
                    navigateToChapterID = prev.id
                } label: {
                    Label("← \(prev.displayTitle): \(prev.title)", systemImage: "arrow.left")
                }
            }
            Divider()
            if let next = contentService.chapter(id: chapter.id + 1) {
                Button {
                    navigateToChapterID = next.id
                } label: {
                    Label("→ \(next.displayTitle): \(next.title)", systemImage: "arrow.right")
                }
            }
        }
    }
}

#Preview {
    let chapter = Chapter(
        id: 1,
        romanNumeral: "I",
        title: "Da Escritura Sagrada",
        sections: [
            Section(id: "ch1_s1", romanNumeral: "I",
                    text: "Ainda que a luz da natureza e as obras da criação e da providência de tal modo manifestem a bondade, a sabedoria e o poder de Deus…",
                    references: "Sal. 19:1-4; Rom. 1:19-20")
        ]
    )
    return NavigationStack {
        ReadingView(chapter: chapter)
    }
    .environmentObject(AppState())
    .environmentObject(ReadingSettings())
    .environmentObject(ContentService())
}
