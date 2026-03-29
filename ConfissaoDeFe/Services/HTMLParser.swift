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

        // Accumulate paragraphs per chapter
        var currentRoman = ""
        var currentTitle = ""
        var pendingParagraphs: [RawParagraph] = []

        func flush() {
            guard !currentRoman.isEmpty else { return }
            chapterCounter += 1
            let sections = buildSections(from: pendingParagraphs, chapterIndex: chapterCounter)
            chapters.append(Chapter(id: chapterCounter,
                                    romanNumeral: currentRoman,
                                    title: currentTitle,
                                    sections: sections))
            pendingParagraphs = []
        }

        for para in paragraphs {
            if para.alignment == "center", para.text.contains("CAPÍTULO"),
               let info = extractChapterInfo(from: para.text) {
                flush()
                currentRoman = info.roman
                currentTitle = info.title
            } else if !currentRoman.isEmpty, para.alignment == "justify" {
                pendingParagraphs.append(para)
            }
        }
        flush()
        return chapters
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

    // MARK: - Section Assembly

    private static func buildSections(from paragraphs: [RawParagraph],
                                      chapterIndex: Int) -> [Section] {
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
                    // Accumulate all reference paragraphs for this section
                    if refs.isEmpty {
                        refs = text
                    } else {
                        refs += " " + text
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
        // Matches Roman numerals 1-8 chars, followed by dot+space OR bare space before a word char
        try? NSRegularExpression(pattern: #"^([IVXLC]{1,8})(?:\.\s|\s+(?=[A-ZÁÉÍÓÚÂÊÔÃÕ]))"#)
    }()

    private static func extractSectionNumeral(from text: String) -> String? {
        guard let regex = sectionNumeralRegex else { return nil }
        let range = NSRange(text.startIndex..., in: text)
        guard let match = regex.firstMatch(in: text, range: range),
              let numRange = Range(match.range(at: 1), in: text) else { return nil }
        let candidate = String(text[numRange])
        // Guard against false positives: single "I" that starts a Bible reference pattern
        if looksLikeReferences(text) { return nil }
        return candidate
    }

    private static func removeSectionPrefix(from text: String, roman: String) -> String {
        var s = text
        // Remove "IV. " or "IV Pela" style prefixes
        if s.hasPrefix(roman + ". ") {
            s = String(s.dropFirst(roman.count + 2))
        } else if s.hasPrefix(roman + ".") {
            s = String(s.dropFirst(roman.count + 1)).trimmingCharacters(in: .whitespaces)
        } else if s.hasPrefix(roman + " ") {
            s = String(s.dropFirst(roman.count + 1))
        }
        return s.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    // MARK: - Bible Reference Detection

    private static let refPattern: NSRegularExpression? = {
        let books = "Gen|Gên|Êx|Exo|Lev|Lv|Num|Nm|Deut|Dt|Jos|Jl|Jz|Rut|Sam|Reis|Cr|Esd|Nee|Est|Jó|Sal|Prov|Pv|Ecl|Cânt|Isa|Is|Jer|Lam|Eze|Ez|Dan|Dn|Os|Ose|Joel|Am|Amos|Ob|Jon|Miq|Nau|Hab|Sof|Age|Zac|Mal|Mat|Mt|Mar|Mc|Luc|Lc|Jo|João|At|Atos|Rom|Cor|Gal|Ef|Fil|Col|Tess|Tim|Tito|Tt|File|Heb|Tia|Tiago|Ped|Pedro|Jud|Judas|Apoc|Ap"
        // Allow optional "I "/"II " prefix and period/comma/space between book and chapter number
        return try? NSRegularExpression(
            pattern: "(?:^|\\s)(?:I{1,2}\\s+)?(?:\(books))[.,;\\s]*\\d+\\s*[:\\.]",
            options: .caseInsensitive
        )
    }()

    static func looksLikeReferences(_ text: String) -> Bool {
        // Primary: regex match for Bible reference patterns
        if let regex = refPattern,
           regex.firstMatch(in: text, range: NSRange(text.startIndex..., in: text)) != nil {
            return true
        }
        // Secondary heuristic: multiple semicolons + chapter:verse patterns
        let semicolonCount = text.filter { $0 == ";" }.count
        let hasChapterVerse = text.range(of: #"\d+\s*:\s*\d+"#, options: .regularExpression) != nil
        return semicolonCount >= 2 && hasChapterVerse
    }
}
