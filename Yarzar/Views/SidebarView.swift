import AppKit
import SwiftUI

struct SidebarView: View {
    @Binding var selection: SidebarDestination
    @ObservedObject var store: ProductStore
    @ObservedObject private var lang = LanguageManager.shared
    @ObservedObject private var theme = ThemeManager.shared

    var body: some View {
        VStack(spacing: 0) {
            brandHeader
                .padding(.horizontal, 14)
                .padding(.top, 12)
                .padding(.bottom, 10)
                .background(YarzarTheme.subtleHeaderGradient)

            Divider().opacity(0.5)

            List {
                Section {
                    SidebarNavRow(
                        selection: $selection,
                        tag: .scanner,
                        title: L("Scanner & Live Lookup"),
                        subtitle: L("Barcode, Camera & OCR Label"),
                        icon: "barcode.viewfinder",
                        badge: 0
                    )
                    SidebarNavRow(
                        selection: $selection,
                        tag: .catalog,
                        title: L("Product Catalog"),
                        subtitle: L("Food & Cosmetics Database"),
                        icon: "shippingbox.fill",
                        badge: store.products.count
                    )
                    SidebarNavRow(
                        selection: $selection,
                        tag: .wholeFoods,
                        title: L("Whole Foods Studio"),
                        subtitle: L("Fresh Produce & Raw Foods"),
                        icon: "leaf.circle.fill",
                        badge: store.products.filter { $0.domain == .wholeFood }.count
                    )
                } header: {
                    Text(L("SCAN & ANALYZE"))
                        .font(.system(size: 10, weight: .bold, design: .rounded))
                        .foregroundStyle(YarzarTheme.emerald)
                        .tracking(0.8)
                }

                Section {
                    SidebarNavRow(
                        selection: $selection,
                        tag: .additives,
                        title: L("Additive Intelligence"),
                        subtitle: L("Dose-Aware Risk Encyclopedia"),
                        icon: "flask.fill",
                        badge: YarzarScoringEngine.additiveReferenceLibrary.count
                    )
                    SidebarNavRow(
                        selection: $selection,
                        tag: .compare,
                        title: L("Compare Products"),
                        subtitle: L("Side-by-Side Health Matrix"),
                        icon: "arrow.left.arrow.right.square.fill",
                        badge: 0
                    )
                } header: {
                    Text(L("EXPLORE & COMPARE"))
                        .font(.system(size: 10, weight: .bold, design: .rounded))
                        .foregroundStyle(YarzarTheme.mintTeal)
                        .tracking(0.8)
                }

                Section {
                    SidebarNavRow(
                        selection: $selection,
                        tag: .dietaryGuardian,
                        title: L("Dietary Guardian"),
                        subtitle: L("Allergens & Personal Alerts"),
                        icon: "shield.checkered",
                        badge: store.activeRestrictions.count
                    )
                    SidebarNavRow(
                        selection: $selection,
                        tag: .history,
                        title: L("Scan History & Basket"),
                        subtitle: L("Your Health Score Analytics"),
                        icon: "chart.pie.fill",
                        badge: store.favoriteProducts.count
                    )
                } header: {
                    Text(L("PERSONALIZE"))
                        .font(.system(size: 10, weight: .bold, design: .rounded))
                        .foregroundStyle(.secondary)
                        .tracking(0.8)
                }

                Section {
                    Button {
                        NSWorkspace.shared.open(AppLinks.helpURL)
                    } label: {
                        HStack(spacing: 10) {
                            ZStack {
                                RoundedRectangle(cornerRadius: 6, style: .continuous)
                                    .fill(YarzarTheme.mintTeal.opacity(0.14))
                                    .frame(width: 26, height: 26)
                                Image(systemName: "book.closed.fill")
                                    .font(.system(size: 12, weight: .semibold))
                                    .foregroundStyle(YarzarTheme.mintTeal)
                            }
                            VStack(alignment: .leading, spacing: 1) {
                                Text(L("User Guide"))
                                    .font(.system(size: 13, weight: .medium))
                                Text("github.com/themanoftalent/Yarzar")
                                    .font(.caption2)
                                    .foregroundStyle(.secondary)
                                    .lineLimit(1)
                            }
                            Spacer()
                            Image(systemName: "arrow.up.right")
                                .font(.caption2.weight(.semibold))
                                .foregroundStyle(.secondary)
                        }
                        .padding(.vertical, 3)
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)

                    SidebarNavRow(
                        selection: $selection,
                        tag: .about,
                        title: L("About Yarzar"),
                        subtitle: L("Developer & support"),
                        icon: "info.circle.fill",
                        badge: 0
                    )
                } header: {
                    Text(L("HELP"))
                        .font(.system(size: 10, weight: .bold, design: .rounded))
                        .foregroundStyle(.secondary)
                        .tracking(0.8)
                }
            }
            .listStyle(.sidebar)

            Divider().opacity(0.6)

            HStack(spacing: 6) {
                Button {
                    theme.toggleTheme()
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: theme.isDark ? "moon.fill" : "sun.max.fill")
                            .font(.system(size: 10, weight: .semibold))
                        Text(L(theme.isDark ? "Dark" : "Normal"))
                            .font(.system(size: 10.5, weight: .bold, design: .rounded))
                    }
                    .foregroundStyle(theme.isDark ? YarzarTheme.mintTeal : YarzarTheme.amberMediocre)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3.5)
                    .background(
                        Capsule()
                            .fill((theme.isDark ? YarzarTheme.mintTeal : YarzarTheme.amberMediocre).opacity(0.14))
                    )
                    .fixedSize()
                }
                .buttonStyle(.plain)
                .help(L(theme.isDark ? "Switch to Normal Theme" : "Switch to Dark Theme"))

                Button {
                    lang.toggleLanguage()
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "globe")
                            .font(.system(size: 10.5, weight: .semibold))
                        Text(lang.currentLanguage.uppercased())
                            .font(.system(size: 10.5, weight: .bold, design: .rounded))
                    }
                    .foregroundStyle(YarzarTheme.emerald)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3.5)
                    .background(
                        Capsule()
                            .fill(YarzarTheme.emerald.opacity(0.14))
                    )
                    .fixedSize()
                }
                .buttonStyle(.plain)
                .help(lang.currentLanguage == "en" ? "Türkçe'ye geç (Switch to Turkish)" : "Switch to English (İngilizce'ye geç)")

                Spacer()

                Button {
                    selection = .about
                } label: {
                    Text(AppVersion.current.displayString)
                        .font(.system(size: 11, weight: .semibold, design: .monospaced))
                        .foregroundStyle(YarzarTheme.emerald)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 3)
                        .background(
                            Capsule()
                                .fill(YarzarTheme.emerald.opacity(0.12))
                        )
                        .fixedSize()
                }
                .buttonStyle(.plain)
                .help(L("About Yarzar"))
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
        }
    }

    private var brandHeader: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 10) {
                if let appIcon = NSImage(named: NSImage.applicationIconName) {
                    Image(nsImage: appIcon)
                        .resizable()
                        .interpolation(.high)
                        .frame(width: 36, height: 36)
                        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                } else {
                    ZStack {
                        RoundedRectangle(cornerRadius: 9, style: .continuous)
                            .fill(YarzarTheme.brandGradient)
                            .frame(width: 34, height: 34)
                        Image(systemName: "checkmark.shield.fill")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundStyle(.white)
                    }
                }

                VStack(alignment: .leading, spacing: 1) {
                    Text(L("Yarzar"))
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                    Text(L("Food, Cosmetic & Whole-Food Health Scanner"))
                        .font(.system(size: 10, weight: .medium))
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }
                Spacer()
            }

            HStack(spacing: 6) {
                headerPill(
                    dotColor: YarzarTheme.scoreColor(for: store.basketAverageScore),
                    label: L("Basket Health Average"),
                    value: "\(store.basketAverageScore)/100"
                )
                headerPill(
                    dotColor: YarzarTheme.emerald,
                    label: L("Favorites"),
                    value: "\(store.favoriteProducts.count)"
                )
            }
        }
    }

    private func headerPill(dotColor: Color, label: String, value: String) -> some View {
        HStack(spacing: 4) {
            Circle()
                .fill(dotColor)
                .frame(width: 6, height: 6)
            Text(label)
                .font(.system(size: 9.5, weight: .medium))
                .foregroundStyle(.secondary)
                .lineLimit(1)
            Text(value)
                .font(.system(size: 10, weight: .bold, design: .monospaced))
                .foregroundStyle(.primary)
        }
        .padding(.horizontal, 7)
        .padding(.vertical, 3.5)
        .background(
            Capsule()
                .fill(Color(nsColor: .controlBackgroundColor).opacity(0.88))
        )
        .overlay(
            Capsule()
                .strokeBorder(Color(nsColor: .separatorColor).opacity(0.5), lineWidth: 0.8)
        )
    }
}

private struct SidebarNavRow: View {
    @Binding var selection: SidebarDestination
    let tag: SidebarDestination
    let title: String
    let subtitle: String
    let icon: String
    let badge: Int

    private var isSelected: Bool { selection == tag }

    var body: some View {
        Button {
            selection = tag
        } label: {
            HStack(spacing: 10) {
                ZStack {
                    RoundedRectangle(cornerRadius: 6, style: .continuous)
                        .fill(isSelected ? Color.white.opacity(0.22) : YarzarTheme.emerald.opacity(0.13))
                        .frame(width: 26, height: 26)
                    Image(systemName: icon)
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(isSelected ? .white : YarzarTheme.emerald)
                }

                VStack(alignment: .leading, spacing: 1) {
                    Text(title)
                        .font(.system(size: 13, weight: isSelected ? .semibold : .medium))
                        .foregroundStyle(isSelected ? .white : .primary)
                        .lineLimit(1)
                    Text(subtitle)
                        .font(.caption2)
                        .foregroundStyle(isSelected ? .white.opacity(0.84) : .secondary)
                        .lineLimit(1)
                }

                Spacer(minLength: 4)

                if badge > 0 {
                    Text("\(badge)")
                        .font(.system(size: 10, weight: .bold, design: .monospaced))
                        .foregroundStyle(isSelected ? .white : YarzarTheme.emerald)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(
                            Capsule()
                                .fill(isSelected ? Color.white.opacity(0.22) : YarzarTheme.emerald.opacity(0.14))
                        )
                }
            }
            .padding(.vertical, 3)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .listRowBackground(
            Group {
                if isSelected {
                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                        .fill(YarzarTheme.brandGradient)
                        .padding(.vertical, 1)
                } else {
                    Color.clear
                }
            }
        )
    }
}
