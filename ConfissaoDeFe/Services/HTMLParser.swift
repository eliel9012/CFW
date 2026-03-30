import Foundation

// MARK: - HTMLParser
// Parses the bundled ConfissaoDeFe.html (ISO-8859-1 encoded, HTML 4 entities)
// into a structured array of Chapter/Section models.

enum HTMLParser {

    // MARK: - Public

    static func parseConfession() -> [Chapter] {
        guard let url = Bundle.main.url(forResource: "ConfissaoDeFe", withExtension: "html"),
              let data = try? Data(contentsOf: url),
              // The original file uses ISO-8859-1 (Latin-1)
              let raw = String(data: data, encoding: .isoLatin1) else {
            assertionFailure("HTMLParser: cannot load ConfissaoDeFe.html from bundle")
            return []
        }
        return parse(html: raw)
    }

    // Exposed for unit testing
    static func parse(html: String) -> [Chapter] {
        let decoded = decodeEntities(html)
        let paragraphs = extractParagraphs(from: decoded)
        return buildChapters(from: paragraphs)
    }

    // MARK: - HTML Entity Decoding

    private static func decodeEntities(_ input: String) -> String {
        var s = input
        // Named entities for Portuguese / common HTML
        let table: [(String, String)] = [
            ("&amp;", "&"), ("&lt;", "<"), ("&gt;", ">"),
            ("&quot;", "\""), ("&apos;", "'"), ("&nbsp;", " "),
            // Lowercase accented
            ("&aacute;", "á"), ("&agrave;", "à"), ("&acirc;", "â"), ("&atilde;", "ã"), ("&auml;", "ä"),
            ("&eacute;", "é"), ("&egrave;", "è"), ("&ecirc;", "ê"), ("&euml;", "ë"),
            ("&iacute;", "í"), ("&igrave;", "ì"), ("&icirc;", "î"), ("&iuml;", "ï"),
            ("&oacute;", "ó"), ("&ograve;", "ò"), ("&ocirc;", "ô"), ("&otilde;", "õ"), ("&ouml;", "ö"),
            ("&uacute;", "ú"), ("&ugrave;", "ù"), ("&ucirc;", "û"), ("&uuml;", "ü"),
            ("&ccedil;", "ç"), ("&ntilde;", "ñ"),
            // Uppercase accented
            ("&Aacute;", "Á"), ("&Agrave;", "À"), ("&Acirc;", "Â"), ("&Atilde;", "Ã"), ("&Auml;", "Ä"),
            ("&Eacute;", "É"), ("&Egrave;", "È"), ("&Ecirc;", "Ê"), ("&Euml;", "Ë"),
            ("&Iacute;", "Í"), ("&Igrave;", "Ì"), ("&Icirc;", "Î"), ("&Iuml;", "Ï"),
            ("&Oacute;", "Ó"), ("&Ograve;", "Ò"), ("&Ocirc;", "Ô"), ("&Otilde;", "Õ"), ("&Ouml;", "Ö"),
            ("&Uacute;", "Ú"), ("&Ugrave;", "Ù"), ("&Ucirc;", "Û"), ("&Uuml;", "Ü"),
            ("&Ccedil;", "Ç"), ("&Ntilde;", "Ñ"),
            // Punctuation
            ("&ndash;", "–"), ("&mdash;", "—"),
            ("&lsquo;", "\u{2018}"), ("&rsquo;", "\u{2019}"),
            ("&ldquo;", "\u{201C}"), ("&rdquo;", "\u{201D}"),
            ("&laquo;", "«"), ("&raquo;", "»"),
        ]
        for (entity, replacement) in table {
            s = s.replacingOccurrences(of: entity, with: replacement)
        }
        // Numeric decimal entities like &#233;
        if let regex = try? NSRegularExpression(pattern: "&#(\\d{1,5});") {
            let ns = s as NSString
            var offset = 0
            for match in regex.matches(in: s, range: NSRange(location: 0, length: ns.length)) {
                guard match.numberOfRanges > 1 else { continue }
                let codeRange = match.range(at: 1)
                if codeRange.location == NSNotFound { continue }
                let code = Int(ns.substring(with: codeRange)) ?? 0
                guard let scalar = Unicode.Scalar(code) else { continue }
                let replacement = String(Character(scalar))
                let adjustedRange = NSRange(location: match.range.location + offset,
                                            length: match.range.length)
                if let swiftRange = Range(adjustedRange, in: s) {
                    s.replaceSubrange(swiftRange, with: replacement)
                    offset += replacement.utf16.count - match.range.length
                }
            }
        }
        return s
    }

    // MARK: - Paragraph Extraction

    private struct RawParagraph {
        let alignment: String   // "center" | "justify" | "left"
        let text: String
    }

    private static func extractParagraphs(from html: String) -> [RawParagraph] {
        var result: [RawParagraph] = []
        guard let regex = try? NSRegularExpression(
            pattern: #"<p\b([^>]*)>(.*?)</p>"#,
            options: [.dotMatchesLineSeparators, .caseInsensitive]
        ) else { return [] }

        let ns = html as NSString
        let full = NSRange(location: 0, length: ns.length)
        for match in regex.matches(in: html, range: full) {
            let attrs = match.range(at: 1).location != NSNotFound
                ? ns.substring(with: match.range(at: 1))
                : ""
            let rawContent = match.range(at: 2).location != NSNotFound
                ? ns.substring(with: match.range(at: 2))
                : ""

            let alignment: String
            let attrsL = attrs.lowercased()
            if attrsL.contains("center") { alignment = "center" }
            else if attrsL.contains("justify") { alignment = "justify" }
            else { alignment = "left" }

            let text = stripTags(rawContent)
                .components(separatedBy: .newlines)
                .map { $0.trimmingCharacters(in: .whitespaces) }
                .filter { !$0.isEmpty }
                .joined(separator: " ")
                .trimmingCharacters(in: .whitespacesAndNewlines)

            if !text.isEmpty && text != "\u{00A0}" {
                result.append(RawParagraph(alignment: alignment, text: text))
            }
        }
        return result
    }

    private static func stripTags(_ html: String) -> String {
        // Replace <br> variants with a space
        var s = html
            .replacingOccurrences(of: "<br>", with: " ", options: .caseInsensitive)
            .replacingOccurrences(of: "<br/>", with: " ", options: .caseInsensitive)
            .replacingOccurrences(of: "<br />", with: " ", options: .caseInsensitive)
        // Strip all other tags
        if let regex = try? NSRegularExpression(pattern: "<[^>]+>", options: .caseInsensitive) {
            s = regex.stringByReplacingMatches(in: s,
                                               range: NSRange(s.startIndex..., in: s),
                                               withTemplate: "")
        }
        return s
    }

    // MARK: - Chapter Assembly

    private static func buildChapters(from paragraphs: [RawParagraph]) -> [Chapter] {
        var chapters: [Chapter] = []
        var chapterCounter = 0
        var historicalAmendments: [HistoricalAmendment] = []

        // Accumulate paragraphs per chapter
        var currentRoman = ""
        var currentTitle = ""
        var pendingParagraphs: [RawParagraph] = []

        func flush() {
            guard !currentTitle.isEmpty else { return }
            chapterCounter += 1
            var chapterParagraphs = pendingParagraphs
            if currentTitle == "Nota Histórica" {
                historicalAmendments.append(contentsOf: extractHistoricalAmendments(from: pendingParagraphs))
                chapterParagraphs = removingHistoricalAmendments(from: pendingParagraphs)
            }
            let sections = buildSections(from: chapterParagraphs,
                                         chapterIndex: chapterCounter,
                                         chapterRoman: currentRoman)
            chapters.append(Chapter(id: chapterCounter,
                                    romanNumeral: currentRoman,
                                    title: currentTitle,
                                    sections: sections))
            pendingParagraphs = []
        }

        for para in paragraphs {
            if para.alignment == "center", let info = extractChapterInfo(from: para.text) {
                flush()
                currentRoman = info.roman
                currentTitle = info.title
            } else if isHistoricalNoteHeading(para.text) {
                flush()
                currentRoman = ""
                currentTitle = "Nota Histórica"
            } else if !currentRoman.isEmpty, para.alignment == "justify" {
                pendingParagraphs.append(para)
            } else if currentRoman.isEmpty, !currentTitle.isEmpty, para.alignment == "justify" {
                // Keep justify paragraphs for unnumbered narrative chapters (e.g. Nota Histórica).
                pendingParagraphs.append(para)
            }
        }
        flush()
        return applyHistoricalAmendments(historicalAmendments, to: chapters)
    }

    // MARK: - Chapter Info Extraction

    private static func extractChapterInfo(from text: String) -> (roman: String, title: String)? {
        guard let regex = try? NSRegularExpression(
            pattern: #"CAPÍTULO\s+([IVXLC]+)\s+(.+)"#,
            options: .caseInsensitive
        ) else { return nil }
        let cleaned = text.trimmingCharacters(in: .whitespacesAndNewlines)
        let range = NSRange(cleaned.startIndex..., in: cleaned)
        guard let match = regex.firstMatch(in: cleaned, range: range),
              match.numberOfRanges >= 3,
              let romanRange = Range(match.range(at: 1), in: cleaned),
              let titleRange = Range(match.range(at: 2), in: cleaned) else { return nil }
        let roman = String(cleaned[romanRange])
        let title = String(cleaned[titleRange])
            .trimmingCharacters(in: .whitespacesAndNewlines)
        return (roman: roman, title: title)
    }

    private static func isHistoricalNoteHeading(_ text: String) -> Bool {
        text.trimmingCharacters(in: .whitespacesAndNewlines)
            .uppercased()
            .contains("NOTA HISTÓRICA")
    }

    // MARK: - Historical Amendments

    private struct HistoricalAmendment {
        let chapterRoman: String
        let sectionRoman: String
        let text: String
    }

    private static let historicalAmendmentHeadingRegex: NSRegularExpression? = {
        try? NSRegularExpression(
            pattern: #"^CAPÍTULO\s+([IVXLC]+)[\.,]\s+SE(?:C|Ç)(?:Ã|A)O\s+([IVXLC]+)$"#,
            options: .caseInsensitive
        )
    }()

    private static func extractHistoricalAmendments(from paragraphs: [RawParagraph]) -> [HistoricalAmendment] {
        guard let regex = historicalAmendmentHeadingRegex else { return [] }

        var amendments: [HistoricalAmendment] = []
        var index = 0

        while index < paragraphs.count {
            let text = paragraphs[index].text.trimmingCharacters(in: .whitespacesAndNewlines)
            let range = NSRange(text.startIndex..., in: text)

            if let match = regex.firstMatch(in: text, range: range),
               match.numberOfRanges >= 3,
               let chapterRange = Range(match.range(at: 1), in: text),
               let sectionRange = Range(match.range(at: 2), in: text),
               index + 1 < paragraphs.count {
                let body = paragraphs[index + 1].text.trimmingCharacters(in: .whitespacesAndNewlines)
                if !body.isEmpty {
                    amendments.append(HistoricalAmendment(
                        chapterRoman: String(text[chapterRange]).uppercased(),
                        sectionRoman: String(text[sectionRange]).uppercased(),
                        text: body
                    ))
                    index += 2
                    continue
                }
            }

            index += 1
        }

        return amendments
    }

    private static func removingHistoricalAmendments(from paragraphs: [RawParagraph]) -> [RawParagraph] {
        guard let regex = historicalAmendmentHeadingRegex else { return paragraphs }

        var filtered: [RawParagraph] = []
        var index = 0

        while index < paragraphs.count {
            let text = paragraphs[index].text.trimmingCharacters(in: .whitespacesAndNewlines)
            let range = NSRange(text.startIndex..., in: text)

            if regex.firstMatch(in: text, range: range) != nil,
               index + 1 < paragraphs.count,
               !paragraphs[index + 1].text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                index += 2
                continue
            }

            filtered.append(paragraphs[index])
            index += 1
        }

        return filtered
    }

    private static func applyHistoricalAmendments(_ amendments: [HistoricalAmendment],
                                                  to chapters: [Chapter]) -> [Chapter] {
        guard !amendments.isEmpty else { return chapters }

        let amendmentMap = Dictionary(
            uniqueKeysWithValues: amendments.map { amendment in
                ("\(amendment.chapterRoman)|\(amendment.sectionRoman)", amendment.text)
            }
        )

        return chapters.map { chapter in
            let updatedSections = chapter.sections.map { section in
                let key = "\(chapter.romanNumeral.uppercased())|\(section.romanNumeral.uppercased())"
                guard let replacement = amendmentMap[key] else { return section }
                return Section(
                    id: section.id,
                    romanNumeral: section.romanNumeral,
                    text: replacement,
                    references: section.references
                )
            }

            return Chapter(
                id: chapter.id,
                romanNumeral: chapter.romanNumeral,
                title: chapter.title,
                sections: updatedSections
            )
        }
    }

    // MARK: - Section Assembly

    private static func buildSections(from paragraphs: [RawParagraph],
                                      chapterIndex: Int,
                                      chapterRoman: String) -> [Section] {
        if chapterRoman.isEmpty {
            let body = paragraphs
                .map { $0.text.trimmingCharacters(in: .whitespacesAndNewlines) }
                .filter { !$0.isEmpty }
                .joined(separator: "\n\n")
            guard !body.isEmpty else { return [] }
            return [Section(id: "ch\(chapterIndex)_s1",
                            romanNumeral: "",
                            text: body,
                            references: "")]
        }

        var sections: [Section] = []
        var sectionSeq = 0

        var currentRoman: String? = nil
        var bodyLines: [String] = []
        var refs = ""

        func flushSection() {
            guard let roman = currentRoman, !bodyLines.isEmpty else { return }
            sectionSeq += 1
            sections.append(Section(
                id: "ch\(chapterIndex)_s\(sectionSeq)",
                romanNumeral: roman,
                text: bodyLines.joined(separator: "\n\n"),
                references: refs
            ))
            currentRoman = nil
            bodyLines = []
            refs = ""
        }

        for para in paragraphs {
            let text = para.text
            if let roman = extractSectionNumeral(from: text) {
                flushSection()
                currentRoman = roman
                let body = removeSectionPrefix(from: text, roman: roman)
                if !body.isEmpty { bodyLines.append(body) }
            } else if currentRoman != nil {
                if looksLikeReferences(text) {
                    let normalized = normalizeReferences(text)
                    guard !normalized.isEmpty else { continue }

                    // Accumulate all reference paragraphs for this section
                    if refs.isEmpty {
                        refs = normalized
                    } else {
                        refs += refs.hasSuffix(";") ? " " : "; "
                        refs += normalized
                    }
                } else if refs.isEmpty {
                    // Only add to body before references have started
                    bodyLines.append(text)
                }
            }
        }
        flushSection()
        return sections
    }

    // MARK: - Section Helpers

    private static let sectionNumeralRegex: NSRegularExpression? = {
        // Matches Roman numerals followed by optional spaced dot, covering cases like "V . Texto".
        try? NSRegularExpression(pattern: #"^([IVXLC]{1,8})\s*(?:\.\s*|\s+)(?=[A-ZÁÉÍÓÚÂÊÔÃÕ])"#)
    }()

    private static func extractSectionNumeral(from text: String) -> String? {
        // Guard against false positives like "I Tim. 5:21".
        if looksLikeReferences(text) { return nil }

        guard let regex = sectionNumeralRegex else { return nil }
        let range = NSRange(text.startIndex..., in: text)
        guard let match = regex.firstMatch(in: text, range: range),
              let numRange = Range(match.range(at: 1), in: text) else { return nil }
        return String(text[numRange])
    }

    private static func removeSectionPrefix(from text: String, roman: String) -> String {
        var s = text
        let escaped = NSRegularExpression.escapedPattern(for: roman)
        if let regex = try? NSRegularExpression(pattern: "^\(escaped)\\s*\\.?\\s*") {
            s = regex.stringByReplacingMatches(in: s,
                                               range: NSRange(s.startIndex..., in: s),
                                               withTemplate: "")
        }
        return s.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    // MARK: - Bible Reference Detection

    private static let referenceTokenPattern: NSRegularExpression? = {
        // Common Portuguese abbreviations + frequent source typos found in the original file.
        let books = "Gen|Gên|Gn|Êx|Exo|Ex|Lev|Lv|Num|Nm|Deut|Dt|Jos|Jz|Rut|Rute|Sam|Reis|Cr|Cron|Esd|Nee|Est|Jó|Sal|Sl|Prov|Pv|Ecl|Cânt|Cant|Isa|Is|Jer|Lam|Eze|Ez|Dan|Dn|Os|Ose|Joel|Am|Amos|Ob|Jon|Miq|Nau|Naum|Hab|Sof|Age|Zac|Mal|Mat|Mt|Mar|Mc|Luc|Lc|Jo|João|At|Atos|Rom|Ron|Cor|Gal|Ef|Fil|Col|Tess|Tim|Tito|Tt|File|Heb|Tia|Tiago|Ped|Pedro|Jud|Judas|Apoc|Ap"
        return try? NSRegularExpression(
            pattern: "(?:^|\\s)(?:I{1,3}\\s+)?(?:\(books))\\.?\\s*\\d+(?:\\s*[:.]\\s*\\d+)?(?:\\s*[-–]\\s*\\d+)?(?:\\s*,\\s*\\d+)*",
            options: .caseInsensitive
        )
    }()

    static func looksLikeReferences(_ text: String) -> Bool {
        let candidate = normalizedReferenceCandidate(text)
        let trimmed = candidate.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return false }

        // Headings like "CAPÍTULO XVI. SEÇÃO VII" are narrative content, not verse lists.
        if trimmed.uppercased().contains("CAPÍTULO") || trimmed.uppercased().contains("SEÇÃO") {
            return false
        }

        if let regex = referenceTokenPattern {
            let matches = regex.matches(in: trimmed, range: NSRange(trimmed.startIndex..., in: trimmed))
            if matches.count >= 2 {
                return true
            }
            if matches.count == 1 {
                let hasChapterVerse = trimmed.range(of: #"\d+\s*[:.]\s*\d+"#,
                                                    options: .regularExpression) != nil
                let hasListSeparator = trimmed.contains(";") || trimmed.contains(",")
                if hasChapterVerse || (hasListSeparator && trimmed.count <= 90) {
                    return true
                }
            }
        }

        // Secondary heuristic: many separators with verse-like numbers.
        let semicolonCount = trimmed.filter { $0 == ";" }.count
        let hasChapterVerse = trimmed.range(of: #"\d+\s*[:.]\s*\d+"#,
                                            options: .regularExpression) != nil
        if semicolonCount >= 2 && hasChapterVerse {
            return true
        }

        return false
    }

    private static func normalizedReferenceCandidate(_ text: String) -> String {
        var s = text
        s = s.replacingOccurrences(of: #"\b(I{1,3}),\s*"#,
                                   with: "$1 ",
                                   options: .regularExpression)
        s = s.replacingOccurrences(of: #"\b(I{1,3})([A-Za-zÁ-Úá-ú]{2,}\.)"#,
                                   with: "$1 $2",
                                   options: .regularExpression)
        s = s.replacingOccurrences(of: #"([A-Za-zÁ-Úá-ú]{2,}\.)(\d)"#,
                                   with: "$1 $2",
                                   options: .regularExpression)
        return s
    }

    private static func normalizeReferences(_ text: String) -> String {
        var s = normalizedReferenceCandidate(text)
        s = s.replacingOccurrences(of: "\u{00A0}", with: " ")
        s = s.replacingOccurrences(of: #"\s+"#, with: " ", options: .regularExpression)
        s = s.replacingOccurrences(of: #"\s+([,.;:])"#, with: "$1", options: .regularExpression)
        s = s.replacingOccurrences(of: #"\s*:\s*"#, with: ":", options: .regularExpression)
        s = s.replacingOccurrences(of: #"\s*;\s*"#, with: "; ", options: .regularExpression)
        s = s.replacingOccurrences(of: #"\s*,\s*"#, with: ", ", options: .regularExpression)
        s = s.replacingOccurrences(of: #"\s*-\s*"#, with: "-", options: .regularExpression)
        s = s.replacingOccurrences(of: #"([A-Za-zÁ-Úá-ú]{2,}\.)\s*(\d)"#,
                                   with: "$1 $2",
                                   options: .regularExpression)
        s = s.replacingOccurrences(of: #"\s{2,}"#, with: " ", options: .regularExpression)
        s = s.replacingOccurrences(of: #"[;,\.\s]+$"#, with: "", options: .regularExpression)
        return s.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
