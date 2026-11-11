import SwiftUI

struct DietaryGuardianView: View {
    @ObservedObject var store: ProductStore

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(L("Dietary Guardian"))
                        .font(.system(size: 22, weight: .bold, design: .rounded))
                    Text(L("All Features Free: Offline database, manual search, OCR label scanner, and dietary alerts with zero paywalls."))
                        .font(.system(size: 13))
                        .foregroundStyle(.secondary)
                }

                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                    ForEach(DietaryRestriction.allCases) { restriction in
                        let isOn = store.activeRestrictions.contains(restriction)
                        Button {
                            store.toggleRestriction(restriction)
                        } label: {
                            HStack(spacing: 12) {
                                ZStack {
                                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                                        .fill(isOn ? YarzarTheme.emerald.opacity(0.18) : Color.secondary.opacity(0.10))
                                        .frame(width: 40, height: 40)
                                    Image(systemName: restriction.icon)
                                        .font(.system(size: 16, weight: .semibold))
                                        .foregroundStyle(isOn ? YarzarTheme.emerald : .secondary)
                                }
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(L(restriction.rawValue))
                                        .font(.system(size: 13.5, weight: .bold))
                                        .foregroundStyle(.primary)
                                    Text(isOn ? "Active Alert" : "Disabled")
                                        .font(.caption)
                                        .foregroundStyle(isOn ? YarzarTheme.emerald : .secondary)
                                }
                                Spacer()
                                Image(systemName: isOn ? "checkmark.circle.fill" : "circle")
                                    .font(.system(size: 18))
                                    .foregroundStyle(isOn ? YarzarTheme.emerald : .secondary)
                            }
                            .padding(14)
                            .yarzarCard(accent: isOn ? YarzarTheme.emerald : .secondary)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
            .padding(20)
        }
    }
}

struct HistoryBasketView: View {
    @ObservedObject var store: ProductStore
    var onSelectProduct: (ProductItem) -> Void

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                HStack(spacing: 18) {
                    YarzarScoreRing(score: store.basketAverageScore, size: 78, lineWidth: 8)
                    VStack(alignment: .leading, spacing: 4) {
                        Text(L("Basket Health Average"))
                            .font(.system(size: 20, weight: .bold, design: .rounded))
                        Text("\(L(YarzarTheme.ratingTitle(for: store.basketAverageScore))) · \(store.scannedHistory.count) \(L("Scanned Items")) · \(store.favoriteProducts.count) \(L("Favorites"))")
                            .font(.system(size: 13))
                            .foregroundStyle(.secondary)
                    }
                    Spacer()
                }
                .padding(18)
                .yarzarCard(accent: YarzarTheme.scoreColor(for: store.basketAverageScore))

                Text(L("Scanned Items"))
                    .font(.system(size: 15, weight: .bold, design: .rounded))

                ForEach(store.scannedHistory.isEmpty ? store.products : store.scannedHistory) { item in
                    HStack(spacing: 12) {
                        Text(item.emojiIcon).font(.system(size: 26))
                        VStack(alignment: .leading, spacing: 2) {
                            Text(item.name).font(.system(size: 14, weight: .bold))
                            Text("\(item.brand) · \(item.barcode)").font(.caption).foregroundStyle(.secondary)
                        }
                        Spacer()
                        YarzarScoreRing(score: item.totalScore, size: 46, lineWidth: 5)
                        Button(L("Select Product")) {
                            onSelectProduct(item)
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(YarzarTheme.emerald)
                        .controlSize(.small)
                    }
                    .padding(12)
                    .yarzarCard(accent: item.scoreColor)
                }
            }
            .padding(20)
        }
    }
}
