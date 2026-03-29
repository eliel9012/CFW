import SwiftUI

// MARK: - SplashScreenView
// Displays an elegant launch screen matching the navy + gold brand identity.
// Shown briefly on app start, then crossfades to the main content.

struct SplashScreenView: View {

    @State private var iconOpacity: Double = 0
    @State private var titleOpacity: Double = 0
    @State private var subtitleOpacity: Double = 0
    @State private var footerOpacity: Double = 0
    @State private var iconScale: CGFloat = 0.85

    var body: some View {
        ZStack {
            // Radial gradient background (scriptorium)
            RadialGradient(
                colors: [
                    Color(red: 0.102, green: 0.169, blue: 0.282),  // #1a2b48
                    Color(red: 0.012, green: 0.086, blue: 0.196)   // #031632
                ],
                center: .center,
                startRadius: 0,
                endRadius: 500
            )
            .ignoresSafeArea()

            VStack(spacing: 0) {
                Spacer()

                // Center icon group
                VStack(spacing: 16) {
                    // Flame + Book icon
                    ZStack {
                        // Glow behind icon
                        Circle()
                            .fill(AppTheme.secondary.opacity(0.08))
                            .frame(width: 140, height: 140)
                            .blur(radius: 30)

                        VStack(spacing: -12) {
                            Image(systemName: "flame.fill")
                                .font(.system(size: 52, weight: .light))
                                .foregroundStyle(
                                    LinearGradient(
                                        colors: [
                                            Color(red: 0.92, green: 0.76, blue: 0.38),  // warm gold
                                            AppTheme.secondary
                                        ],
                                        startPoint: .top,
                                        endPoint: .bottom
                                    )
                                )
                                .shadow(color: AppTheme.secondary.opacity(0.35), radius: 8, y: 2)

                            Image(systemName: "book.fill")
                                .font(.system(size: 62, weight: .ultraLight))
                                .foregroundStyle(AppTheme.secondary)
                        }
                    }
                    .scaleEffect(iconScale)
                    .opacity(iconOpacity)

                    // Title
                    VStack(spacing: 6) {
                        Text("Confissão de Fé")
                            .font(.custom("Georgia", size: 30))
                            .fontWeight(.medium)
                            .foregroundStyle(Color(red: 0.98, green: 0.976, blue: 0.957)) // #fbf9f4
                            .tracking(0.5)

                        Text("de Westminster")
                            .font(.custom("Georgia", size: 19))
                            .italic()
                            .foregroundStyle(Color(red: 0.51, green: 0.576, blue: 0.71).opacity(0.85)) // #8293b5
                            .tracking(1)
                    }
                    .opacity(titleOpacity)
                }

                Spacer()

                // Bottom branding
                VStack(spacing: 12) {
                    // Subtle dot indicator
                    HStack(spacing: 5) {
                        Circle().fill(AppTheme.secondary.opacity(0.4)).frame(width: 5, height: 5)
                        Circle().fill(AppTheme.secondary.opacity(0.2)).frame(width: 5, height: 5)
                        Circle().fill(AppTheme.secondary.opacity(0.1)).frame(width: 5, height: 5)
                    }

                    Text("PADRÕES PRESBITERIANOS")
                        .font(.system(size: 10, weight: .medium, design: .default))
                        .tracking(3)
                        .foregroundStyle(Color(red: 0.51, green: 0.576, blue: 0.71)) // #8293b5
                }
                .opacity(footerOpacity)
                .padding(.bottom, 50)
            }
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.6)) {
                iconOpacity = 1
                iconScale = 1.0
            }
            withAnimation(.easeOut(duration: 0.5).delay(0.25)) {
                titleOpacity = 1
            }
            withAnimation(.easeOut(duration: 0.4).delay(0.5)) {
                subtitleOpacity = 1
                footerOpacity = 1
            }
        }
    }
}

#Preview {
    SplashScreenView()
}
