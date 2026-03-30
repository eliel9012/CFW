import SwiftUI

// MARK: - MainTabView
// Adapts layout for iPhone (TabView) vs iPad (NavigationSplitView).

struct MainTabView: View {

    @EnvironmentObject private var contentService: ContentService
    @EnvironmentObject private var appState: AppState
    @EnvironmentObject private var settings: ReadingSettings

    @State private var selectedTab: AppTab = .home
    @State private var selectedChapterID: Int? = nil
    @State private var chapterPath: [Int] = []
    @State private var iPadSelectedTab: AppTab? = .home

    var body: some View {
        Group {
            if UIDevice.current.userInterfaceIdiom == .pad {
                iPadLayout
            } else {
                iPhoneLayout
            }
        }
        .overlay {
            if contentService.isLoading {
                loadingOverlay
            }
        }
    }

    // MARK: - iPhone Layout

    private var iPhoneLayout: some View {
        TabView(selection: $selectedTab) {
            Tab(AppTab.home.label, systemImage: AppTab.home.icon, value: AppTab.home) {
                HomeView(selectedTab: $selectedTab, selectedChapterID: $selectedChapterID)
            }
            Tab(AppTab.chapters.label, systemImage: AppTab.chapters.icon, value: AppTab.chapters) {
                NavigationStack(path: $chapterPath) {
                    ChapterListView(selectedChapterID: $selectedChapterID)
                        .navigationDestination(for: Int.self) { id in
                            if let chapter = contentService.chapter(id: id) {
                                ReadingView(chapter: chapter)
                                    .onAppear {
                                        selectedChapterID = id
                                    }
                            }
                        }
                }
            }
            Tab(AppTab.search.label, systemImage: AppTab.search.icon, value: AppTab.search) {
                NavigationStack {
                    SearchView(selectedChapterID: $selectedChapterID)
                }
            }
            Tab(AppTab.study.label, systemImage: AppTab.study.icon, value: AppTab.study) {
                NavigationStack {
                    StudyView(selectedChapterID: $selectedChapterID)
                }
            }
            Tab(AppTab.settings.label, systemImage: AppTab.settings.icon, value: AppTab.settings) {
                NavigationStack {
                    SettingsView()
                }
            }
        }
        .tint(AppTheme.secondary)
        .onChange(of: selectedTab) { _, newTab in
            guard newTab == .chapters else { return }
            syncIPhoneChapterPath()
        }
        .onChange(of: selectedChapterID) { _, _ in
            guard selectedTab == .chapters else { return }
            syncIPhoneChapterPath()
        }
    }

    // MARK: - iPad Layout

    @State private var iPadColumn: NavigationSplitViewVisibility = .all

    private var iPadLayout: some View {
        NavigationSplitView(columnVisibility: $iPadColumn) {
            // Sidebar
            List(selection: $iPadSelectedTab) {
                ForEach(AppTab.allCases, id: \.self) { tab in
                    Label(tab.label, systemImage: tab.icon)
                        .tag(tab)
                }
            }
            .navigationTitle("Confissão de Fé")
            .listStyle(.sidebar)
        } content: {
            // Middle column – chapter list when relevant
            switch iPadSelectedTab ?? .home {
            case .home, .chapters:
                ChapterListView(selectedChapterID: $selectedChapterID)
            case .search:
                SearchView(selectedChapterID: $selectedChapterID)
            case .study:
                StudyView(selectedChapterID: $selectedChapterID)
            case .settings:
                SettingsView()
            }
        } detail: {
            // Detail – reading pane
            if let id = selectedChapterID,
               let chapter = contentService.chapter(id: id) {
                ReadingView(chapter: chapter)
            } else {
                iPadWelcome
            }
        }
        .navigationSplitViewStyle(.balanced)
        .tint(AppTheme.secondary)
    }

    private var iPadWelcome: some View {
        VStack(spacing: 16) {
            Image(systemName: "book.closed")
                .font(.system(size: 64, weight: .ultraLight))
                .foregroundStyle(AppTheme.primary.opacity(0.25))
            Text("Selecione um capítulo")
                .font(AppTheme.uiLabel(size: 17))
                .foregroundStyle(AppTheme.outline)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(AppTheme.surface)
    }

    // MARK: - Loading

    private var loadingOverlay: some View {
        ZStack {
            Color.black.opacity(0.4).ignoresSafeArea()
            VStack(spacing: 16) {
                ProgressView()
                    .progressViewStyle(.circular)
                    .tint(.white)
                Text("Carregando Confissão…")
                    .font(AppTheme.uiLabel(size: 15))
                    .foregroundStyle(.white)
            }
            .padding(24)
            .background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 16))
        }
    }

    private func syncIPhoneChapterPath() {
        guard UIDevice.current.userInterfaceIdiom != .pad else { return }

        guard let selectedChapterID else {
            chapterPath.removeAll()
            return
        }

        if chapterPath != [selectedChapterID] {
            chapterPath = [selectedChapterID]
        }
    }
}

#Preview {
    MainTabView()
        .environmentObject(ContentService())
        .environmentObject(AppState())
        .environmentObject(ReadingSettings())
}
