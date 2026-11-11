import SwiftUI

struct ProductDetailView: View {
    let product: ProductItem
    @ObservedObject var store: ProductStore
    var onSelectComparison: ((ProductItem) -> Void)? = nil

    private var violations: [DietaryRestriction] {
        store.dietaryViolations(for: product)
    }

    private var alternatives: [ProductItem] {
        store.healthierAlternatives(for: product)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            heroScoreCard
            dietaryAlertBanner
            threePillarBreakdownCard
            if let wf = product.wholeFoodProfile {
                wholeFoodAdvantageCard(wf)
            }
            if !product.nutrients.isEmpty {
                nutrientsSection
            }
            additivesSection
            ingredientsCard
            if !alternatives.isEmpty {
                alternativesSection
            }
        }
    }

    // MARK: - 1. Hero Score Card
    private var heroScoreCard: some View {
        HStack(alignment: .center, spacing: 18) {
            ZStack {
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(product.scoreColor.opacity(0.12))
                    .frame(width: 78, height: 78)

                if let urlStr = product.imageURL, let url = URL(string: urlStr) {
                    AsyncImage(url: url) { phase in
                        switch phase {
                        case .success(let image):
                            image
                                .resizable()
                                .scaledToFill()
                                .frame(width: 78, height: 78)
                                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                        default:
                            Text(product.emojiIcon)
                                .font(.system(size: 38))
                        }
                    }
                } else {
                    Text(product.emojiIcon)
                        .font(.system(size: 38))
                }
            }

            VStack(alignment: .leading, spacing: 5) {
                HStack(spacing: 6) {
                    Label(L(product.domain.rawValue), systemImage: product.domain.icon)
                        .font(.system(size: 11, weight: .bold))
                        .foregroundStyle(product.domain.color)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 3)
                        .background(Capsule().fill(product.domain.color.opacity(0.12)))

                    if product.isOrganic {
                        Label(L("Organic Certified"), systemImage: "leaf.fill")
                            .font(.system(size: 11, weight: .bold))
                            .foregroundStyle(YarzarTheme.emerald)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 3)
                            .background(Capsule().fill(YarzarTheme.emerald.opacity(0.14)))
                    }

                    if let nutri = product.nutriScoreGrade {
                        Text("Nutri-Score \(nutri)")
                            .font(.system(size: 10.5, weight: .bold, design: .rounded))
                            .foregroundStyle(YarzarTheme.clinicalCyan)
                            .padding(.horizontal, 7)
                            .padding(.vertical, 2.5)
                            .background(Capsule().fill(YarzarTheme.clinicalCyan.opacity(0.14)))
                    }

                    if let nova = product.novaGroup {
                        Text("NOVA \(nova)")
                            .font(.system(size: 10.5, weight: .bold, design: .monospaced))
                            .foregroundStyle(nova >= 4 ? YarzarTheme.crimsonPoor : YarzarTheme.emerald)
                            .padding(.horizontal, 7)
                            .padding(.vertical, 2.5)
                            .background(Capsule().fill((nova >= 4 ? YarzarTheme.crimsonPoor : YarzarTheme.emerald).opacity(0.14)))
                    }

                    Text(product.barcode)
                        .font(.system(size: 11, weight: .medium, design: .monospaced))
                        .foregroundStyle(.secondary)
                }

                Text(product.name)
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                HStack(spacing: 6) {
                    Text("\(product.brand) · \(product.category)")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundStyle(.secondary)
                    if let serving = product.servingSize, !serving.isEmpty {
                        Text("· \(serving)")
                            .font(.system(size: 12, weight: .semibold, design: .monospaced))
                            .foregroundStyle(.secondary)
                    }
                }

                HStack(spacing: 8) {
                    Button {
                        store.toggleFavorite(product)
                    } label: {
                        Label(
                            L(product.isFavorite ? "Favorited" : "Favorite"),
                            systemImage: product.isFavorite ? "heart.fill" : "heart"
                        )
                        .font(.caption.weight(.semibold))
                    }
                    .buttonStyle(.bordered)
                    .tint(product.isFavorite ? .pink : .secondary)

                    Button {
                        store.toggleOrganicStatus(for: product)
                    } label: {
                        Label(
                            L(product.isOrganic ? "Organic (+10 pts)" : "Set Organic"),
                            systemImage: product.isOrganic ? "checkmark.seal.fill" : "leaf"
                        )
                        .font(.caption.weight(.semibold))
                    }
                    .buttonStyle(.bordered)
                    .tint(product.isOrganic ? YarzarTheme.emerald : .secondary)

                    if let onSelectComparison {
                        Button {
                            onSelectComparison(product)
                        } label: {
                            Label(L("Compare"), systemImage: "arrow.left.arrow.right")
                                .font(.caption.weight(.semibold))
                        }
                        .buttonStyle(.bordered)
                    }
                }
                .padding(.top, 2)
            }

            Spacer()

            VStack(spacing: 6) {
                YarzarScoreRing(score: product.totalScore, size: 84, lineWidth: 9)
                Text(L(product.ratingTitle))
                    .font(.system(size: 12, weight: .bold, design: .rounded))
                    .foregroundStyle(product.scoreColor)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 3)
                    .background(Capsule().fill(product.scoreColor.opacity(0.14)))
            }
        }
        .padding(18)
        .yarzarCard(accent: product.scoreColor)
    }

    // MARK: - 2. Dietary Guardian Alert Banner
    @ViewBuilder
    private var dietaryAlertBanner: some View {
        if !violations.isEmpty {
            HStack(spacing: 12) {
                Image(systemName: "exclamationmark.shield.fill")
                    .font(.system(size: 22))
                    .foregroundStyle(YarzarTheme.crimsonPoor)
                VStack(alignment: .leading, spacing: 3) {
                    Text(L("Dietary Alert Triggered"))
                        .font(.system(size: 13, weight: .bold))
                        .foregroundStyle(YarzarTheme.crimsonPoor)
                    Text(violations.map { L($0.rawValue) }.joined(separator: " · "))
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(.primary)
                }
                Spacer()
            }
            .padding(14)
            .background(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(YarzarTheme.crimsonPoor.opacity(0.10))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .strokeBorder(YarzarTheme.crimsonPoor.opacity(0.35), lineWidth: 1)
                    )
            )
        } else {
            HStack(spacing: 10) {
                Image(systemName: "checkmark.shield.fill")
                    .font(.system(size: 16))
                    .foregroundStyle(YarzarTheme.emerald)
                Text(L("Matches All Your Dietary Preferences"))
                    .font(.system(size: 12.5, weight: .semibold))
                    .foregroundStyle(YarzarTheme.emerald)
                Spacer()
                Text(L("100% Independent · Zero Brand Funding · Dose-Aware Science"))
                    .font(.system(size: 11))
                    .foregroundStyle(.secondary)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
            .background(
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .fill(YarzarTheme.emerald.opacity(0.08))
            )
        }
    }

    // MARK: - 3. Three-Pillar Score Breakdown
    private var threePillarBreakdownCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(L("Score Breakdown"))
                .font(.system(size: 14, weight: .bold, design: .rounded))

            if product.domain == .cosmetic {
                pillarBar(
                    title: L("Ingredient Safety (100%)"),
                    score: product.breakdown.additiveSafetyScore,
                    maxScore: 100,
                    color: product.scoreColor,
                    subtitle: "Evaluated across endocrine disruption, allergenicity, carcinogenicity, and irritation thresholds."
                )
            } else {
                HStack(spacing: 12) {
                    pillarMiniCard(
                        title: L("Nutritional Quality (60%)"),
                        points: "\(product.breakdown.nutritionalQualityScore) / 60",
                        progress: Double(product.breakdown.nutritionalQualityScore) / 60.0,
                        color: YarzarTheme.emerald
                    )
                    pillarMiniCard(
                        title: L("Additive Safety (30%)"),
                        points: "\(product.breakdown.additiveSafetyScore) / 30",
                        progress: Double(product.breakdown.additiveSafetyScore) / 30.0,
                        color: YarzarTheme.mintTeal
                    )
                    pillarMiniCard(
                        title: L("Organic Dimension (10%)"),
                        points: "\(product.breakdown.organicDimensionScore) / 10",
                        progress: Double(product.breakdown.organicDimensionScore) / 10.0,
                        color: YarzarTheme.limeGood
                    )
                }
            }
        }
        .padding(16)
        .yarzarCard(accent: YarzarTheme.mintTeal)
    }

    private func pillarMiniCard(title: String, points: String, progress: Double, color: Color) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.system(size: 11.5, weight: .semibold))
                .foregroundStyle(.secondary)
                .lineLimit(1)
            Text(points)
                .font(.system(size: 18, weight: .heavy, design: .rounded))
                .foregroundStyle(color)
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule().fill(color.opacity(0.15))
                    Capsule()
                        .fill(color)
                        .frame(width: max(6, geo.size.width * max(0, min(1, progress))))
                }
            }
            .frame(height: 6)
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .fill(Color(nsColor: .windowBackgroundColor).opacity(0.6))
        )
    }

    private func pillarBar(title: String, score: Int, maxScore: Int, color: Color, subtitle: String) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(title)
                    .font(.system(size: 13, weight: .semibold))
                Spacer()
                Text("\(score) / \(maxScore)")
                    .font(.system(size: 14, weight: .bold, design: .monospaced))
                    .foregroundStyle(color)
            }
            Text(subtitle)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }

    // MARK: - 4. Whole Food Advantage Card
    private func wholeFoodAdvantageCard(_ wf: WholeFoodProfile) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Label(L("Whole Food Advantage"), systemImage: "leaf.circle.fill")
                    .font(.system(size: 14, weight: .bold, design: .rounded))
                    .foregroundStyle(YarzarTheme.emerald)
                Spacer()
                Text("\(L("Glycemic Index")): \(wf.glycemicIndex)")
                    .font(.system(size: 11.5, weight: .bold, design: .monospaced))
                    .foregroundStyle(wf.glycemicIndex < 55 ? YarzarTheme.emerald : YarzarTheme.amberMediocre)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(Capsule().fill(YarzarTheme.emerald.opacity(0.12)))
            }

            VStack(alignment: .leading, spacing: 6) {
                HStack(alignment: .top, spacing: 6) {
                    Text("🛡️ \(L("Pesticide Cleanliness")):")
                        .font(.caption.weight(.bold))
                    Text(wf.pesticideCategory)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                HStack(alignment: .top, spacing: 6) {
                    Text("🧬 \(L("Key Micronutrients")):")
                        .font(.caption.weight(.bold))
                    Text(wf.keyMicronutrients.joined(separator: " · "))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                HStack(alignment: .top, spacing: 6) {
                    Text("🍳 \(L("Best Preparation")):")
                        .font(.caption.weight(.bold))
                    Text(wf.bestPreparationTip)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .padding(16)
        .yarzarCard(accent: YarzarTheme.emerald)
    }

    // MARK: - 5. Nutrients Section
    private var nutrientsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(L("Nutritional Quality (60%)"))
                .font(.system(size: 14, weight: .bold, design: .rounded))

            ForEach(product.nutrients) { metric in
                VStack(alignment: .leading, spacing: 5) {
                    HStack {
                        Image(systemName: metric.icon)
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundStyle(metric.impact.color)
                            .frame(width: 18)
                        Text(L(metric.name))
                            .font(.system(size: 13, weight: .semibold))
                        Text("— \(metric.detailNote)")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .lineLimit(1)
                        Spacer()
                        Text(metric.valueText)
                            .font(.system(size: 12, weight: .bold, design: .monospaced))
                        Text(L(metric.impact.rawValue))
                            .font(.system(size: 10.5, weight: .bold))
                            .foregroundStyle(metric.impact.color)
                            .padding(.horizontal, 7)
                            .padding(.vertical, 2)
                            .background(Capsule().fill(metric.impact.color.opacity(0.14)))
                    }

                    GeometryReader { geo in
                        ZStack(alignment: .leading) {
                            Capsule().fill(Color.secondary.opacity(0.12))
                            Capsule()
                                .fill(metric.impact.color)
                                .frame(width: max(8, geo.size.width * min(1.0, metric.numericValue / max(1.0, metric.maxScaleValue))))
                        }
                    }
                    .frame(height: 5)
                }
                .padding(.vertical, 4)
            }
        }
        .padding(16)
        .yarzarCard(accent: YarzarTheme.emerald)
    }

    // MARK: - 6. Nuanced Additives Section (With Live Dose-Aware Recalculation!)
    private var additivesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text(L("Nuanced Additive & Ingredient Analysis"))
                        .font(.system(size: 14, weight: .bold, design: .rounded))
                    Text(L("Adjust additive concentration tier below to see real-time dose-weighted score impact."))
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
                Spacer()
                Text("\(product.additives.count)")
                    .font(.system(size: 11, weight: .bold, design: .monospaced))
                    .padding(.horizontal, 8)
                    .padding(.vertical, 2)
                    .background(Capsule().fill(Color.secondary.opacity(0.15)))
            }

            if product.additives.isEmpty {
                HStack(spacing: 8) {
                    Image(systemName: "checkmark.seal.fill")
                        .foregroundStyle(YarzarTheme.emerald)
                    Text(L("Zero Harmful Additives Detected"))
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(YarzarTheme.emerald)
                }
                .padding(.vertical, 4)
            } else {
                ForEach(product.additives) { additive in
                    VStack(alignment: .leading, spacing: 7) {
                        HStack(spacing: 8) {
                            Text(additive.code)
                                .font(.system(size: 11, weight: .bold, design: .monospaced))
                                .foregroundStyle(.white)
                                .padding(.horizontal, 7)
                                .padding(.vertical, 2.5)
                                .background(RoundedRectangle(cornerRadius: 6).fill(additive.riskLevel.color))

                            Text(additive.name)
                                .font(.system(size: 13, weight: .bold))

                            Text(additive.functionCategory)
                                .font(.caption)
                                .foregroundStyle(.secondary)

                            Spacer()

                            // Interactive Dose / Concentration Tier Selector
                            HStack(spacing: 4) {
                                ForEach(AdditiveConcentrationTier.allCases, id: \.self) { tier in
                                    let isSelected = additive.concentrationTier == tier
                                    Button {
                                        store.updateAdditiveConcentration(
                                            for: product,
                                            additiveCode: additive.code,
                                            newTier: tier
                                        )
                                    } label: {
                                        Text(L(tier.shortTitle))
                                            .font(.system(size: 10, weight: isSelected ? .bold : .medium))
                                            .foregroundStyle(isSelected ? .white : YarzarTheme.clinicalCyan)
                                            .padding(.horizontal, 7)
                                            .padding(.vertical, 2.5)
                                            .background(
                                                Capsule()
                                                    .fill(isSelected ? YarzarTheme.clinicalCyan : YarzarTheme.clinicalCyan.opacity(0.12))
                                            )
                                    }
                                    .buttonStyle(.plain)
                                }
                            }

                            Text(L(additive.riskLevel.rawValue))
                                .font(.system(size: 10.5, weight: .bold))
                                .foregroundStyle(additive.riskLevel.color)
                                .padding(.horizontal, 7)
                                .padding(.vertical, 2)
                                .background(Capsule().fill(additive.riskLevel.color.opacity(0.14)))
                        }

                        Text(additive.scientificSummary)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Text("📋 \(additive.regulatoryNote)")
                            .font(.caption2)
                            .foregroundStyle(.tertiary)
                    }
                    .padding(10)
                    .background(
                        RoundedRectangle(cornerRadius: 9, style: .continuous)
                            .fill(Color(nsColor: .windowBackgroundColor).opacity(0.55))
                    )
                }
            }
        }
        .padding(16)
        .yarzarCard(accent: YarzarTheme.mintTeal)
    }

    // MARK: - 7. Ingredients Text Card
    private var ingredientsCard: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(L("Ingredients"))
                .font(.system(size: 13, weight: .bold, design: .rounded))
            Text(product.ingredientsText)
                .font(.system(size: 12.5))
                .foregroundStyle(.secondary)
                .textSelection(.enabled)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(14)
        .yarzarCard(accent: YarzarTheme.emerald)
    }

    // MARK: - 8. Smart Healthier Alternatives
    private var alternativesSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Label(L("Healthier Alternatives"), systemImage: "sparkles")
                    .font(.system(size: 14, weight: .bold, design: .rounded))
                    .foregroundStyle(YarzarTheme.emerald)
                Text("— \(L("Smart Recommendations in Same Category"))")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Spacer()
            }

            ForEach(alternatives) { alt in
                HStack(spacing: 12) {
                    if let urlStr = alt.imageURL, let url = URL(string: urlStr) {
                        AsyncImage(url: url) { phase in
                            switch phase {
                            case .success(let img):
                                img.resizable().scaledToFill()
                                    .frame(width: 38, height: 38)
                                    .clipShape(RoundedRectangle(cornerRadius: 8))
                            default:
                                Text(alt.emojiIcon).font(.system(size: 24))
                            }
                        }
                    } else {
                        Text(alt.emojiIcon)
                            .font(.system(size: 26))
                    }
                    VStack(alignment: .leading, spacing: 2) {
                        Text(alt.name)
                            .font(.system(size: 13, weight: .bold))
                        Text("\(alt.brand) · \(alt.barcode)")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    Spacer()

                    let delta = alt.totalScore - product.totalScore
                    if delta > 0 {
                        Text("+\(delta) pts")
                            .font(.system(size: 11, weight: .bold, design: .monospaced))
                            .foregroundStyle(YarzarTheme.emerald)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 3)
                            .background(Capsule().fill(YarzarTheme.emerald.opacity(0.14)))
                    }

                    YarzarScoreRing(score: alt.totalScore, size: 44, lineWidth: 5)

                    Button(L("Select Product")) {
                        store.selectAndRecordScan(alt)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(YarzarTheme.emerald)
                    .controlSize(.small)
                }
                .padding(10)
                .background(
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .fill(Color(nsColor: .windowBackgroundColor).opacity(0.55))
                )
            }
        }
        .padding(16)
        .yarzarCard(accent: YarzarTheme.emerald)
    }
}
