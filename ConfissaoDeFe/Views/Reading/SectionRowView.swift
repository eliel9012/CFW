import SwiftUI

// MARK: - SectionRowView
// Renders a single numbered section with its bible references.

struct SectionRowView: View {

    let section: Section
    let chapter: Chapter
    let fontSize: Double

    @EnvironmentObject private var appState: AppState
    @State private var showingShareSheet = false

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .center, spacing: 10) {
                if section.hasNumber {
                    Text(section.displayNumber)
                        .font(.system(size: fontSize * 0.75, weight: .semibold, design: .serif))
                        .foregroundStyle(AppTheme.secondary)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 3)
                        .background(AppTheme.secondaryContainer.opacity(0.45))
                        .clipShape(RoundedRectangle(cornerRadius: 4))
                }

                Spacer()

                // Contextual menu for this section
                Menu {
                    Button {
                        let note = StudyNote(
                            chapterID: chapter.id,
                            chapterTitle: chapter.fullTitle,
                            sectionID: section.id,
                            sectionNumber: section.romanNumeral,
                            excerpt: section.text
                        )
                        appState.addNote(note)
                    } label: {
                        Label("Salvar no Estudo", systemImage: "bookmark")
                    }

                    Button {
                        UIPasteboard.general.string = formattedText
                    } label: {
                        Label("Copiar trecho", systemImage: "doc.on.doc")
                    }

                    ShareLink(item: formattedText) {
                        Label("Compartilhar", systemImage: "square.and.arrow.up")
                    }
                } label: {
                    Image(systemName: "ellipsis")
                        .font(.system(size: 16))
                        .foregroundStyle(AppTheme.outline)
                        .padding(8)
                        .contentShape(Rectangle())
                }
                .accessibilityLabel(section.hasNumber
                    ? "Opções da seção \(section.romanNumeral)"
                    : "Opções do texto")
            }

            // Body text
            Text(section.text)
                .font(AppTheme.readingBody(size: fontSize))
                .foregroundStyle(Color(.label))
                .lineSpacing(AppTheme.lineSpacing)
                .textSelection(.enabled)
                .fixedSize(horizontal: false, vertical: true)

            // Bible references
            if section.hasReferences {
                referencesView
            }
        }
        .padding(.vertical, 8)
        .accessibilityElement(children: .combine)
        .accessibilityLabel(section.hasNumber
            ? "Seção \(section.romanNumeral). \(section.text)"
            : section.text)
    }

    // MARK: - References

    private var referencesView: some View {
        HStack(alignment: .top, spacing: 8) {
            Rectangle()
                .fill(AppTheme.secondary.opacity(0.5))
                .frame(width: 2)
                .clipShape(Capsule())

            Text(section.references)
                .font(AppTheme.uiLabel(size: fontSize * 0.78))
                .foregroundStyle(AppTheme.secondary)
                .lineSpacing(4)
                .textSelection(.enabled)
        }
        .padding(.top, 4)
        .accessibilityLabel("Referências bíblicas: \(section.references)")
    }

    // MARK: - Copy helpers

    private var formattedText: String {
        var s = chapter.fullTitle
        if section.hasNumber {
            s += " — §\(section.romanNumeral)"
        }
        s += "\n\n\(section.text)"
        if section.hasReferences {
            s += "\n\n\(section.references)"
        }
        return s
    }
}
