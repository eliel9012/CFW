import SwiftUI

@main
struct ConfissaoDeFeApp: App {

    @StateObject private var contentService = ContentService()
    @StateObject private var appState       = AppState()
    @StateObject private var settings       = ReadingSettings()

    @State private var showSplash = false

    private let coldStartSplashDuration: UInt64 = 250_000_000

    var body: some Scene {
        WindowGroup {
            ZStack {
                MainTabView()
                    .environmentObject(contentService)
                    .environmentObject(appState)
                    .environmentObject(settings)
                    .preferredColorScheme(settings.preferredColorScheme)

                if showSplash {
                    SplashScreenView()
                        .transition(.opacity)
                        .zIndex(1)
                }
            }
            .onAppear {
                guard contentService.chapters.isEmpty else { return }
                showSplash = true

                Task {
                    try? await Task.sleep(nanoseconds: coldStartSplashDuration)
                    await MainActor.run {
                        withAnimation(.easeOut(duration: 0.2)) {
                            showSplash = false
                        }
                    }
                }
            }
        }
    }
}
