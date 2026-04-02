import SwiftUI

@main
struct ConfissaoDeFeApp: App {

    @StateObject private var contentService = ContentService()
    @StateObject private var appState       = AppState()
    @StateObject private var settings       = ReadingSettings()

    @State private var showSplash = true

    private let coldStartSplashDuration: UInt64 = 2_200_000_000

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
                Task {
                    try? await Task.sleep(nanoseconds: coldStartSplashDuration)
                    await MainActor.run {
                        withAnimation(.easeOut(duration: 0.5)) {
                            showSplash = false
                        }
                    }
                }
            }
        }
    }
}
