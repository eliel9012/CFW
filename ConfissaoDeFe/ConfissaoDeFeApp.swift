import SwiftUI

@main
struct ConfissaoDeFeApp: App {

    @StateObject private var contentService = ContentService()
    @StateObject private var appState       = AppState()
    @StateObject private var settings       = ReadingSettings()

    var body: some Scene {
        WindowGroup {
            MainTabView()
                .environmentObject(contentService)
                .environmentObject(appState)
                .environmentObject(settings)
                .preferredColorScheme(settings.preferredColorScheme)
        }
    }
}
