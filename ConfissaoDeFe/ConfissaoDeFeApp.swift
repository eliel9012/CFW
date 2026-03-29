import SwiftUI

@main
struct ConfissaoDeFeApp: App {

    @StateObject private var contentService = ContentService()
    @StateObject private var appState       = AppState()
    @StateObject private var settings       = ReadingSettings()

    @State private var showSplash = true

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
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.8) {
                    withAnimation(.easeInOut(duration: 0.5)) {
                        showSplash = false
                    }
                }
            }
        }
    }
}
