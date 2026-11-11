import SwiftUI

struct AdditiveEncyclopediaView: View {
    @State private var searchText: String = ""

    private var filteredAdditives: [AdditiveItem] {
        YarzarScoringEngine.additiveReferenceLibrary.filter { item in
            searchText.isEmpty
                || item.code.localizedCaseInsensitiveContains(searchText)
                || item.name.localizedCaseInsensitiveContains(searchText)
                || item.functionCategory.localizedCaseInsensitiveContains(searchText)
                || item.scientificSummary.localizedCaseInsensitiveContains(searchText)
        }
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(L("Additive Intelligence"))
                        .font(.system(size: 22, weight: .bold, design: .rounded))
                    Text(L("Dose-Aware Nuance: Evaluates additive concentration tier (trace vs. primary) instead of flat binary penalties."))
                        .font(.system(size: 13))
                        .foregroundStyle(.secondary)
                }

                LazyVStack(spacing: 12) {
                    ForEach(filteredAdditives) { additive in
                        VStack(alignment: .leading, spacing: 8) {
                            HStack(spacing: 10) {
                                Text(additive.code)
                                    .font(.system(size: 12, weight: .bold, design: .monospaced))
                                    .foregroundStyle(.white)
                                    .padding(.horizontal, 9)
                                    .padding(.vertical, 3.5)
                                    .background(RoundedRectangle(cornerRadius: 7).fill(additive.riskLevel.color))

                                VStack(alignment: .leading, spacing: 1) {
                                    Text(additive.name)
                                        .font(.system(size: 15, weight: .bold))
                                    Text(additive.functionCategory)
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }

                                Spacer()

                                Text(L(additive.concentrationTier.rawValue))
                                    .font(.system(size: 11, weight: .semibold))
                                    .foregroundStyle(YarzarTheme.clinicalCyan)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 3)
                                    .background(Capsule().fill(YarzarTheme.clinicalCyan.opacity(0.14)))

                                Text(L(additive.riskLevel.rawValue))
                                    .font(.system(size: 11, weight: .bold))
                                    .foregroundStyle(additive.riskLevel.color)
                                    .padding(.horizontal, 9)
                                    .padding(.vertical, 3)
                                    .background(Capsule().fill(additive.riskLevel.color.opacity(0.14)))
                            }

                            Text(additive.scientificSummary)
                                .font(.system(size: 12.5))
                                .foregroundStyle(.secondary)

                            HStack(spacing: 12) {
                                Text("📋 \(additive.regulatoryNote)")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                Spacer()
                                if additive.isEndocrineDisruptor {
                                    Label(L("Endocrine Disruptor Guard"), systemImage: "exclamationmark.triangle.fill")
                                        .font(.caption2.weight(.bold))
                                        .foregroundStyle(YarzarTheme.crimsonPoor)
                                }
                            }
                        }
                        .padding(14)
                        .yarzarCard(accent: additive.riskLevel.color)
                    }
                }
            }
            .padding(20)
        }
        .searchable(text: $searchText, prompt: L("Search additives, E-numbers, or INCI names…"))
    }
}
