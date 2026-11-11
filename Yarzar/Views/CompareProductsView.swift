import SwiftUI

struct CompareProductsView: View {
    @ObservedObject var store: ProductStore

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(L("Compare Products"))
                        .font(.system(size: 22, weight: .bold, design: .rounded))
                    Text(L("Side-by-Side Health Matrix"))
                        .font(.system(size: 13))
                        .foregroundStyle(.secondary)
                }

                HStack(spacing: 16) {
                    productPickerCard(title: L("Product A"), selection: $store.compareProductA)
                    productPickerCard(title: L("Product B"), selection: $store.compareProductB)
                }

                if let a = store.compareProductA, let b = store.compareProductB {
                    comparisonMatrix(a: a, b: b)
                }
            }
            .padding(20)
        }
    }

    private func productPickerCard(title: String, selection: Binding<ProductItem?>) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text(title)
                    .font(.system(size: 12, weight: .bold, design: .rounded))
                    .foregroundStyle(.secondary)
                Spacer()
                Picker("", selection: selection) {
                    ForEach(store.products) { item in
                        Text("\(item.emojiIcon) \(item.name) (\(item.totalScore)/100)")
                            .tag(ProductItem?.some(item))
                    }
                }
                .labelsHidden()
            }

            if let item = selection.wrappedValue {
                HStack(spacing: 12) {
                    Text(item.emojiIcon)
                        .font(.system(size: 34))
                    VStack(alignment: .leading, spacing: 2) {
                        Text(item.name)
                            .font(.system(size: 15, weight: .bold))
                        Text(item.brand)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    Spacer()
                    YarzarScoreRing(score: item.totalScore, size: 62, lineWidth: 7)
                }
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity)
        .yarzarCard(accent: selection.wrappedValue?.scoreColor ?? YarzarTheme.emerald)
    }

    private func comparisonMatrix(a: ProductItem, b: ProductItem) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            let winner = a.totalScore >= b.totalScore ? a : b
            let diff = abs(a.totalScore - b.totalScore)

            HStack(spacing: 10) {
                Image(systemName: "trophy.fill")
                    .foregroundStyle(YarzarTheme.emerald)
                Text("\(L("Winner")): \(winner.name) (+\(diff) pts)")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(YarzarTheme.emerald)
                Spacer()
            }
            .padding(12)
            .background(RoundedRectangle(cornerRadius: 10).fill(YarzarTheme.emerald.opacity(0.10)))

            matrixRow(label: L("Score Breakdown"), left: "\(a.totalScore) / 100 (\(L(a.ratingTitle)))", right: "\(b.totalScore) / 100 (\(L(b.ratingTitle)))", leftBetter: a.totalScore >= b.totalScore)
            matrixRow(label: L("Nutritional Quality (60%)"), left: "\(a.breakdown.nutritionalQualityScore) / 60", right: "\(b.breakdown.nutritionalQualityScore) / 60", leftBetter: a.breakdown.nutritionalQualityScore >= b.breakdown.nutritionalQualityScore)
            matrixRow(label: L("Additive Safety (30%)"), left: "\(a.breakdown.additiveSafetyScore)", right: "\(b.breakdown.additiveSafetyScore)", leftBetter: a.breakdown.additiveSafetyScore >= b.breakdown.additiveSafetyScore)
            matrixRow(label: L("Organic Certified"), left: a.isOrganic ? "✓ Yes" : "No", right: b.isOrganic ? "✓ Yes" : "No", leftBetter: a.isOrganic)
            matrixRow(label: L("Palm Oil-Free Alert"), left: a.containsPalmOil ? "Contains Palm Oil" : "✓ Palm-Oil-Free", right: b.containsPalmOil ? "Contains Palm Oil" : "✓ Palm-Oil-Free", leftBetter: !a.containsPalmOil)
            matrixRow(label: "Additives Count", left: "\(a.additives.count)", right: "\(b.additives.count)", leftBetter: a.additives.count <= b.additives.count)
        }
        .padding(16)
        .yarzarCard(accent: YarzarTheme.mintTeal)
    }

    private func matrixRow(label: String, left: String, right: String, leftBetter: Bool) -> some View {
        HStack {
            Text(left)
                .font(.system(size: 13, weight: leftBetter ? .bold : .medium, design: .monospaced))
                .foregroundStyle(leftBetter ? YarzarTheme.emerald : .secondary)
                .frame(maxWidth: .infinity, alignment: .leading)

            Text(label)
                .font(.system(size: 12, weight: .bold))
                .foregroundStyle(.secondary)
                .frame(width: 190, alignment: .center)

            Text(right)
                .font(.system(size: 13, weight: !leftBetter ? .bold : .medium, design: .monospaced))
                .foregroundStyle(!leftBetter ? YarzarTheme.emerald : .secondary)
                .frame(maxWidth: .infinity, alignment: .trailing)
        }
        .padding(.vertical, 6)
        .overlay(Divider(), alignment: .bottom)
    }
}
