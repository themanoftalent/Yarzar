import AppKit
import SwiftUI

struct ContentView: View {
    @StateObject private var store = ProductStore()
    @StateObject private var updateChecker = UpdateChecker()
    @ObservedObject private var lang = LanguageManager.shared
    @ObservedObject private var theme = ThemeManager.shared

    @State private var selection: SidebarDestination = .scanner
    @State private var showAboutSheet = false

    var body: some View {
        NavigationSplitView {
            SidebarView(selection: $selection, store: store)
                .navigationSplitViewColumnWidth(min: 245, ideal: 265, max: 300)
        } detail: {
            detailContent
        }
        .id("\(lang.currentLanguage)-\(theme.currentTheme.rawValue)")
        .preferredColorScheme(theme.colorScheme)
        .sheet(isPresented: $showAboutSheet) {
            AboutView(updateChecker: updateChecker)
        }
        .onReceive(NotificationCenter.default.publisher(for: .showYarzarAbout)) { _ in
            showAboutSheet = true
        }
    }

    @ViewBuilder
    private var detailContent: some View {
        switch selection {
        case .scanner:
            ScannerDashboardView(
                store: store,
                onOpenCompare: { item in
                    store.compareProductA = item
                    if let firstAlt = store.healthierAlternatives(for: item).first {
                        store.compareProductB = firstAlt
                    }
                    selection = .compare
                }
            )
        case .catalog:
            CatalogBrowserView(
                store: store,
                filterDomain: nil,
                onInspectProduct: { item in
                    store.selectAndRecordScan(item)
                    selection = .scanner
                },
                onCompareProduct: { item in
                    store.compareProductA = item
                    if let firstAlt = store.healthierAlternatives(for: item).first {
                        store.compareProductB = firstAlt
                    }
                    selection = .compare
                }
            )
        case .wholeFoods:
            CatalogBrowserView(
                store: store,
                filterDomain: .wholeFood,
                onInspectProduct: { item in
                    store.selectAndRecordScan(item)
                    selection = .scanner
                },
                onCompareProduct: { item in
                    store.compareProductA = item
                    selection = .compare
                }
            )
        case .additives:
            AdditiveEncyclopediaView()
        case .compare:
            CompareProductsView(store: store)
        case .dietaryGuardian:
            DietaryGuardianView(store: store)
        case .history:
            HistoryBasketView(
                store: store,
                onSelectProduct: { item in
                    store.selectAndRecordScan(item)
                    selection = .scanner
                }
            )
        case .about:
            AboutView(updateChecker: updateChecker, isInlinePage: true)
        }
    }
}
