import AppKit
import SwiftUI

extension Notification.Name {
    static let showYarzarAbout = Notification.Name("showYarzarAbout")
}

@main
struct YarzarApp: App {
    @ObservedObject private var lang = LanguageManager.shared
    @ObservedObject private var theme = ThemeManager.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .frame(minWidth: 920, minHeight: 620)
                .tint(YarzarTheme.emerald)
                .environment(\.locale, lang.locale)
                .preferredColorScheme(theme.colorScheme)
                .onAppear {
                    theme.applyAppearance()
                }
        }
        .windowStyle(.titleBar)
        .windowToolbarStyle(.unified)
        .commands {
            CommandGroup(replacing: .newItem) {}
            CommandGroup(replacing: .appInfo) {
                Button(L("About Yarzar")) {
                    NotificationCenter.default.post(name: .showYarzarAbout, object: nil)
                }
            }
            CommandMenu(L("Theme")) {
                Button(theme.currentTheme == .normal ? "✓ \(L("Normal Theme"))" : L("Normal Theme")) {
                    theme.setTheme(.normal)
                }
                Button(theme.currentTheme == .dark ? "✓ \(L("Dark Theme"))" : L("Dark Theme")) {
                    theme.setTheme(.dark)
                }
            }
            CommandMenu(L("Language")) {
                Button(lang.currentLanguage == "en" ? "✓ English" : "English") {
                    lang.setLanguage("en")
                }
                Button(lang.currentLanguage == "tr" ? "✓ Türkçe" : "Türkçe") {
                    lang.setLanguage("tr")
                }
            }
            CommandGroup(replacing: .help) {
                Button(L("User Guide")) {
                    NSWorkspace.shared.open(AppLinks.helpURL)
                }
            }
        }
    }
}
