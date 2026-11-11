import AppKit
import Combine
import SwiftUI

enum AppThemeMode: String, CaseIterable, Identifiable {
    case normal = "normal"
    case dark = "dark"

    var id: String { rawValue }

    var colorScheme: ColorScheme {
        switch self {
        case .normal: return .light
        case .dark: return .dark
        }
    }

    var nsAppearanceName: NSAppearance.Name {
        switch self {
        case .normal: return .aqua
        case .dark: return .darkAqua
        }
    }
}

final class ThemeManager: ObservableObject {
    static let shared = ThemeManager()

    @Published private(set) var currentTheme: AppThemeMode

    private let storageKey = "yarzarThemeMode"

    private init() {
        if let saved = UserDefaults.standard.string(forKey: storageKey),
           let mode = AppThemeMode(rawValue: saved) {
            currentTheme = mode
        } else {
            let isSystemDark = NSApplication.shared.effectiveAppearance.bestMatch(from: [.darkAqua, .aqua]) == .darkAqua
            currentTheme = isSystemDark ? .dark : .normal
        }
        DispatchQueue.main.async { [weak self] in
            self?.applyAppearance()
        }
    }

    var isDark: Bool {
        currentTheme == .dark
    }

    var colorScheme: ColorScheme {
        currentTheme.colorScheme
    }

    func setTheme(_ mode: AppThemeMode) {
        guard currentTheme != mode else {
            applyAppearance()
            return
        }
        currentTheme = mode
        UserDefaults.standard.set(mode.rawValue, forKey: storageKey)
        applyAppearance()
    }

    func toggleTheme() {
        setTheme(currentTheme == .dark ? .normal : .dark)
    }

    func applyAppearance() {
        let appearance = NSAppearance(named: currentTheme.nsAppearanceName)
        NSApp?.appearance = appearance
        for window in NSApp?.windows ?? [] {
            window.appearance = appearance
        }
    }
}

enum YarzarTheme {
    // Bio-intelligence brand colors
    static let emerald = Color(red: 0.063, green: 0.725, blue: 0.506)       // #10B981
    static let mintTeal = Color(red: 0.078, green: 0.722, blue: 0.651)      // #14B8A6
    static let limeGood = Color(red: 0.133, green: 0.773, blue: 0.369)      // #22C55E
    static let amberMediocre = Color(red: 0.961, green: 0.620, blue: 0.043) // #F59E0B
    static let crimsonPoor = Color(red: 0.937, green: 0.267, blue: 0.267)   // #EF4444
    static let clinicalCyan = Color(red: 0.024, green: 0.714, blue: 0.831)  // #06B6D4
    static let botanicalPurple = Color(red: 0.545, green: 0.361, blue: 0.965)

    static let brandGradient = LinearGradient(
        colors: [emerald, mintTeal],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let subtleHeaderGradient = LinearGradient(
        colors: [
            emerald.opacity(0.16),
            mintTeal.opacity(0.06),
            Color.clear
        ],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static func scoreColor(for score: Int) -> Color {
        switch score {
        case 75...100: return emerald
        case 50...74:  return limeGood
        case 20...49:  return amberMediocre
        default:       return crimsonPoor
        }
    }

    static func ratingTitle(for score: Int) -> String {
        switch score {
        case 75...100: return "Excellent"
        case 50...74:  return "Good"
        case 20...49:  return "Mediocre"
        default:       return "Poor"
        }
    }
}

struct YarzarScoreRing: View {
    let score: Int
    var size: CGFloat = 76
    var lineWidth: CGFloat = 8

    private var color: Color {
        YarzarTheme.scoreColor(for: score)
    }

    var body: some View {
        ZStack {
            Circle()
                .stroke(color.opacity(0.16), lineWidth: lineWidth)

            Circle()
                .trim(from: 0, to: CGFloat(max(4, min(100, score))) / 100.0)
                .stroke(
                    AngularGradient(
                        colors: [color.opacity(0.75), color],
                        center: .center
                    ),
                    style: StrokeStyle(lineWidth: lineWidth, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))

            VStack(spacing: 0) {
                Text("\(score)")
                    .font(.system(size: size * 0.33, weight: .heavy, design: .rounded))
                    .foregroundStyle(color)
                Text("/100")
                    .font(.system(size: size * 0.14, weight: .semibold, design: .monospaced))
                    .foregroundStyle(.secondary)
            }
        }
        .frame(width: size, height: size)
    }
}

struct YarzarCardModifier: ViewModifier {
    var accent: Color = YarzarTheme.emerald
    @State private var isHovered = false

    func body(content: Content) -> some View {
        content
            .background(
                ZStack {
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(Color(nsColor: .controlBackgroundColor))
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(
                            LinearGradient(
                                colors: [
                                    accent.opacity(isHovered ? 0.07 : 0.025),
                                    Color.clear
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                }
            )
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .strokeBorder(
                        isHovered ? accent.opacity(0.45) : Color(nsColor: .separatorColor).opacity(0.65),
                        lineWidth: isHovered ? 1.2 : 1.0
                    )
            )
            .shadow(
                color: isHovered ? accent.opacity(0.10) : .black.opacity(0.04),
                radius: isHovered ? 7 : 2,
                y: isHovered ? 2 : 1
            )
            .animation(.easeOut(duration: 0.15), value: isHovered)
            .onHover { isHovered = $0 }
    }
}

extension View {
    func yarzarCard(accent: Color = YarzarTheme.emerald) -> some View {
        modifier(YarzarCardModifier(accent: accent))
    }
}
