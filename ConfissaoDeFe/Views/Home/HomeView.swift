import SwiftUI

// MARK: - HomeView

struct HomeView: View {

    @EnvironmentObject private var contentService: ContentService
    @EnvironmentObject private var appState: AppState
    @Binding var selectedTab: AppTab
    @Binding var selectedChapterID: Int?

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 32) {
                    headerSection
                    if let lastChapter = lastReadChapter {
                        continueReadingCard(chapter: lastChapter)
                    }
                    recentFavouritesSection
                    allChaptersPreview
                }
                .padding(.horizontal, AppTheme.pagePadding)
                .padding(.top, 8)
                .padding(.bottom, 40)
            }
            .background(AppTheme.surface.ignoresSafeArea())
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        selectedTab = .search
                    } label: {
                        Image(systemName: "magnifyingglass")
                            .foregroundStyle(AppTheme.primary)
                    }
                    .accessibilityLabel("Buscar")
                }
            }
        }
    }

    // MARK: - Header

    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("Padrões Presbiterianos")
                .font(AppTheme.uiLabel(size: 11, weight: .semibold))
                .tracking(1.4)
                .textCase(.uppercase)
                .foregroundStyle(AppTheme.secondary)

            Text("Início")
                .font(AppTheme.readingHeadline(size: 34))
                .foregroundStyle(AppTheme.primary)
        }
        .padding(.top, 8)
    }

    // MARK: - Continue Reading Card

    private var lastReadChapter: Chapter? {
        guard appState.lastReadChapterID > 0 else { return nil }
        return contentService.chapter(id: appState.lastReadChapterID)
    }

    private func continueReadingCard(chapter: Chapter) -> some View {
        Button {
            selectedChapterID = chapter.id
            if UIDevice.current.userInterfaceIdiom != .pad {
                selectedTab = .chapters
            }
        } label: {
            ZStack(alignment: .topLeading) {
                // Background
                RoundedRectangle(cornerRadius: AppTheme.cardRadius)
                    .fill(AppTheme.primaryContainer)

                // Decorative circle
                Circle()
                    .fill(AppTheme.secondary.opacity(0.12))
                    .frame(width: 180, height: 180)
                    .offset(x: 220, y: -60)
                    .blur(radius: 32)

                VStack(alignment: .leading, spacing: 16) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("ÚLTIMA LEITURA")
                            .font(AppTheme.uiLabel(size: 10, weight: .semibold))
                            .tracking(1.8)
                            .foregroundStyle(AppTheme.onPrimaryContainer)

                        Text(chapter.displayTitle)
                            .font(AppTheme.uiLabel(size: 13, weight: .medium))
                            .foregroundStyle(AppTheme.onPrimaryContainer)

                        Text(chapter.title)
                            .font(AppTheme.readingHeadline(size: 20))
                            .foregroundStyle(.white)
                            .lineLimit(2)

                        if let firstSection = chapter.sections.first {
                            Text(firstSection.text.prefix(100) + "…")
                                .font(AppTheme.readingBody(size: 13))
                                .italic()
                                .foregroundStyle(AppTheme.onPrimaryContainer)
                                .lineLimit(2)
                                .padding(.top, 2)
                        }
                    }

                    HStack {
                        Text("Continuar leitura")
                            .font(AppTheme.uiLabel(size: 14, weight: .semibold))
                        Image(systemName: "arrow.forward")
                            .font(.system(size: 13, weight: .semibold))
                    }
                    .foregroundStyle(.white)
                    .padding(.horizontal, 18)
                    .padding(.vertical, 10)
                    .background(AppTheme.secondary)
                    .clipShape(Capsule())
                }
                .padding(20)
            }
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Continuar leitura: \(chapter.fullTitle)")
    }

    // MARK: - Favourites

    private var favouriteChapters: [Chapter] {
        contentService.chapters.filter { appState.isFavourite(chapterID: $0.id) }
    }

    private var recentFavouritesSection: some View {
        Group {
            if !favouriteChapters.isEmpty {
                VStack(alignment: .leading, spacing: 12) {
                    sectionHeader(title: "Favoritos Recentes", action: {
                        selectedTab = .study
                    })

                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            ForEach(favouriteChapters.prefix(5)) { chapter in
                                favouriteCard(chapter: chapter)
                            }
                        }
                        .padding(.horizontal, AppTheme.pagePadding)
                    }
                    .padding(.horizontal, -AppTheme.pagePadding)
                }
            }
        }
    }

    private func favouriteCard(chapter: Chapter) -> some View {
        Button {
            selectedChapterID = chapter.id
            if UIDevice.current.userInterfaceIdiom != .pad {
                selectedTab = .chapters
            }
        } label: {
            VStack(alignment: .leading, spacing: 8) {
                Image(systemName: "star.fill")
                    .font(.system(size: 13))
                    .foregroundStyle(AppTheme.secondary)

                Text(chapter.displayTitle)
                    .font(AppTheme.uiLabel(size: 11, weight: .medium))
                    .tracking(0.4)
                    .textCase(.uppercase)
                    .foregroundStyle(AppTheme.outline)

                Text(chapter.title)
                    .font(AppTheme.readingBody(size: 14))
                    .foregroundStyle(AppTheme.primary)
                    .lineLimit(3)
                    .multilineTextAlignment(.leading)
            }
            .padding(16)
            .frame(width: 168, alignment: .leading)
            .cardStyle()
            .overlay(alignment: .leading) {
                Rectangle()
                    .fill(AppTheme.secondary)
                    .frame(width: 2)
                    .clipShape(
                        UnevenRoundedRectangle(
                            topLeadingRadius: AppTheme.cardRadius,
                            bottomLeadingRadius: AppTheme.cardRadius
                        )
                    )
            }
        }
        .buttonStyle(.plain)
    }

    // MARK: - All Chapters Preview

    private var allChaptersPreview: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionHeader(title: "Capítulos", action: {
                selectedTab = .chapters
            })

            VStack(spacing: 0) {
                ForEach(contentService.chapters.prefix(5)) { chapter in
                    chapterRow(chapter)
                    if chapter.id < min(5, contentService.chapters.count) {
                        SectionDivider().padding(.leading, 56)
                    }
                }

                Button {
                    selectedTab = .chapters
                } label: {
                    HStack {
                        Text("Ver todos os \(contentService.chapters.count) capítulos")
                            .font(AppTheme.uiLabel(size: 14, weight: .medium))
                            .foregroundStyle(AppTheme.secondary)
                        Spacer()
                        Image(systemName: "chevron.right")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundStyle(AppTheme.secondary)
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 14)
                }
            }
            .cardStyle()
        }
    }

    private func chapterRow(_ chapter: Chapter) -> some View {
        Button {
            selectedChapterID = chapter.id
            if UIDevice.current.userInterfaceIdiom != .pad {
                selectedTab = .chapters
            }
        } label: {
            HStack(spacing: 14) {
                Text(chapter.romanNumeral)
                    .font(.system(size: 13, weight: .semibold, design: .serif))
                    .foregroundStyle(.white)
                    .frame(width: 36, height: 36)
                    .background(AppTheme.primaryContainer)
                    .clipShape(Circle())

                VStack(alignment: .leading, spacing: 2) {
                    Text(chapter.title)
                        .font(AppTheme.readingBody(size: 15))
                        .foregroundStyle(AppTheme.primary)
                        .lineLimit(1)
                    Text("\(chapter.sections.count) seções")
                        .font(AppTheme.uiLabel(size: 12))
                        .foregroundStyle(AppTheme.outline)
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.system(size: 12))
                    .foregroundStyle(AppTheme.outline.opacity(0.5))
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
        }
        .buttonStyle(.plain)
    }

    // MARK: - Helpers

    private func sectionHeader(title: String, action: @escaping () -> Void) -> some View {
        HStack(alignment: .firstTextBaseline) {
            Text(title)
                .font(AppTheme.readingHeadline(size: 20))
                .foregroundStyle(AppTheme.primary)
            Spacer()
            Button("Ver todos", action: action)
                .font(AppTheme.uiLabel(size: 12, weight: .semibold))
                .textCase(.uppercase)
                .tracking(0.8)
                .foregroundStyle(AppTheme.secondary)
        }
    }
}

#Preview {
    HomeView(selectedTab: .constant(AppTab.home), selectedChapterID: .constant(nil))
        .environmentObject(ContentService())
        .environmentObject(AppState())
        .environmentObject(ReadingSettings())
}
