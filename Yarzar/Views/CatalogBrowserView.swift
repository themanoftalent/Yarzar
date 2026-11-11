import SwiftUI

struct CatalogBrowserView: View {
    @ObservedObject var store: ProductStore
    var filterDomain: ProductDomain? = nil
    var onInspectProduct: (ProductItem) -> Void
    var onCompareProduct: (ProductItem) -> Void

    @State private var searchText: String = ""
    @State private var selectedDomain: ProductDomain? = nil

    private var filteredProducts: [ProductItem] {
        let domainTarget = filterDomain ?? selectedDomain
        return store.products.filter { item in
            let matchesDomain = (domainTarget == nil) || (item.domain == domainTarget)
            let matchesSearch = searchText.isEmpty
                || item.name.localizedCaseInsensitiveContains(searchText)
                || item.brand.localizedCaseInsensitiveContains(searchText)
                || item.barcode.localizedCaseInsensitiveContains(searchText)
                || item.ingredientsText.localizedCaseInsensitiveContains(searchText)
            return matchesDomain && matchesSearch
        }
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                headerSection

                if filterDomain == .wholeFood {
                    wholeFoodBanner
                }

                LazyVStack(spacing: 12) {
                    ForEach(filteredProducts) { item in
                        catalogRow(item)
                    }
                }
            }
            .padding(20)
        }
        .searchable(text: $searchText, prompt: L("Search products, brands, barcodes, or ingredients…"))
    }

    private var headerSection: some View {
        HStack {
            VStack(alignment: .leading, spacing: 3) {
                Text(filterDomain == .wholeFood ? L("Whole Foods Studio") : L("Product Catalog"))
                    .font(.system(size: 22, weight: .bold, design: .rounded))
                Text(filterDomain == .wholeFood
                     ? L("Whole Foods Support: Evaluates non-barcoded fresh fruits, vegetables, meats, and grains with GI and pesticide metrics.")
                     : L("Evaluate food, cosmetics, and raw whole foods with transparent scientific scoring."))
                    .font(.system(size: 13))
                    .foregroundStyle(.secondary)
            }
            Spacer()

            if filterDomain == nil {
                Picker("", selection: $selectedDomain) {
                    Text(L("All Categories")).tag(ProductDomain?.none)
                    ForEach(ProductDomain.allCases) { dom in
                        Text(L(dom.rawValue)).tag(ProductDomain?.some(dom))
                    }
                }
                .pickerStyle(.segmented)
                .frame(maxWidth: 420)
            }
        }
    }

    private var wholeFoodBanner: some View {
        HStack(spacing: 14) {
            Image(systemName: "leaf.circle.fill")
                .font(.system(size: 28))
                .foregroundStyle(YarzarTheme.emerald)
            VStack(alignment: .leading, spacing: 3) {
                Text(L("Why Yarzar Improves on Traditional Scanners"))
                    .font(.system(size: 14, weight: .bold))
                Text(L("Whole Foods Support: Evaluates non-barcoded fresh fruits, vegetables, meats, and grains with GI and pesticide metrics."))
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Spacer()
        }
        .padding(14)
        .yarzarCard(accent: YarzarTheme.emerald)
    }

    private func catalogRow(_ item: ProductItem) -> some View {
        HStack(spacing: 14) {
            ZStack {
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(item.scoreColor.opacity(0.12))
                    .frame(width: 54, height: 54)
                Text(item.emojiIcon)
                    .font(.system(size: 28))
            }

            VStack(alignment: .leading, spacing: 3) {
                HStack(spacing: 6) {
                    Text(item.name)
                        .font(.system(size: 15, weight: .bold, design: .rounded))
                    if item.isOrganic {
                        Text(L("Organic Certified"))
                            .font(.system(size: 10, weight: .bold))
                            .foregroundStyle(YarzarTheme.emerald)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Capsule().fill(YarzarTheme.emerald.opacity(0.14)))
                    }
                }
                Text("\(item.brand) · \(item.category) · \(item.barcode)")
                    .font(.caption)
                    .foregroundStyle(.secondary)

                HStack(spacing: 8) {
                    Text(L(item.domain.rawValue))
                        .font(.system(size: 10.5, weight: .semibold))
                        .foregroundStyle(item.domain.color)
                    if !item.additives.isEmpty {
                        Text("\(item.additives.count) additive(s)")
                            .font(.system(size: 10.5, weight: .medium))
                            .foregroundStyle(.secondary)
                    } else {
                        Text(L("Zero Harmful Additives Detected"))
                            .font(.system(size: 10.5, weight: .medium))
                            .foregroundStyle(YarzarTheme.emerald)
                    }
                }
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 4) {
                Text(L(item.ratingTitle))
                    .font(.system(size: 11, weight: .bold))
                    .foregroundStyle(item.scoreColor)
                HStack(spacing: 6) {
                    Button(L("Compare")) {
                        onCompareProduct(item)
                    }
                    .buttonStyle(.bordered)
                    .controlSize(.small)

                    Button(L("Select Product")) {
                        onInspectProduct(item)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(YarzarTheme.emerald)
                    .controlSize(.small)
                }
            }

            YarzarScoreRing(score: item.totalScore, size: 54, lineWidth: 6)
        }
        .padding(14)
        .yarzarCard(accent: item.scoreColor)
    }
}
