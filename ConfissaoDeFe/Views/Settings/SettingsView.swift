import SwiftUI

// MARK: - SettingsView

struct SettingsView: View {

    @EnvironmentObject private var settings: ReadingSettings
    @Environment(\.colorScheme) private var colorScheme

    @State private var showResetConfirm = false

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {

                // MARK: Aparência
                settingsGroup(title: "Aparência") {
                    Picker("Aparência", selection: $settings.colorSchemeRaw) {
                        Label("Sistema", systemImage: "circle.lefthalf.filled").tag("system")
                        Label("Claro",   systemImage: "sun.max").tag("light")
                        Label("Escuro",  systemImage: "moon").tag("dark")
                    }
                    .pickerStyle(.segmented)
                }

                // MARK: Tipografia
                settingsGroup(title: "Tipografia") {
                    VStack(alignment: .leading, spacing: 10) {
                        HStack {
                            Text("Tamanho da fonte")
                                .font(AppTheme.uiLabel(size: 15))
                                .foregroundStyle(AppTheme.primary)
                            Spacer()
                            Text("\(Int(settings.fontSize))pt")
                                .font(AppTheme.uiLabel(size: 14, weight: .semibold))
                                .foregroundStyle(AppTheme.secondary)
                                .monospacedDigit()
                        }

                        Slider(value: $settings.fontSize, in: 13...28, step: 1)
                            .tint(AppTheme.secondary)

                        HStack(spacing: 8) {
                            Text("Aa")
                                .font(AppTheme.readingBody(size: settings.fontSize))
                                .foregroundStyle(AppTheme.primary)

                            Text("Ainda que a luz da natureza manifeste a bondade de Deus…")
                                .font(AppTheme.readingBody(size: settings.fontSize))
                                .foregroundStyle(AppTheme.primary)
                                .lineSpacing(AppTheme.lineSpacing)
                                .lineLimit(2)
                        }
                        .padding(12)
                        .background(AppTheme.surfaceContainer)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                    }
                }

                // MARK: Sobre
                settingsGroup(title: "Sobre") {
                    labelRow(icon: "book.closed", label: "Confissão de Fé de Westminster",
                             value: "1646 (rev. 1903)")
                    Divider()
                    labelRow(icon: "globe", label: "Idioma", value: "Português do Brasil")
                    Divider()
                    labelRow(icon: "app.badge", label: "Versão", value: appVersion)
                }

                // MARK: Redefinir
                settingsGroup(title: nil) {
                    Button(role: .destructive) {
                        showResetConfirm = true
                    } label: {
                        HStack {
                            Spacer()
                            Image(systemName: "arrow.counterclockwise")
                            Text("Restaurar preferências padrão")
                            Spacer()
                        }
                        .foregroundStyle(.red)
                    }
                }

            }
            .padding(.horizontal, 16)
            .padding(.vertical, 20)
        }
        .background(AppTheme.surface.ignoresSafeArea())
        .navigationTitle("Ajustes")
        .confirmationDialog(
            "Restaurar preferências?",
            isPresented: $showResetConfirm,
            titleVisibility: .visible
        ) {
            Button("Restaurar", role: .destructive) { settings.reset() }
            Button("Cancelar", role: .cancel) {}
        } message: {
            Text("O tamanho da fonte e a aparência voltarão aos valores padrão.")
        }
    }

    // MARK: - Section Group

    @ViewBuilder
    private func settingsGroup<Content: View>(title: String?, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            if let title {
                Text(title)
                    .font(AppTheme.uiLabel(size: 12, weight: .semibold))
                    .tracking(0.6)
                    .foregroundStyle(AppTheme.outline)
                    .padding(.horizontal, 4)
            }
            VStack(spacing: 0) {
                content()
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
            }
            .background(colorScheme == .dark ? Color(.systemGray6) : AppTheme.surfaceContainer)
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
    }

    // MARK: - Helpers

    private func labelRow(icon: String, label: String, value: String) -> some View {
        HStack {
            Label {
                Text(label)
                    .font(AppTheme.uiLabel(size: 15))
                    .foregroundStyle(AppTheme.primary)
            } icon: {
                Image(systemName: icon)
                    .foregroundStyle(AppTheme.secondary)
            }
            Spacer()
            Text(value)
                .font(AppTheme.uiLabel(size: 14))
                .foregroundStyle(AppTheme.outline)
        }
    }

    private var appVersion: String {
        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
        let build   = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
        return "\(version) (\(build))"
    }
}

#Preview {
    NavigationStack {
        SettingsView()
            .environmentObject(ReadingSettings())
    }
}
