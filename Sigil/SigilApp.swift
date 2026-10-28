import SwiftUI

final class SigilPreferences: ObservableObject {
    static let shared = SigilPreferences()

    @Published var themeName: String {
        didSet { UserDefaults.standard.set(themeName, forKey: "sigil.theme") }
    }
    @Published var fontSize: CGFloat {
        didSet { UserDefaults.standard.set(Double(fontSize), forKey: "sigil.fontSize") }
    }
    @Published var lineSpacing: CGFloat {
        didSet { UserDefaults.standard.set(Double(lineSpacing), forKey: "sigil.lineSpacing") }
    }
    @Published var textDirection: TextDirection {
        didSet { UserDefaults.standard.set(textDirection.rawValue, forKey: "sigil.textDirection") }
    }
    @Published var showToolbar: Bool {
        didSet { UserDefaults.standard.set(showToolbar, forKey: "sigil.showToolbar") }
    }

    private init() {
        self.themeName = UserDefaults.standard.string(forKey: "sigil.theme") ?? "Sigil"
        let storedSize = UserDefaults.standard.double(forKey: "sigil.fontSize")
        self.fontSize = storedSize > 0 ? CGFloat(storedSize) : 15
        let storedSpacing = UserDefaults.standard.double(forKey: "sigil.lineSpacing")
        self.lineSpacing = storedSpacing > 0 ? CGFloat(storedSpacing) : 1.4
        self.textDirection = TextDirection(rawValue: UserDefaults.standard.string(forKey: "sigil.textDirection") ?? "") ?? .auto
        self.showToolbar = UserDefaults.standard.object(forKey: "sigil.showToolbar") as? Bool ?? true
    }
}

@main
struct SigilApp: App {
    @StateObject private var prefs = SigilPreferences.shared

    var body: some Scene {
        DocumentGroup(newDocument: MarkdownDocument()) { file in
            ContentView(document: file.$document)
                .environmentObject(prefs)
                .onAppear {
                    // Close untitled blank windows on launch
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        for window in NSApplication.shared.windows {
                            if window.title == "" || window.title == "Untitled" {
                                window.close()
                            }
                        }
                    }
                }
        }
        .windowStyle(.titleBar)
        .defaultSize(width: 780, height: 920)
        .commands {
            CommandGroup(after: .toolbar) {
                Button(prefs.showToolbar ? "Hide Sigil Toolbar" : "Show Sigil Toolbar") {
                    withAnimation(.easeOut(duration: 0.2)) { prefs.showToolbar.toggle() }
                }
                .keyboardShortcut("t", modifiers: [.command, .shift])
            }
            CommandGroup(after: .textFormatting) {
                Divider()
                Menu("Theme") {
                    ForEach(SigilTheme.allThemes, id: \.name) { theme in
                        Button(theme.name) {
                            prefs.themeName = theme.name
                        }
                    }
                }
                Divider()
                Button("Increase Font Size") {
                    if prefs.fontSize < 28 { prefs.fontSize += 1 }
                }
                .keyboardShortcut("+", modifiers: .command)
                Button("Decrease Font Size") {
                    if prefs.fontSize > 10 { prefs.fontSize -= 1 }
                }
                .keyboardShortcut("-", modifiers: .command)
                Button("Reset Font Size") {
                    prefs.fontSize = 15
                }
                .keyboardShortcut("0", modifiers: .command)
            }
        }
    }
}
