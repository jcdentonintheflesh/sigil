import AppKit
import Foundation

enum TextDirection: String, CaseIterable {
    case auto, rtl, ltr

    var label: String {
        switch self {
        case .auto: return "Auto"
        case .rtl: return "RTL"
        case .ltr: return "LTR"
        }
    }
}

final class MarkdownRenderer {

    let theme: SigilTheme
    let fontSize: CGFloat
    let lineSpacing: CGFloat
    let direction: TextDirection

    // Track code block character ranges for background drawing
    var codeBlockRanges: [NSRange] = []

    init(theme: SigilTheme, fontSize: CGFloat = 15, lineSpacing: CGFloat = 1.4, direction: TextDirection = .auto) {
        self.theme = theme
        self.fontSize = fontSize
        self.lineSpacing = lineSpacing
        self.direction = direction
    }

    // MARK: - Main render

    func render(_ markdown: String) -> NSAttributedString {
        let result = NSMutableAttributedString()
        let lines = markdown.components(separatedBy: "\n")
        var i = 0

        while i < lines.count {
            let line = lines[i]

            // Blank line
            if line.trimmingCharacters(in: .whitespaces).isEmpty {
                result.append(styledString("\n", font: bodyFont, color: theme.bodyText))
                i += 1
                continue
            }

            // Fenced code block
            if line.trimmingCharacters(in: .whitespaces).hasPrefix("```") {
                i += 1
                var codeLines: [String] = []
                while i < lines.count && !lines[i].trimmingCharacters(in: .whitespaces).hasPrefix("```") {
                    codeLines.append(lines[i])
                    i += 1
                }
                if i < lines.count { i += 1 }
                let codeStart = result.length
                result.append(renderCodeBlock(codeLines.joined(separator: "\n")))
                let codeEnd = result.length
                codeBlockRanges.append(NSRange(location: codeStart, length: codeEnd - codeStart))
                result.append(styledString("\n", font: bodyFont, color: theme.bodyText))
                continue
            }

            // Horizontal rule
            let trimmed = line.trimmingCharacters(in: .whitespaces)
            if isHorizontalRule(trimmed) {
                result.append(renderHorizontalRule())
                i += 1
                continue
            }

            // Heading
            if let (level, text) = parseHeading(line) {
                result.append(renderHeading(text, level: level))
                result.append(styledString("\n", font: bodyFont, color: theme.bodyText))
                i += 1
                continue
            }

            // Blockquote
            if trimmed.hasPrefix(">") {
                var quoteLines: [String] = []
                while i < lines.count && lines[i].trimmingCharacters(in: .whitespaces).hasPrefix(">") {
                    let qLine = lines[i].trimmingCharacters(in: .whitespaces)
                    let stripped = String(qLine.dropFirst(qLine.hasPrefix("> ") ? 2 : 1))
                    quoteLines.append(stripped)
                    i += 1
                }
                result.append(renderBlockquote(quoteLines.joined(separator: "\n")))
                result.append(styledString("\n", font: bodyFont, color: theme.bodyText))
                continue
            }

            // Checkbox list item
            if let (indent, checked, text) = parseCheckbox(line) {
                result.append(renderCheckbox(text, indent: indent, checked: checked))
                result.append(styledString("\n", font: bodyFont, color: theme.bodyText))
                i += 1
                continue
            }

            // List item
            if let (indent, bullet, text) = parseListItem(line) {
                result.append(renderListItem(text, indent: indent, bullet: bullet))
                result.append(styledString("\n", font: bodyFont, color: theme.bodyText))
                i += 1
                continue
            }

            // Regular paragraph
            result.append(renderInline(line))
            result.append(styledString("\n", font: bodyFont, color: theme.bodyText))
            i += 1
        }

        applyWritingDirection(to: result)
        return result
    }

    // MARK: - Bidi

    /// Auto: paragraphs whose first strong character is from an RTL script become right-to-left;
    /// neutral paragraphs (blank lines, rules) inherit the previous direction.
    /// RTL forces every paragraph, LTR leaves everything as-is. Code blocks always stay LTR.
    private func applyWritingDirection(to result: NSMutableAttributedString) {
        if direction == .ltr { return }
        let ns = result.string as NSString
        var previousRTL = false
        ns.enumerateSubstrings(in: NSRange(location: 0, length: ns.length), options: [.byParagraphs, .substringNotRequired]) { _, _, enclosing, _ in
            if self.codeBlockRanges.contains(where: { NSIntersectionRange($0, enclosing).length > 0 }) {
                previousRTL = false
                return
            }
            let isRTL = self.direction == .rtl || (Self.isRightToLeft(ns.substring(with: enclosing)) ?? previousRTL)
            previousRTL = isRTL
            guard isRTL else { return }

            result.enumerateAttribute(.paragraphStyle, in: enclosing) { value, range, _ in
                let ps = (value as? NSParagraphStyle)?.mutableCopy() as? NSMutableParagraphStyle ?? self.bodyParagraphStyle()
                ps.baseWritingDirection = .rightToLeft
                result.addAttribute(.paragraphStyle, value: ps, range: range)
            }
        }
    }

    /// Direction of the first strongly-directional character, or nil if there is none.
    static func isRightToLeft(_ text: String) -> Bool? {
        for scalar in text.unicodeScalars {
            switch scalar.value {
            case 0x0590...0x08FF, 0xFB1D...0xFDFF, 0xFE70...0xFEFF:
                if scalar.properties.isAlphabetic { return true }
            default:
                if scalar.properties.isAlphabetic { return false }
            }
        }
        return nil
    }

    // MARK: - Convenience

    private var bodyFont: NSFont { theme.bodyFont(size: fontSize) }
    private var codeFont: NSFont { theme.codeFont(size: fontSize) }

    private func bodyParagraphStyle(extraBefore: CGFloat = 0, extraAfter: CGFloat = 0) -> NSMutableParagraphStyle {
        let ps = NSMutableParagraphStyle()
        ps.lineSpacing = (lineSpacing - 1.0) * fontSize
        ps.paragraphSpacingBefore = extraBefore
        ps.paragraphSpacing = extraAfter
        return ps
    }

    private func styledString(_ text: String, font: NSFont, color: NSColor, paragraphStyle: NSMutableParagraphStyle? = nil) -> NSAttributedString {
        var attrs: [NSAttributedString.Key: Any] = [.font: font, .foregroundColor: color]
        if let ps = paragraphStyle { attrs[.paragraphStyle] = ps }
        return NSAttributedString(string: text, attributes: attrs)
    }

    // MARK: - Block Renderers

    private func renderHeading(_ text: String, level: Int) -> NSAttributedString {
        let sizes: [Int: CGFloat] = [1: fontSize + 14, 2: fontSize + 10, 3: fontSize + 6, 4: fontSize + 3, 5: fontSize + 1, 6: fontSize]
        let size = sizes[level] ?? fontSize
        let font = theme.headingFont(size: size, level: level)

        let ps = NSMutableParagraphStyle()
        ps.paragraphSpacingBefore = level <= 2 ? 22 : 16
        ps.paragraphSpacing = 6
        ps.lineSpacing = 4

        let result = NSMutableAttributedString()
        result.append(renderInline(text, baseFont: font, baseColor: theme.headingText))

        // Apply paragraph style to entire heading
        result.addAttribute(.paragraphStyle, value: ps, range: NSRange(location: 0, length: result.length))

        // Add a subtle underline for h1
        if level == 1 {
            result.append(styledString("\n", font: font, color: theme.headingText))
            let rule = String(repeating: "━", count: 50)
            result.append(NSAttributedString(string: rule, attributes: [
                .font: NSFont.systemFont(ofSize: 8),
                .foregroundColor: theme.accentColor.withAlphaComponent(0.4)
            ]))
        }

        return result
    }

    private func renderCodeBlock(_ code: String) -> NSAttributedString {
        let ps = NSMutableParagraphStyle()
        ps.paragraphSpacingBefore = 4
        ps.paragraphSpacing = 4
        ps.lineSpacing = 1
        ps.firstLineHeadIndent = 12
        ps.headIndent = 12

        return NSAttributedString(string: code, attributes: [
            .font: codeFont,
            .foregroundColor: theme.codeText,
            .paragraphStyle: ps
        ])
    }

    private func renderBlockquote(_ text: String) -> NSAttributedString {
        let ps = NSMutableParagraphStyle()
        ps.headIndent = 24
        ps.firstLineHeadIndent = 4
        ps.paragraphSpacingBefore = 6
        ps.lineSpacing = (lineSpacing - 1.0) * fontSize

        let result = NSMutableAttributedString()
        result.append(NSAttributedString(string: "┃ ", attributes: [
            .font: bodyFont,
            .foregroundColor: theme.blockquoteBorder
        ]))
        result.append(NSAttributedString(string: text, attributes: [
            .font: NSFont.systemFont(ofSize: fontSize, weight: .light),
            .foregroundColor: theme.blockquoteText,
            .paragraphStyle: ps
        ]))
        return result
    }

    private func renderListItem(_ text: String, indent: Int, bullet: String) -> NSAttributedString {
        let ps = bodyParagraphStyle()
        let indentPts = CGFloat(indent) * 20 + 24
        ps.headIndent = indentPts
        ps.firstLineHeadIndent = indentPts - 18

        let prefix: String
        if bullet == "-" || bullet == "*" || bullet == "+" {
            let bullets = ["•", "◦", "▸"]
            prefix = bullets[min(indent, bullets.count - 1)] + "  "
        } else {
            prefix = bullet + " "
        }

        let result = NSMutableAttributedString(string: prefix, attributes: [
            .font: bodyFont,
            .foregroundColor: theme.accentColor,
            .paragraphStyle: ps
        ])
        result.append(renderInline(text))
        return result
    }

    private func renderCheckbox(_ text: String, indent: Int, checked: Bool) -> NSAttributedString {
        let ps = bodyParagraphStyle()
        let indentPts = CGFloat(indent) * 20 + 24
        ps.headIndent = indentPts
        ps.firstLineHeadIndent = indentPts - 18

        let box = checked ? "☑ " : "☐ "
        let boxColor = checked ? theme.accentColor : theme.blockquoteText

        let result = NSMutableAttributedString(string: box, attributes: [
            .font: bodyFont,
            .foregroundColor: boxColor,
            .paragraphStyle: ps
        ])

        let textColor = checked ? theme.blockquoteText : theme.bodyText
        result.append(renderInline(text, baseColor: textColor))

        if checked {
            result.addAttribute(.strikethroughStyle, value: NSUnderlineStyle.single.rawValue,
                              range: NSRange(location: box.count, length: result.length - box.count))
        }

        return result
    }

    private func renderHorizontalRule() -> NSAttributedString {
        let ps = NSMutableParagraphStyle()
        ps.paragraphSpacingBefore = 14
        ps.paragraphSpacing = 14
        ps.alignment = .center

        let rule = String(repeating: "─", count: 40)
        return NSAttributedString(string: rule + "\n", attributes: [
            .font: NSFont.systemFont(ofSize: 9),
            .foregroundColor: theme.hrColor,
            .paragraphStyle: ps
        ])
    }

    // MARK: - Inline Rendering

    func renderInline(_ text: String, baseFont: NSFont? = nil, baseColor: NSColor? = nil) -> NSAttributedString {
        let font = baseFont ?? bodyFont
        let color = baseColor ?? theme.bodyText
        let result = NSMutableAttributedString()
        var remaining = text[text.startIndex...]

        while !remaining.isEmpty {
            // Inline code
            if remaining.hasPrefix("`") {
                if let endIdx = remaining.dropFirst().firstIndex(of: "`") {
                    let code = String(remaining[remaining.index(after: remaining.startIndex)..<endIdx])
                    result.append(NSAttributedString(string: "\u{2009}" + code + "\u{2009}", attributes: [
                        .font: codeFont,
                        .foregroundColor: theme.codeText,
                        .backgroundColor: theme.codeBackground
                    ]))
                    remaining = remaining[remaining.index(after: endIdx)...]
                    continue
                }
            }

            // Bold + Italic
            if remaining.hasPrefix("***") || remaining.hasPrefix("___") {
                let marker = String(remaining.prefix(3))
                let rest = remaining.dropFirst(3)
                if let range = rest.range(of: marker) {
                    let inner = String(rest[rest.startIndex..<range.lowerBound])
                    let biFont = NSFontManager.shared.convert(font, toHaveTrait: [.boldFontMask, .italicFontMask])
                    result.append(NSAttributedString(string: inner, attributes: [.font: biFont, .foregroundColor: color]))
                    remaining = rest[range.upperBound...]
                    continue
                }
            }

            // Bold
            if remaining.hasPrefix("**") || remaining.hasPrefix("__") {
                let marker = String(remaining.prefix(2))
                let rest = remaining.dropFirst(2)
                if let range = rest.range(of: marker) {
                    let inner = String(rest[rest.startIndex..<range.lowerBound])
                    let boldFont = NSFontManager.shared.convert(font, toHaveTrait: .boldFontMask)
                    result.append(NSAttributedString(string: inner, attributes: [.font: boldFont, .foregroundColor: color]))
                    remaining = rest[range.upperBound...]
                    continue
                }
            }

            // Italic
            if remaining.hasPrefix("*") || remaining.hasPrefix("_") {
                let marker = String(remaining.prefix(1))
                let rest = remaining.dropFirst(1)
                if let range = rest.range(of: marker) {
                    let inner = String(rest[rest.startIndex..<range.lowerBound])
                    if !inner.isEmpty && (marker == "*" || !inner.contains(" ")) {
                        let italicFont = NSFontManager.shared.convert(font, toHaveTrait: .italicFontMask)
                        result.append(NSAttributedString(string: inner, attributes: [.font: italicFont, .foregroundColor: color]))
                        remaining = rest[range.upperBound...]
                        continue
                    }
                }
            }

            // Strikethrough
            if remaining.hasPrefix("~~") {
                let rest = remaining.dropFirst(2)
                if let range = rest.range(of: "~~") {
                    let inner = String(rest[rest.startIndex..<range.lowerBound])
                    result.append(NSAttributedString(string: inner, attributes: [
                        .font: font, .foregroundColor: color,
                        .strikethroughStyle: NSUnderlineStyle.single.rawValue
                    ]))
                    remaining = rest[range.upperBound...]
                    continue
                }
            }

            // Link
            if remaining.hasPrefix("[") {
                let rest = remaining.dropFirst()
                if let closeBracket = rest.firstIndex(of: "]") {
                    let linkText = String(rest[rest.startIndex..<closeBracket])
                    let afterBracket = rest[rest.index(after: closeBracket)...]
                    if afterBracket.hasPrefix("(") {
                        let parenContent = afterBracket.dropFirst()
                        if let closeParen = parenContent.firstIndex(of: ")") {
                            let url = String(parenContent[parenContent.startIndex..<closeParen])
                            var attrs: [NSAttributedString.Key: Any] = [
                                .font: font,
                                .foregroundColor: theme.linkColor,
                                .underlineStyle: NSUnderlineStyle.single.rawValue
                            ]
                            if let linkURL = URL(string: url) { attrs[.link] = linkURL }
                            result.append(NSAttributedString(string: linkText, attributes: attrs))
                            remaining = parenContent[parenContent.index(after: closeParen)...]
                            continue
                        }
                    }
                }
            }

            // Plain character
            let char = remaining[remaining.startIndex]
            result.append(NSAttributedString(string: String(char), attributes: [.font: font, .foregroundColor: color]))
            remaining = remaining[remaining.index(after: remaining.startIndex)...]
        }

        return result
    }

    // MARK: - Parsers

    private func parseHeading(_ line: String) -> (Int, String)? {
        let trimmed = line.trimmingCharacters(in: .whitespaces)
        var level = 0
        for char in trimmed {
            if char == "#" { level += 1 } else { break }
        }
        guard level >= 1 && level <= 6 else { return nil }
        let rest = trimmed.dropFirst(level)
        guard rest.first == " " else { return nil }
        return (level, String(rest.dropFirst()))
    }

    private func parseListItem(_ line: String) -> (Int, String, String)? {
        let indent = line.prefix(while: { $0 == " " || $0 == "\t" }).count / 2
        let trimmed = line.trimmingCharacters(in: .whitespaces)

        if trimmed.hasPrefix("- ") || trimmed.hasPrefix("* ") || trimmed.hasPrefix("+ ") {
            return (indent, String(trimmed.prefix(1)), String(trimmed.dropFirst(2)))
        }

        let digits = trimmed.prefix(while: { $0.isNumber })
        if !digits.isEmpty {
            let rest = trimmed.dropFirst(digits.count)
            if rest.hasPrefix(". ") {
                return (indent, String(digits) + ".", String(rest.dropFirst(2)))
            }
        }
        return nil
    }

    private func parseCheckbox(_ line: String) -> (Int, Bool, String)? {
        let indent = line.prefix(while: { $0 == " " || $0 == "\t" }).count / 2
        let trimmed = line.trimmingCharacters(in: .whitespaces)

        if trimmed.hasPrefix("- [x] ") || trimmed.hasPrefix("- [X] ") {
            return (indent, true, String(trimmed.dropFirst(6)))
        }
        if trimmed.hasPrefix("- [ ] ") {
            return (indent, false, String(trimmed.dropFirst(6)))
        }
        return nil
    }

    private func isHorizontalRule(_ trimmed: String) -> Bool {
        trimmed.count >= 3 && (
            trimmed.allSatisfy({ $0 == "-" || $0 == " " }) ||
            trimmed.allSatisfy({ $0 == "*" || $0 == " " }) ||
            trimmed.allSatisfy({ $0 == "_" || $0 == " " })
        ) && trimmed.filter({ $0 != " " }).count >= 3
    }
}

// MARK: - Pasteboard

extension NSAttributedString {
    /// Writes HTML (with dir="rtl" per paragraph), RTF and plain text. Theme colors are
    /// stripped so dark-theme text doesn't paste as white-on-white into mail clients.
    func writeForPasting(to pasteboard: NSPasteboard = .general) {
        let copy = NSMutableAttributedString(attributedString: self)
        let full = NSRange(location: 0, length: copy.length)
        copy.removeAttribute(.foregroundColor, range: full)
        copy.removeAttribute(.backgroundColor, range: full)

        pasteboard.clearContents()
        if let html = try? copy.data(from: full, documentAttributes: [.documentType: NSAttributedString.DocumentType.html]) {
            pasteboard.setData(html, forType: .html)
        }
        if let rtf = copy.rtf(from: full) {
            pasteboard.setData(rtf, forType: .rtf)
        }
        pasteboard.setString(copy.string, forType: .string)
    }
}
