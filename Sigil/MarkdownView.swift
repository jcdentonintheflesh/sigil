import SwiftUI
import AppKit

struct ContentView: View {
    @Binding var document: MarkdownDocument
    @EnvironmentObject var prefs: SigilPreferences
    @State private var isEditing = false
    @State private var showBar = true
    @State private var fontSizeText: String = ""

    private var currentTheme: SigilTheme {
        SigilTheme.named(prefs.themeName)
    }

    var body: some View {
        VStack(spacing: 0) {
            // Fixed top bar
            if showBar {
                controlBar
            }

            // Main content
            Group {
                if isEditing {
                    EditorTextView(text: $document.text, theme: currentTheme, fontSize: prefs.fontSize)
                } else {
                    PreviewTextView(
                        markdown: document.text,
                        theme: currentTheme,
                        fontSize: prefs.fontSize,
                        lineSpacing: prefs.lineSpacing
                    )
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .background(Color(currentTheme.background))
        .onAppear {
            fontSizeText = "\(Int(prefs.fontSize))"
        }
        .onChange(of: prefs.fontSize) { newVal in
            fontSizeText = "\(Int(newVal))"
        }
    }

    // MARK: - Control bar

    private var controlBar: some View {
        HStack(spacing: 10) {
            // Theme picker
            Picker("", selection: $prefs.themeName) {
                ForEach(SigilTheme.allThemes, id: \.name) { theme in
                    Text(theme.name).tag(theme.name)
                }
            }
            .pickerStyle(.menu)
            .frame(width: 110)
            .colorScheme(.dark)

            divider

            // Font size: - / field / presets / +
            Button(action: { if prefs.fontSize > 10 { prefs.fontSize -= 1 } }) {
                Image(systemName: "minus")
                    .font(.system(size: 10, weight: .bold))
                    .frame(width: 20, height: 20)
            }
            .buttonStyle(.plain)
            .foregroundColor(.white.opacity(0.6))

            // Editable text field
            TextField("", text: $fontSizeText, onCommit: {
                if let val = Int(fontSizeText), val >= 10, val <= 36 {
                    prefs.fontSize = CGFloat(val)
                } else {
                    fontSizeText = "\(Int(prefs.fontSize))"
                }
            })
            .textFieldStyle(.plain)
            .font(.system(size: 11, weight: .medium, design: .monospaced))
            .foregroundColor(.white.opacity(0.8))
            .multilineTextAlignment(.center)
            .frame(width: 28)
            .padding(.horizontal, 4)
            .padding(.vertical, 3)
            .background(Color.white.opacity(0.08))
            .cornerRadius(4)

            Button(action: { if prefs.fontSize < 36 { prefs.fontSize += 1 } }) {
                Image(systemName: "plus")
                    .font(.system(size: 10, weight: .bold))
                    .frame(width: 20, height: 20)
            }
            .buttonStyle(.plain)
            .foregroundColor(.white.opacity(0.6))

            // Preset sizes
            presetMenu

            divider

            // Line spacing with +/- and presets
            Image(systemName: "text.line.spacing")
                .font(.system(size: 11))
                .foregroundColor(.white.opacity(0.45))

            Button(action: { adjustLineSpacing(-0.1) }) {
                Image(systemName: "minus")
                    .font(.system(size: 9, weight: .bold))
                    .frame(width: 16, height: 16)
            }
            .buttonStyle(.plain)
            .foregroundColor(.white.opacity(0.6))

            Text(String(format: "%.1f", prefs.lineSpacing))
                .font(.system(size: 11, weight: .medium, design: .monospaced))
                .foregroundColor(.white.opacity(0.6))
                .frame(width: 24)

            Button(action: { adjustLineSpacing(0.1) }) {
                Image(systemName: "plus")
                    .font(.system(size: 9, weight: .bold))
                    .frame(width: 16, height: 16)
            }
            .buttonStyle(.plain)
            .foregroundColor(.white.opacity(0.6))

            lineSpacingPresetMenu

            Spacer()

            // Edit/Preview toggle
            Button(action: { isEditing.toggle() }) {
                HStack(spacing: 5) {
                    Image(systemName: isEditing ? "eye.fill" : "pencil")
                        .font(.system(size: 11, weight: .medium))
                    Text(isEditing ? "Preview" : "Edit")
                        .font(.system(size: 11, weight: .medium))
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 5)
                .background(Color.white.opacity(0.10))
                .cornerRadius(5)
            }
            .buttonStyle(.plain)
            .foregroundColor(.white.opacity(0.8))

            divider

            // Hide bar button
            Button(action: { withAnimation(.easeOut(duration: 0.2)) { showBar = false } }) {
                Image(systemName: "chevron.up")
                    .font(.system(size: 10, weight: .bold))
                    .frame(width: 20, height: 20)
            }
            .buttonStyle(.plain)
            .foregroundColor(.white.opacity(0.4))
            .help("Hide toolbar (Cmd+Shift+T to show)")
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .background(Color(red: 0.10, green: 0.10, blue: 0.13))
        .overlay(
            Rectangle()
                .frame(height: 1)
                .foregroundColor(Color.white.opacity(0.06)),
            alignment: .bottom
        )
    }

    // MARK: - Subviews

    private var divider: some View {
        Rectangle()
            .fill(.white.opacity(0.10))
            .frame(width: 1, height: 18)
    }

    private var presetMenu: some View {
        Menu {
            ForEach([12, 14, 15, 16, 18, 20, 24, 28], id: \.self) { size in
                Button("\(size) pt\(size == 15 ? "  (default)" : "")") {
                    prefs.fontSize = CGFloat(size)
                }
            }
        } label: {
            Image(systemName: "textformat.size")
                .font(.system(size: 11))
                .foregroundColor(.white.opacity(0.5))
                .frame(width: 20, height: 20)
        }
        .menuStyle(.borderlessButton)
        .frame(width: 20)
    }

    private var lineSpacingPresetMenu: some View {
        Menu {
            ForEach([
                ("Tight", 1.0),
                ("Compact", 1.2),
                ("Default", 1.4),
                ("Relaxed", 1.6),
                ("Loose", 1.8),
                ("Double", 2.0)
            ], id: \.0) { label, value in
                Button("\(label)  (\(String(format: "%.1f", value)))") {
                    prefs.lineSpacing = value
                }
            }
        } label: {
            Image(systemName: "list.bullet")
                .font(.system(size: 10))
                .foregroundColor(.white.opacity(0.5))
                .frame(width: 20, height: 20)
        }
        .menuStyle(.borderlessButton)
        .frame(width: 20)
    }

    // MARK: - Helpers

    private func adjustLineSpacing(_ delta: CGFloat) {
        let newVal = prefs.lineSpacing + delta
        prefs.lineSpacing = min(2.5, max(0.8, (newVal * 10).rounded() / 10))
    }
}

// MARK: - Preview (rendered markdown)

class CodeBlockTextView: NSTextView {
    var codeBlockRanges: [NSRange] = []
    var codeBackground: NSColor = .darkGray
    var codeCornerRadius: CGFloat = 6

    override func drawBackground(in rect: NSRect) {
        // Draw the normal background first
        super.drawBackground(in: rect)

        // Then draw code block rounded rects on top of bg, before text
        guard let layoutManager = self.layoutManager,
              let textContainer = self.textContainer else { return }

        let origin = textContainerOrigin
        let inset = textContainerInset

        for range in codeBlockRanges {
            let glyphRange = layoutManager.glyphRange(forCharacterRange: range, actualCharacterRange: nil)
            let boundingRect = layoutManager.boundingRect(forGlyphRange: glyphRange, in: textContainer)
            let drawRect = NSRect(
                x: inset.width + 8,
                y: boundingRect.origin.y + origin.y - 8,
                width: bounds.width - inset.width * 2 - 16,
                height: boundingRect.height + 16
            )

            let path = NSBezierPath(roundedRect: drawRect, xRadius: codeCornerRadius, yRadius: codeCornerRadius)
            codeBackground.setFill()
            path.fill()
        }
    }
}

struct PreviewTextView: NSViewRepresentable {
    let markdown: String
    let theme: SigilTheme
    let fontSize: CGFloat
    let lineSpacing: CGFloat

    func makeNSView(context: Context) -> NSScrollView {
        let scrollView = NSScrollView()
        scrollView.hasVerticalScroller = true
        scrollView.hasHorizontalScroller = false
        scrollView.autohidesScrollers = true
        scrollView.scrollerStyle = .overlay
        scrollView.drawsBackground = false

        let textContainer = NSTextContainer()
        textContainer.widthTracksTextView = true

        let layoutManager = NSLayoutManager()
        layoutManager.addTextContainer(textContainer)

        let textStorage = NSTextStorage()
        textStorage.addLayoutManager(layoutManager)

        let textView = CodeBlockTextView(frame: .zero, textContainer: textContainer)
        textView.isEditable = false
        textView.isSelectable = true
        textView.drawsBackground = true
        textView.textContainerInset = NSSize(width: 48, height: 36)
        textView.isAutomaticLinkDetectionEnabled = true
        textView.isRichText = true
        textView.autoresizingMask = [.width]
        textView.isVerticallyResizable = true
        textView.isHorizontallyResizable = false

        scrollView.documentView = textView

        applyContent(to: textView)
        return scrollView
    }

    func updateNSView(_ scrollView: NSScrollView, context: Context) {
        guard let textView = scrollView.documentView as? CodeBlockTextView else { return }
        applyContent(to: textView)
    }

    private func applyContent(to textView: CodeBlockTextView) {
        textView.backgroundColor = theme.background
        let renderer = MarkdownRenderer(theme: theme, fontSize: fontSize, lineSpacing: lineSpacing)
        let rendered = renderer.render(markdown)
        textView.textStorage?.setAttributedString(rendered)
        textView.codeBlockRanges = renderer.codeBlockRanges
        textView.codeBackground = theme.codeBackground
        textView.needsDisplay = true
    }
}

// MARK: - Editor (raw markdown with syntax tinting)

struct EditorTextView: NSViewRepresentable {
    @Binding var text: String
    let theme: SigilTheme
    let fontSize: CGFloat

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    func makeNSView(context: Context) -> NSScrollView {
        let scrollView = NSTextView.scrollableTextView()
        let textView = scrollView.documentView as! NSTextView

        textView.isEditable = true
        textView.isSelectable = true
        textView.drawsBackground = true
        textView.textContainerInset = NSSize(width: 48, height: 36)
        textView.isRichText = false
        textView.allowsUndo = true
        textView.isAutomaticQuoteSubstitutionEnabled = false
        textView.isAutomaticDashSubstitutionEnabled = false
        textView.isAutomaticTextReplacementEnabled = false
        textView.isAutomaticSpellingCorrectionEnabled = false
        textView.textContainer?.widthTracksTextView = true
        textView.usesFindBar = true

        textView.insertionPointColor = theme.cursorColor
        textView.selectedTextAttributes = [
            .backgroundColor: theme.selectionColor,
            .foregroundColor: theme.bodyText
        ]

        scrollView.hasVerticalScroller = true
        scrollView.hasHorizontalScroller = false
        scrollView.autohidesScrollers = true
        scrollView.scrollerStyle = .overlay
        scrollView.drawsBackground = false

        textView.delegate = context.coordinator
        applyContent(to: textView)

        return scrollView
    }

    func updateNSView(_ scrollView: NSScrollView, context: Context) {
        guard let textView = scrollView.documentView as? NSTextView else { return }

        textView.backgroundColor = theme.background
        textView.insertionPointColor = theme.cursorColor
        textView.selectedTextAttributes = [
            .backgroundColor: theme.selectionColor,
            .foregroundColor: theme.bodyText
        ]

        if textView.string != text {
            applyContent(to: textView)
        } else {
            applySyntaxTint(to: textView)
        }
    }

    private func applyContent(to textView: NSTextView) {
        textView.string = text
        applySyntaxTint(to: textView)
    }

    private func applySyntaxTint(to textView: NSTextView) {
        let storage = textView.textStorage!
        let fullRange = NSRange(location: 0, length: storage.length)
        let font = theme.bodyFont(size: fontSize)
        let codeFont = theme.codeFont(size: fontSize)

        storage.beginEditing()
        storage.addAttribute(.font, value: font, range: fullRange)
        storage.addAttribute(.foregroundColor, value: theme.bodyText, range: fullRange)

        let text = storage.string

        tint(text: text, storage: storage, pattern: "^#{1,6}\\s.+$", color: theme.headingText, font: NSFont.systemFont(ofSize: fontSize, weight: .bold))
        tint(text: text, storage: storage, pattern: "\\*\\*[^*]+\\*\\*", color: theme.bodyText, font: NSFontManager.shared.convert(font, toHaveTrait: .boldFontMask))
        tint(text: text, storage: storage, pattern: "__[^_]+__", color: theme.bodyText, font: NSFontManager.shared.convert(font, toHaveTrait: .boldFontMask))
        tint(text: text, storage: storage, pattern: "(?<![*])\\*[^*]+\\*(?![*])", color: theme.bodyText, font: NSFontManager.shared.convert(font, toHaveTrait: .italicFontMask))
        tint(text: text, storage: storage, pattern: "```[\\s\\S]*?```", color: theme.codeText, font: codeFont)
        tint(text: text, storage: storage, pattern: "`[^`]+`", color: theme.codeText, font: codeFont)
        tint(text: text, storage: storage, pattern: "\\[.+?\\]\\(.+?\\)", color: theme.linkColor, font: nil)
        tint(text: text, storage: storage, pattern: "^>\\s?.+$", color: theme.blockquoteText, font: nil)
        tint(text: text, storage: storage, pattern: "^\\s*[-*+]\\s", color: theme.accentColor, font: nil)
        tint(text: text, storage: storage, pattern: "^\\s*\\d+\\.\\s", color: theme.accentColor, font: nil)

        storage.endEditing()
    }

    private func tint(text: String, storage: NSTextStorage, pattern: String, color: NSColor, font: NSFont?) {
        guard let regex = try? NSRegularExpression(pattern: pattern, options: [.anchorsMatchLines]) else { return }
        let fullRange = NSRange(location: 0, length: (text as NSString).length)
        for match in regex.matches(in: text, range: fullRange) {
            storage.addAttribute(.foregroundColor, value: color, range: match.range)
            if let font = font {
                storage.addAttribute(.font, value: font, range: match.range)
            }
        }
    }

    class Coordinator: NSObject, NSTextViewDelegate {
        var parent: EditorTextView

        init(_ parent: EditorTextView) {
            self.parent = parent
        }

        func textDidChange(_ notification: Notification) {
            guard let textView = notification.object as? NSTextView else { return }
            parent.text = textView.string
        }
    }
}
