import AppKit

struct SigilTheme {
    let name: String
    let background: NSColor
    let bodyText: NSColor
    let headingText: NSColor
    let accentColor: NSColor
    let codeText: NSColor
    let codeBackground: NSColor
    let blockquoteText: NSColor
    let blockquoteBorder: NSColor
    let linkColor: NSColor
    let hrColor: NSColor
    let cursorColor: NSColor
    let selectionColor: NSColor

    // MARK: - Built-in Themes

    static let allThemes: [SigilTheme] = [neon, obsidian, nord, parchment, paper, terminal]

    static func named(_ name: String) -> SigilTheme {
        allThemes.first(where: { $0.name == name }) ?? neon
    }

    // Neon — cyberpunk default, dark bg with electric accents
    static let neon = SigilTheme(
        name: "Neon",
        background: NSColor(srgbRed: 0.06, green: 0.06, blue: 0.09, alpha: 1),
        bodyText: NSColor(srgbRed: 0.80, green: 0.82, blue: 0.86, alpha: 1),
        headingText: NSColor(srgbRed: 0.55, green: 0.85, blue: 1.0, alpha: 1),
        accentColor: NSColor(srgbRed: 1.0, green: 0.30, blue: 0.55, alpha: 1),
        codeText: NSColor(srgbRed: 0.40, green: 0.95, blue: 0.55, alpha: 1),
        codeBackground: NSColor(srgbRed: 0.10, green: 0.10, blue: 0.14, alpha: 1),
        blockquoteText: NSColor(srgbRed: 0.55, green: 0.55, blue: 0.65, alpha: 1),
        blockquoteBorder: NSColor(srgbRed: 1.0, green: 0.30, blue: 0.55, alpha: 0.5),
        linkColor: NSColor(srgbRed: 0.55, green: 0.85, blue: 1.0, alpha: 1),
        hrColor: NSColor(srgbRed: 0.20, green: 0.20, blue: 0.28, alpha: 1),
        cursorColor: NSColor(srgbRed: 1.0, green: 0.30, blue: 0.55, alpha: 1),
        selectionColor: NSColor(srgbRed: 0.55, green: 0.85, blue: 1.0, alpha: 0.2)
    )

    // Obsidian — deep charcoal, muted purples
    static let obsidian = SigilTheme(
        name: "Obsidian",
        background: NSColor(srgbRed: 0.10, green: 0.10, blue: 0.12, alpha: 1),
        bodyText: NSColor(srgbRed: 0.78, green: 0.78, blue: 0.82, alpha: 1),
        headingText: NSColor(srgbRed: 0.88, green: 0.88, blue: 0.92, alpha: 1),
        accentColor: NSColor(srgbRed: 0.65, green: 0.50, blue: 0.90, alpha: 1),
        codeText: NSColor(srgbRed: 0.60, green: 0.80, blue: 0.60, alpha: 1),
        codeBackground: NSColor(srgbRed: 0.14, green: 0.14, blue: 0.16, alpha: 1),
        blockquoteText: NSColor(srgbRed: 0.55, green: 0.55, blue: 0.60, alpha: 1),
        blockquoteBorder: NSColor(srgbRed: 0.65, green: 0.50, blue: 0.90, alpha: 0.4),
        linkColor: NSColor(srgbRed: 0.65, green: 0.50, blue: 0.90, alpha: 1),
        hrColor: NSColor(srgbRed: 0.22, green: 0.22, blue: 0.26, alpha: 1),
        cursorColor: NSColor(srgbRed: 0.65, green: 0.50, blue: 0.90, alpha: 1),
        selectionColor: NSColor(srgbRed: 0.65, green: 0.50, blue: 0.90, alpha: 0.2)
    )

    // Nord — cool arctic blues
    static let nord = SigilTheme(
        name: "Nord",
        background: NSColor(srgbRed: 0.18, green: 0.20, blue: 0.25, alpha: 1),
        bodyText: NSColor(srgbRed: 0.85, green: 0.87, blue: 0.91, alpha: 1),
        headingText: NSColor(srgbRed: 0.56, green: 0.74, blue: 0.73, alpha: 1),
        accentColor: NSColor(srgbRed: 0.75, green: 0.38, blue: 0.42, alpha: 1),
        codeText: NSColor(srgbRed: 0.64, green: 0.75, blue: 0.55, alpha: 1),
        codeBackground: NSColor(srgbRed: 0.22, green: 0.24, blue: 0.30, alpha: 1),
        blockquoteText: NSColor(srgbRed: 0.62, green: 0.65, blue: 0.72, alpha: 1),
        blockquoteBorder: NSColor(srgbRed: 0.56, green: 0.74, blue: 0.73, alpha: 0.4),
        linkColor: NSColor(srgbRed: 0.51, green: 0.63, blue: 0.76, alpha: 1),
        hrColor: NSColor(srgbRed: 0.30, green: 0.33, blue: 0.39, alpha: 1),
        cursorColor: NSColor(srgbRed: 0.56, green: 0.74, blue: 0.73, alpha: 1),
        selectionColor: NSColor(srgbRed: 0.56, green: 0.74, blue: 0.73, alpha: 0.2)
    )

    // Parchment — warm sepia, like aged paper
    static let parchment = SigilTheme(
        name: "Parchment",
        background: NSColor(srgbRed: 0.96, green: 0.93, blue: 0.87, alpha: 1),
        bodyText: NSColor(srgbRed: 0.22, green: 0.20, blue: 0.17, alpha: 1),
        headingText: NSColor(srgbRed: 0.35, green: 0.18, blue: 0.10, alpha: 1),
        accentColor: NSColor(srgbRed: 0.65, green: 0.30, blue: 0.15, alpha: 1),
        codeText: NSColor(srgbRed: 0.35, green: 0.45, blue: 0.30, alpha: 1),
        codeBackground: NSColor(srgbRed: 0.92, green: 0.88, blue: 0.82, alpha: 1),
        blockquoteText: NSColor(srgbRed: 0.45, green: 0.40, blue: 0.35, alpha: 1),
        blockquoteBorder: NSColor(srgbRed: 0.65, green: 0.30, blue: 0.15, alpha: 0.4),
        linkColor: NSColor(srgbRed: 0.45, green: 0.30, blue: 0.60, alpha: 1),
        hrColor: NSColor(srgbRed: 0.80, green: 0.75, blue: 0.68, alpha: 1),
        cursorColor: NSColor(srgbRed: 0.35, green: 0.18, blue: 0.10, alpha: 1),
        selectionColor: NSColor(srgbRed: 0.65, green: 0.30, blue: 0.15, alpha: 0.15)
    )

    // Paper — clean white, minimal
    static let paper = SigilTheme(
        name: "Paper",
        background: NSColor(srgbRed: 1.0, green: 1.0, blue: 1.0, alpha: 1),
        bodyText: NSColor(srgbRed: 0.13, green: 0.13, blue: 0.15, alpha: 1),
        headingText: NSColor(srgbRed: 0.05, green: 0.05, blue: 0.08, alpha: 1),
        accentColor: NSColor(srgbRed: 0.20, green: 0.40, blue: 0.75, alpha: 1),
        codeText: NSColor(srgbRed: 0.75, green: 0.22, blue: 0.17, alpha: 1),
        codeBackground: NSColor(srgbRed: 0.95, green: 0.96, blue: 0.97, alpha: 1),
        blockquoteText: NSColor(srgbRed: 0.40, green: 0.40, blue: 0.45, alpha: 1),
        blockquoteBorder: NSColor(srgbRed: 0.20, green: 0.40, blue: 0.75, alpha: 0.3),
        linkColor: NSColor(srgbRed: 0.20, green: 0.40, blue: 0.75, alpha: 1),
        hrColor: NSColor(srgbRed: 0.85, green: 0.85, blue: 0.87, alpha: 1),
        cursorColor: NSColor(srgbRed: 0.20, green: 0.40, blue: 0.75, alpha: 1),
        selectionColor: NSColor(srgbRed: 0.20, green: 0.40, blue: 0.75, alpha: 0.15)
    )

    // Terminal — green on black
    static let terminal = SigilTheme(
        name: "Terminal",
        background: NSColor(srgbRed: 0.0, green: 0.0, blue: 0.0, alpha: 1),
        bodyText: NSColor(srgbRed: 0.0, green: 0.80, blue: 0.0, alpha: 1),
        headingText: NSColor(srgbRed: 0.0, green: 1.0, blue: 0.0, alpha: 1),
        accentColor: NSColor(srgbRed: 0.0, green: 1.0, blue: 0.0, alpha: 1),
        codeText: NSColor(srgbRed: 0.0, green: 0.90, blue: 0.45, alpha: 1),
        codeBackground: NSColor(srgbRed: 0.05, green: 0.08, blue: 0.05, alpha: 1),
        blockquoteText: NSColor(srgbRed: 0.0, green: 0.55, blue: 0.0, alpha: 1),
        blockquoteBorder: NSColor(srgbRed: 0.0, green: 0.60, blue: 0.0, alpha: 0.5),
        linkColor: NSColor(srgbRed: 0.30, green: 0.90, blue: 1.0, alpha: 1),
        hrColor: NSColor(srgbRed: 0.0, green: 0.30, blue: 0.0, alpha: 1),
        cursorColor: NSColor(srgbRed: 0.0, green: 1.0, blue: 0.0, alpha: 1),
        selectionColor: NSColor(srgbRed: 0.0, green: 0.80, blue: 0.0, alpha: 0.2)
    )

    // MARK: - Font helpers

    func bodyFont(size: CGFloat) -> NSFont {
        NSFont.systemFont(ofSize: size, weight: .regular)
    }

    func headingFont(size: CGFloat, level: Int) -> NSFont {
        NSFont.systemFont(ofSize: size, weight: level <= 2 ? .bold : .semibold)
    }

    func codeFont(size: CGFloat) -> NSFont {
        NSFont.monospacedSystemFont(ofSize: size - 1.5, weight: .regular)
    }
}
